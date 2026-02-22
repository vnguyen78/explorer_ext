import SwiftUI

struct DirectoryContentView: View {
    @EnvironmentObject var navigationState: NavigationState
    @State private var children: [FileNode] = []
    @Binding var selectedFile: URL?
    @State private var showingNoAppAlert = false
    @State private var alertFileName = ""
    
    var body: some View {
        List(selection: $selectedFile) {
            if children.isEmpty {
                Text("Folder is empty")
                    .foregroundColor(.secondary)
            } else {
                ForEach(children, id: \.url) { child in
                    HStack {
                        Image(systemName: child.isDirectory ? "folder.fill" : fileIcon(for: child.name))
                            .foregroundColor(child.isDirectory ? .blue : .primary)
                        Text(child.name)
                            .lineLimit(1)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture(count: 2) {
                        if !child.isDirectory {
                            openExternalApp(url: child.url)
                        }
                    }
                    .onTapGesture {
                        if child.isDirectory {
                            navigationState.navigate(to: child.url)
                        } else {
                            selectedFile = child.url
                        }
                    }
                    .padding(.vertical, 2)
                    // Visual indication of selection
                    .background(selectedFile == child.url ? Color.accentColor.opacity(0.2) : Color.clear)
                    .cornerRadius(4)
                }
            }
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
        .onAppear { loadCurrentFolder() }
        .onChange(of: navigationState.currentFolder) { _, _ in loadCurrentFolder() }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("directoryContentsDidUpdate"))) { _ in
            loadCurrentFolder()
        }
        .alert(isPresented: $showingNoAppAlert) {
            Alert(
                title: Text("No Application Found"),
                message: Text("There is no default application available to open '\(alertFileName)'."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func loadCurrentFolder() {
        guard let current = navigationState.currentFolder else {
            children = []
            return
        }
        let node = FileNode(url: current)
        DispatchQueue.global(qos: .userInitiated).async {
            let fetched = node.fetchChildren()
            DispatchQueue.main.async {
                self.children = fetched
            }
        }
    }
    
    func fileIcon(for name: String) -> String {
        let ext = (name as NSString).pathExtension.lowercased()
        switch ext {
        case "txt", "md": return "doc.text"
        case "py": return "curlybraces.square"
        case "swift": return "swift"
        case "pdf": return "doc.richtext"
        case "png", "jpg", "jpeg", "gif": return "photo"
        default: return "doc"
        }
    }
    
    func openExternalApp(url: URL) {
        if NSWorkspace.shared.urlForApplication(toOpen: url) != nil {
            NSWorkspace.shared.open(url)
        } else {
            alertFileName = url.lastPathComponent
            showingNoAppAlert = true
        }
    }
}
