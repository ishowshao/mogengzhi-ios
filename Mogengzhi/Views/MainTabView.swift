import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            MonthView()
                .tabItem {
                    Label("本月", systemImage: "calendar")
                }

            InboxView()
                .tabItem {
                    Label("Inbox", systemImage: "tray")
                }

            RetroView()
                .tabItem {
                    Label("复盘", systemImage: "doc.text.magnifyingglass")
                }

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppStore())
}
