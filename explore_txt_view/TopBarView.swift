import SwiftUI

struct TopBarView: View {
    @EnvironmentObject var navigationState: NavigationState
    
    var body: some View {
        HStack {
            Button(action: { navigationState.goBack() }) {
                Image(systemName: "chevron.left")
            }
            .disabled(!navigationState.canGoBack)
            
            Button(action: { navigationState.goForward() }) {
                Image(systemName: "chevron.right")
            }
            .disabled(!navigationState.canGoForward)
            
            Button(action: { navigationState.goUp() }) {
                Image(systemName: "arrow.up")
            }
            .disabled(!navigationState.canGoUp)
            
            // Breadcrumbs inside a scrolling frame or geometry reader
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    if let folder = navigationState.currentFolder {
                        let pathComponents = folder.pathComponents
                        ForEach(Array(pathComponents.enumerated()), id: \.offset) { index, component in
                            Text(component == "/" ? "Mac" : component)
                                .font(.system(size: 13, weight: .semibold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(4)
                                .onTapGesture {
                                    // Jump to intermediate folder
                                    let subpathComponents = pathComponents.prefix(index + 1)
                                    let pathStr = subpathComponents.joined(separator: "/").replacingOccurrences(of: "//", with: "/")
                                    if pathStr.isEmpty {
                                        navigationState.navigate(to: URL(fileURLWithPath: "/"))
                                    } else {
                                        navigationState.navigate(to: URL(fileURLWithPath: pathStr.hasPrefix("/") ? pathStr : "/" + pathStr))
                                    }
                                }
                            if index < pathComponents.count - 1 {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else {
                        Text("No Workspace Selected")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Button("Open Root Folder") {
                let panel = NSOpenPanel()
                panel.canChooseDirectories = true
                panel.canChooseFiles = false
                panel.allowsMultipleSelection = false
                if panel.runModal() == .OK, let url = panel.url {
                    navigationState.navigate(to: url)
                }
            }
        }
        .padding(8)
        .background(Color(NSColor.windowBackgroundColor))
        // Shadow for depth
        .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}
