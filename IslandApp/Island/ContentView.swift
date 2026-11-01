import SwiftUI

/// 主界面：四个功能页
struct ContentView: View {
    var body: some View {
        TabView {
            CodeTabView()
                .tabItem { Label("取餐码", systemImage: "number") }
            TimerTabView()
                .tabItem { Label("倒计时", systemImage: "timer") }
            TextTabView()
                .tabItem { Label("文字", systemImage: "textformat") }
            ReminderTabView()
                .tabItem { Label("提醒", systemImage: "bell") }
        }
        .task {
            // 首次打开请求通知权限（灵动岛也依赖它）
            _ = await NotificationManager.shared.requestAuthorization()
        }
    }
}
