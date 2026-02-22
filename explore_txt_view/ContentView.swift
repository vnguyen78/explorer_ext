import SwiftUI
import QuickLookUI

struct ContentView: View {
    @EnvironmentObject var navigationState: NavigationState
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var selectedFile: URL?
    @State private var fileContent: String = ""
    @State private var hasModifications: Bool = false
    @State private var showingQuickLook: Bool = false
    @State private var fileNotSupported: Bool = false
    @State private var showMarkdownPreview: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            TopBarView()
            
            NavigationSplitView(columnVisibility: $columnVisibility) {
                SidebarTreeView()
                    .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 400)
            } content: {
                DirectoryContentView(selectedFile: $selectedFile)
                    .navigationSplitViewColumnWidth(min: 250, ideal: 300, max: 500)
            } detail: {
                if let file = selectedFile {
                    VStack(spacing: 0) {
                        HStack {
                            Text(file.lastPathComponent)
                                .font(.headline)
                            if hasModifications {
                                Text("(Modified)")
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button("Save") {
                                saveFile()
                            }
                            .disabled(!hasModifications)
                            
                            Button("Save As...") {
                                saveAsFile()
                            }
                            
                            if file.pathExtension.lowercased() == "md" {
                                Divider()
                                    .frame(height: 16)
                                    .padding(.horizontal, 4)
                                
                                Picker("", selection: $showMarkdownPreview) {
                                    Image(systemName: "doc.plaintext").tag(false)
                                    Image(systemName: "eye").tag(true)
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 70)
                                .help("Toggle Diagram Preview")
                            }
                        }
                        .padding()
                        .frame(height: 50)
                        .background(Color(NSColor.controlBackgroundColor))
                        
                        Divider()
                        
                        if fileNotSupported {
                            VStack {
                                Image(systemName: "xmark.octagon")
                                    .font(.system(size: 60))
                                    .foregroundColor(.secondary)
                                    .padding(.bottom, 8)
                                Text("File Not Supported")
                                    .font(.headline)
                                Text("This file type cannot be opened or previewed.")
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if showingQuickLook {
                            QuickLookPreview(url: file)
                                .id(file.absoluteString)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if showMarkdownPreview && file.pathExtension.lowercased() == "md" {
                            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                                Text("Mermaid JS Preview is disabled in the Xcode Canvas.")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else {
                                MermaidWebView(markdown: fileContent)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        } else {
                            SyntaxEditorDetailView(
                                text: Binding(
                                    get: { fileContent },
                                    set: { newValue in
                                        if fileContent != newValue {
                                            fileContent = newValue
                                            hasModifications = true
                                        }
                                    }
                                ),
                                fileExtension: file.pathExtension.lowercased()
                            )
                        }
                    }
                } else {
                    Text("Select a file to view")
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .onChange(of: selectedFile) { oldFile, newFile in
            loadFile(url: newFile)
        }
        .onChange(of: navigationState.currentFolder) { _, _ in
            selectedFile = nil
        }
    }
    
    private func loadFile(url: URL?) {
        guard let url = url else {
            fileContent = ""
            hasModifications = false
            showingQuickLook = false
            fileNotSupported = false
            return
        }
        
        let ext = url.pathExtension.lowercased()
        let quickLookSupported = ["png", "jpg", "jpeg", "gif", "pdf", "heic", "bmp", "tiff", "svg"]
        let explicitlyUnsupported = ["docx", "doc", "xlsx", "xls", "pptx", "ppt", "zip", "tar", "gz", "rar", "7z", "dmg", "app", "exe", "bin"]

        if explicitlyUnsupported.contains(ext) {
            fileContent = ""
            hasModifications = false
            showingQuickLook = false
            fileNotSupported = true
            return
        }

        if quickLookSupported.contains(ext) {
            fileContent = ""
            hasModifications = false
            showingQuickLook = true
            fileNotSupported = false
            return
        }

        do {
            fileContent = try String(contentsOf: url, encoding: .utf8)
            hasModifications = false
            showingQuickLook = false
            fileNotSupported = false
        } catch {
            fileContent = ""
            hasModifications = false
            showingQuickLook = false
            fileNotSupported = true
        }
    }
    
    private func saveFile() {
        guard let url = selectedFile else { return }
        do {
            try fileContent.write(to: url, atomically: true, encoding: .utf8)
            hasModifications = false
        } catch {
            print("Failed to save: \(error)")
        }
    }
    
    private func saveAsFile() {
        let panel = NSSavePanel()
        if let current = selectedFile {
            panel.nameFieldStringValue = current.lastPathComponent
        } else {
            panel.nameFieldStringValue = "Untitled.txt"
        }
        
        if panel.runModal() == .OK, let url = panel.url {
            do {
                try fileContent.write(to: url, atomically: true, encoding: .utf8)
                selectedFile = url
                hasModifications = false
                NotificationCenter.default.post(name: .directoryContentsDidUpdate, object: nil)
            } catch {
                print("Failed to save as: \(error)")
            }
        }
    }
}

public extension Notification.Name {
    static let directoryContentsDidUpdate = Notification.Name("directoryContentsDidUpdate")
}

#Preview {
    ContentView().environmentObject(NavigationState())
}

struct QuickLookPreview: NSViewRepresentable {
    let url: URL
    
    func makeNSView(context: Context) -> QLPreviewView {
        let view = QLPreviewView()
        view.autostarts = true
        return view
    }
    
    func updateNSView(_ nsView: QLPreviewView, context: Context) {
        if nsView.previewItem?.previewItemURL != url {
            nsView.previewItem = url as QLPreviewItem
        }
    }
    
    static func dismantleNSView(_ nsView: QLPreviewView, coordinator: ()) {
        nsView.previewItem = nil
    }
}
