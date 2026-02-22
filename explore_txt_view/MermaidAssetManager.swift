import Foundation
import Combine

class MermaidAssetManager {
    static let shared = MermaidAssetManager()
    
    private let markedCacheURL: URL
    private let mermaidCacheURL: URL
    
    private let markedCDN = "https://cdn.jsdelivr.net/npm/marked/marked.min.js"
    private let mermaidCDN = "https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"
    
    private var hasCheckedForUpdates = false
    
    let appCacheDir: URL
    
    init() {
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        appCacheDir = cacheDir.appendingPathComponent("explore_txt_view", isDirectory: true)
        if !FileManager.default.fileExists(atPath: appCacheDir.path) {
            try? FileManager.default.createDirectory(at: appCacheDir, withIntermediateDirectories: true)
        }
        markedCacheURL = appCacheDir.appendingPathComponent("marked.min.js")
        mermaidCacheURL = appCacheDir.appendingPathComponent("mermaid.min.js")
    }
    
    func getMarkedScriptTag() -> String {
        return getOrFetchScriptURL(cacheURL: markedCacheURL, bundleName: "marked_min", cdnURL: markedCDN)
    }
    
    func getMermaidScriptTag() -> String {
        return getOrFetchScriptURL(cacheURL: mermaidCacheURL, bundleName: "mermaid_min", cdnURL: mermaidCDN)
    }
    
    private func getOrFetchScriptURL(cacheURL: URL, bundleName: String, cdnURL: String) -> String {
        // 1. Check local Caches (offline fast path or previously updated)
        if FileManager.default.fileExists(atPath: cacheURL.path),
           let scriptText = try? String(contentsOf: cacheURL, encoding: .utf8) {
            updateAssetInBackground(url: URL(string: cdnURL)!, to: cacheURL)
            let safeText = scriptText.replacingOccurrences(of: "</script>", with: "<\\/script>")
            return "<script>\n\(safeText)\n</script>"
        }
        
        // 2. Check App Bundle (initial offline fallback)
        if let bundleURL = Bundle.main.url(forResource: bundleName, withExtension: "txt"),
           let scriptText = try? String(contentsOf: bundleURL, encoding: .utf8) {
            try? FileManager.default.copyItem(at: bundleURL, to: cacheURL)
            updateAssetInBackground(url: URL(string: cdnURL)!, to: cacheURL)
            let safeText = scriptText.replacingOccurrences(of: "</script>", with: "<\\/script>")
            return "<script>\n\(safeText)\n</script>"
        }
        
        // 3. Complete Fallback: First launch without internet OR app wasn't bundled correctly
        updateAssetInBackground(url: URL(string: cdnURL)!, to: cacheURL)
        return "<script src=\"\(cdnURL)\"></script>"
    }
    
    private func updateAssetInBackground(url: URL, to destination: URL) {
        if hasCheckedForUpdates { return }
        hasCheckedForUpdates = true
        
        URLSession.shared.downloadTask(with: url) { tempURL, _, error in
            guard let tempURL = tempURL, error == nil else { return }
            _ = try? FileManager.default.removeItem(at: destination)
            _ = try? FileManager.default.moveItem(at: tempURL, to: destination)
        }.resume()
    }
}
