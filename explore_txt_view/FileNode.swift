import Foundation
import Combine
import SwiftUI

class FileNode: Identifiable, ObservableObject, Hashable {
    let id = UUID()
    let url: URL
    let name: String
    let isDirectory: Bool
    @Published var children: [FileNode]? = nil
    
    // Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
    
    static func == (lhs: FileNode, rhs: FileNode) -> Bool {
        lhs.url == rhs.url
    }
    
    init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
        
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
            self.isDirectory = isDir.boolValue
        } else {
            self.isDirectory = false
        }
    }
    
    func fetchChildren() -> [FileNode] {
        guard isDirectory else { return [] }
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])
            
            var loadedChildren = contents.map { FileNode(url: $0) }
            loadedChildren.sort { (node1, node2) -> Bool in
                if node1.isDirectory && !node2.isDirectory { return true }
                if !node1.isDirectory && node2.isDirectory { return false }
                return node1.name.localizedStandardCompare(node2.name) == .orderedAscending
            }
            return loadedChildren
        } catch {
            print("Error loading children for \(url): \(error)")
            return []
        }
    }
    
    func loadChildren() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let fetched = self.fetchChildren()
            DispatchQueue.main.async {
                self.children = fetched
            }
        }
    }
}
