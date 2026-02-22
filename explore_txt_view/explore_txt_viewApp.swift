import SwiftUI

@main
struct explore_txt_viewApp: App {
    @StateObject private var navigationState = NavigationState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navigationState)
        }
    }
}
