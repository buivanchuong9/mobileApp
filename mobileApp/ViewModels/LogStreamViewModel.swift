import Foundation
import Combine
import Supabase
import Realtime

enum ConnectionStatus: Equatable {
    case disconnected
    case connecting
    case connected
    case error(String)
    
    var displayText: String {
        switch self {
        case .disconnected: return "Ngắt kết nối"
        case .connecting: return "Đang kết nối..."
        case .connected: return "Đã kết nối"
        case .error(let message): return "Lỗi: \(message)"
        }
    }
    
    var isConnected: Bool {
        if case .connected = self { return true }
        return false
    }
}

class LogStreamViewModel: ObservableObject {
    @Published var logs: [LogEntry] = []
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var stats: LogStats?
    @Published var autoScroll: Bool = true
    @Published var filterLevel: LogLevel?
    
    private let supabase = SupabaseManager.shared.client
    private var realtimeChannel: RealtimeChannelV2?
    private var subscriptionTask: Task<Void, Never>?
    private let maxLogsCount = 500
    
    // MARK: - Connection
    
    func connect() {
        guard connectionStatus != .connected else { return }
        
        connectionStatus = .connecting
        
        subscriptionTask?.cancel()
        
        subscriptionTask = Task { [weak self] in
            guard let self = self else { return }
            do {
                let channel = self.supabase.channel("public:logs")
                
                // Use InsertAction to specifically listen for INSERT events
                let insertions = channel.postgresChange(
                    InsertAction.self,
                    schema: "public",
                    table: "logs"
                )
                
                await channel.subscribe()
                
                await MainActor.run {
                    self.realtimeChannel = channel
                    self.connectionStatus = .connected
                    let infoLog = LogEntry(level: .info, message: "Realtime Connected")
                    self.logs.append(infoLog)
                }
                
                // Fetch recent history
                await self.fetchRecentLogs()
                
                // Listen for changes using AsyncSequence (Standard Swift Concurrency)
                for await insert in insertions {
                    if Task.isCancelled { break }
                    let record = insert.record
                    self.handleRealtimeRecord(record)
                }
                
            } catch {
                if Task.isCancelled { return }
                await MainActor.run {
                    self.connectionStatus = .error(error.localizedDescription)
                }
            }
        }
    }
    
    func disconnect() {
        subscriptionTask?.cancel()
        subscriptionTask = nil
        
        Task { [weak self] in
            guard let self = self else { return }
            if let channel = self.realtimeChannel {
                try? await self.supabase.removeChannel(channel)
            }
            await MainActor.run {
                self.realtimeChannel = nil
                self.connectionStatus = .disconnected
            }
        }
    }
    
    // MARK: - Handlers
    
    private func handleRealtimeRecord(_ record: [String: AnyJSON]) {
        // Parse record manually to avoid Codable generic issues
        // We know the fields: message, level, created_at, id
        
        guard let message = record["message"]?.stringValue else { return }
        
        let levelString = record["level"]?.stringValue ?? "INFO"
        let level = LogLevel(rawValue: levelString.uppercased()) ?? .info
        
        // Parse timestamp
        let timestamp: Date
        if let timeStr = record["created_at"]?.stringValue {
            timestamp = ISO8601DateFormatter().date(from: timeStr) ?? Date()
        } else {
            timestamp = Date()
        }
        
        // Parse ID
        let id: UUID
        if let idStr = record["id"]?.stringValue {
            // ID in DB might be Int8 or UUID.
            // If it's Int8 (from the SQL provided), we create a UUID from hash or random
            // Ideally we change LogEntry.swift to accept Int or String ID, but let's just make a UUID wrapper
            id = UUID(uuidString: idStr) ?? UUID()
        } else if let idInt = record["id"]?.intValue {
             // Create a deterministic UUID from the Int ID if needed, or just random
             // For UI list uniqueness, random is fine mostly, but idInt is better.
             id = UUID() 
        } else {
             id = UUID()
        }
        
        let logEntry = LogEntry(id: id, timestamp: timestamp, level: level, message: message)
        
        DispatchQueue.main.async {
            // Insert at top (newest first)
            self.logs.insert(logEntry, at: 0)
            if self.logs.count > self.maxLogsCount {
                self.logs.removeLast()
            }
        }
    }
    
    // MARK: - Data Fetching
    
    func fetchRecentLogs(lines: Int = 50) async {
        do {
            let validLogs: [LogEntry] = try await supabase
                .from("logs")
                .select()
                .order("created_at", ascending: false)
                .limit(lines)
                .execute()
                .value
            
            await MainActor.run {
                // Since validLogs is ordered DESC (newest first), we just replace or append correctly.
                // If we want newest at top, validLogs is already correct.
                // We should append them to the current logs (if real-time logs came in first, they are newer)
                // But typically fetchHistory happens once. Let's just set them if empty, or append unique.
                // Ideally: self.logs.append(contentsOf: validLogs) 
                
                // Simplified: just set them initially or append properly
                if self.logs.isEmpty {
                     self.logs = validLogs
                } else {
                     // Filter duplicates based on ID or timestamp if needed, but for now simple append is okay
                     // Logs are [Oldest ... Newest]?? No, query is ORDER BY created_at DESC -> [Newest ... Oldest]
                     // So validLogs = [Newest ... Oldest]
                     // Our UI list expects: [Newest ... Oldest]
                     // So we append validLogs to the END of current list (which are newer realtime logs)
                     self.logs.append(contentsOf: validLogs)
                }
            }
        } catch {
            print("Error fetching history: \(error)")
            await MainActor.run {
                let errorLog = LogEntry(level: .error, message: "Lỗi tải lịch sử: \(error.localizedDescription)")
                self.logs.append(errorLog)
            }
        }
    }
    
    func fetchStats() async {
        let stats = LogStats(
            success: true,
            filePath: "Supabase Realtime",
            fileSizeMB: 0.0,
            modifiedAt: Date().ISO8601Format(),
            activeConnections: 1
        )
        
        await MainActor.run {
            self.stats = stats
        }
    }
    
    // MARK: - Utils
    
    func clearLogs() {
        logs.removeAll()
    }
    
    var filteredLogs: [LogEntry] {
        guard let filterLevel = filterLevel else {
            return logs
        }
        return logs.filter { $0.level == filterLevel }
    }
    
    func exportLogs() -> String {
        logs.map { "\($0.formattedTime) - \($0.level.rawValue) - \($0.message)" }
            .joined(separator: "\n")
    }
    
    deinit {
        disconnect()
    }
}
