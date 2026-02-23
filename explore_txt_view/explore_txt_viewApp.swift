import SwiftUI
import WebKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillTerminate(_ notification: Notification) {
        // Because we configured the WKWebView to use a .nonPersistent() data store,
        // no cache is written to disk anyway, so we don't need to manually purge it.
        // We call exit(0) to bypass the noisy, harmless XPCConnectionTerminationWatchdog
        // logs when Apple's RunningBoard Services tries to clean up the WebKit daemon processes.
        exit(0)
    }
}

@main
struct explore_txt_viewApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var navigationState = NavigationState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navigationState)
        }
    }
}
