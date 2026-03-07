//
//  PrivacyPolicyView.swift
//  mobileApp
//
//  Created by Antigravity on 7/3/26.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var theme: ThemeManager
    
    @State private var hasScrolledToBottom = false
    @State private var isAgreed = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Chính Sách Bảo Mật")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(theme.primaryText)
                            .padding(.bottom, 10)
                        
                        Group {
                            policySection(title: "1. Thu thập dữ liệu", content: "Chúng tôi thu thập các thông tin cá nhân bao gồm: Họ tên, địa chỉ email để quản lý tài khoản. Ngoài ra, ứng dụng thu thập dữ liệu video từ camera (hoặc tệp tin bạn chọn) để thực hiện phân tích AI.")
                            
                            policySection(title: "2. Sử dụng dữ liệu", content: "Dữ liệu của bạn được sử dụng để: Cung cấp tính năng phân tích lái xe (ADAS) và giám sát tài xế, cải thiện độ chính xác của AI, và hỗ trợ kỹ thuật.")
                            
                            policySection(title: "3. Chia sẻ với bên thứ ba", content: "Để thực hiện phân tích AI, video của bạn sẽ được gửi đến máy chủ xử lý tại adas-api.aiotlab.edu.vn. Chúng tôi cam kết không chia sẻ dữ liệu cá nhân của bạn cho bất kỳ mục đích quảng cáo của bên thứ ba nào mà không có sự đồng ý của bạn.")
                            
                            policySection(title: "4. Quyền của người dùng", content: "Bạn có quyền truy cập, sửa đổi hoặc xóa dữ liệu cá nhân của mình bất kỳ lúc nào thông qua tính năng 'Xóa tài khoản' trong ứng dụng. Khi tài khoản bị xóa, toàn bộ dữ liệu liên quan cũng sẽ bị xóa vĩnh viễn khỏi hệ thống của chúng tôi.")
                            
                            policySection(title: "5. Quyền riêng tư & Theo dõi", content: "Ứng dụng không sử dụng IDFA và không theo dõi người dùng cho mục đích quảng cáo.")
                            
                            policySection(title: "6. Xử lý dữ liệu AI (AI Data Processing)", content: "Để phân tích hành vi lái xe, ứng dụng gửi các tệp video được chọn đến máy chủ AI bảo mật của chúng tôi (adas-api.aiotlab.edu.vn). Dữ liệu này chỉ được sử dụng cho mục đích phân tích kỹ thuật và không được chia sẻ với các nhà quảng cáo.")
                        }
                        
                        // Bottom marker to detect scroll
                        Color.clear
                            .frame(height: 1)
                            .onAppear {
                                hasScrolledToBottom = true
                            }
                        
                        Divider()
                            .padding(.vertical, 10)
                        
                        // Agreement Checkbox
                        Button(action: {
                            if hasScrolledToBottom {
                                isAgreed.toggle()
                            }
                        }) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: isAgreed ? "checkmark.square.fill" : "square")
                                    .font(.system(size: 22))
                                    .foregroundColor(isAgreed ? theme.accentOrange : (hasScrolledToBottom ? theme.secondaryText : theme.tertiaryText))
                                
                                Text("Tôi đã đọc và đồng ý với các điều khoản trong Chính sách bảo mật này.")
                                    .font(.system(size: 14))
                                    .foregroundColor(hasScrolledToBottom ? theme.primaryText : theme.tertiaryText)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .disabled(!hasScrolledToBottom)
                        .padding(.vertical, 8)
                        
                        if !hasScrolledToBottom {
                            Text("Vui lòng lướt xuống dưới cùng để tiếp tục")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(theme.accentOrange)
                                .transition(.opacity)
                        }
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Đồng ý & Tiếp tục")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill((hasScrolledToBottom && isAgreed) ? theme.accentOrange : theme.tertiaryText)
                                )
                        }
                        .disabled(!(hasScrolledToBottom && isAgreed))
                        .padding(.top, 10)
                        
                        Text("Cập nhật lần cuối: 07/03/2026")
                            .font(.system(size: 12))
                            .foregroundColor(theme.secondaryText)
                            .padding(.top, 20)
                    }
                    .padding(24)
                }
            }
            .interactiveDismissDisabled(!(hasScrolledToBottom && isAgreed))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if hasScrolledToBottom && isAgreed {
                        Button("Đóng") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(theme.accentOrange)
                    }
                }
            }
        }
    }
    
    private func policySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(theme.primaryText)
            
            Text(content)
                .font(.system(size: 15))
                .foregroundColor(theme.secondaryText)
                .lineSpacing(5)
        }
    }
}

#Preview {
    PrivacyPolicyView()
        .environmentObject(ThemeManager())
}
