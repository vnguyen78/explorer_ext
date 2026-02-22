import SwiftUI
import Combine

class NavigationState: ObservableObject {
    @Published var workspaceRoot: URL?
    @Published var currentFolder: URL?
    @Published var history: [URL] = []
    @Published var historyIndex: Int = -1
    
    init() {
        let homeURL = FileManager.default.homeDirectoryForCurrentUser
        history.append(homeURL)
        historyIndex = 0
        currentFolder = homeURL
        workspaceRoot = homeURL
    }
    
    var canGoBack: Bool {
        historyIndex > 0
    }
    
    var canGoForward: Bool {
        historyIndex < history.count - 1
    }
    
    var canGoUp: Bool {
        guard let current = currentFolder else { return false }
        return current.path != "/"
    }
    
    func navigate(to url: URL) {
        if let current = currentFolder, current == url {
            return // Already there
        }
        
        // If we navigate somewhere new while not at the end of history,
        // we discard the "forward" history.
        if historyIndex >= 0 && historyIndex < history.count - 1 {
            history.removeSubrange((historyIndex + 1)...)
        }
        
        history.append(url)
        historyIndex = history.count - 1
        currentFolder = url
    }
    
    func goBack() {
        guard canGoBack else { return }
        historyIndex -= 1
        currentFolder = history[historyIndex]
    }
    
    func goForward() {
        guard canGoForward else { return }
        historyIndex += 1
        currentFolder = history[historyIndex]
    }
    
    func goUp() {
        guard canGoUp, let current = currentFolder else { return }
        let parent = current.deletingLastPathComponent()
        navigate(to: parent)
    }
}
