import SwiftUI

struct SidebarTreeView: View {
    @EnvironmentObject var navigationState: NavigationState
    @State private var rootNodes: [FileNode] = []
    
    // We only keep ONE root, or if user can select multiple roots, we can use an array
    // Right now, when currentFolder changes, if there are no root nodes, we make currentFolder root.
    
    var body: some View {
        List {
            if let root = navigationState.workspaceRoot {
                let initialRoot = FileNode(url: root)
                RecursiveOutlineNode(node: initialRoot)
            } else {
                Text("Please select a workspace folder from the Top Bar")
                    .foregroundColor(.secondary)
            }
        }
        .listStyle(.sidebar)
    }
}

struct RecursiveOutlineNode: View {
    @ObservedObject var node: FileNode
    @EnvironmentObject var navigationState: NavigationState
    @State private var isExpanded: Bool = false
    
    var body: some View {
        if node.isDirectory {
            DisclosureGroup(isExpanded: $isExpanded) {
                if isExpanded {
                    if let children = node.children {
                        // Display only folders for left sidebar
                        ForEach(children.filter { $0.isDirectory }) { child in
                            RecursiveOutlineNode(node: child)
                        }
                    } else {
                        ProgressView().scaleEffect(0.5)
                            .task {
                                if node.children == nil {
                                    node.loadChildren()
                                }
                            }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "folder.fill")
                        .foregroundColor(.blue)
                    Text(node.name)
                        .lineLimit(1)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    print("Navigating to \(node.url)")
                    navigationState.navigate(to: node.url)
                }
            }
        } else {
            // we do not show files in left panel
            EmptyView()
        }
    }
}
