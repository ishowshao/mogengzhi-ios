import SwiftUI

@main
struct MogengzhiApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(store)
        }
    }
}
