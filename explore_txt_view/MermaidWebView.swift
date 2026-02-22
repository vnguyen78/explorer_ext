import SwiftUI
import WebKit

struct MermaidWebView: NSViewRepresentable {
    let markdown: String
    
    func makeNSView(context: Context) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        
        // Safety check for Private API keys
        if configuration.preferences.responds(to: NSSelectorFromString("setAllowFileAccessFromFileURLs:")) {
            configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        }
        if configuration.preferences.responds(to: NSSelectorFromString("setAllowUniversalAccessFromFileURLs:")) {
            configuration.preferences.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        }
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        // Set background to transparent to match dark/light mode
        if webView.responds(to: NSSelectorFromString("setDrawsBackground:")) {
            webView.setValue(false, forKey: "drawsBackground")
        }
        
        if #available(macOS 13.3, *) {
            webView.isInspectable = true
        }
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        let markedScript = MermaidAssetManager.shared.getMarkedScriptTag()
        let mermaidScript = MermaidAssetManager.shared.getMermaidScriptTag()
        
        let htmlContent = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style>
                @media (prefers-color-scheme: dark) {
                    body {
                        background-color: transparent;
                        color: #E2E8F0;
                        font-family: -apple-system, system-ui, sans-serif;
                    }
                }
                @media (prefers-color-scheme: light) {
                    body {
                        background-color: transparent;
                        color: #333333;
                        font-family: -apple-system, system-ui, sans-serif;
                    }
                }
                .content { 
                    padding: 20px; 
                    line-height: 1.6;
                }
                pre {
                    background: rgba(128, 128, 128, 0.1);
                    padding: 15px;
                    border-radius: 8px;
                    overflow-x: auto;
                }
                .mermaid {
                    display: flex;
                    justify-content: center;
                    margin: 20px 0;
                    background: white; /* Force white background for legible diagrams even in dark mode */
                    padding: 20px;
                    border-radius: 10px;
                }
            </style>
            \(markedScript)
            \(mermaidScript)
            <script>
                function logError(msg, err) {
                    const errDiv = document.createElement('div');
                    errDiv.style.color = 'red';
                    errDiv.style.background = '#ffebee';
                    errDiv.style.padding = '10px';
                    errDiv.style.margin = '10px';
                    errDiv.innerText = msg + "\\n" + (err ? err.toString() : '');
                    document.body.prepend(errDiv);
                }

                try {
                    mermaid.initialize({ startOnLoad: false, theme: 'default' });
                } catch(e) { logError("mermaid init error", e); }
                
                window.renderMarkdown = async function(md) {
                    try {
                        const renderer = new marked.Renderer();
                        // Override the code block renderer (supports both marked v11+ and old API)
                        renderer.code = function(code, language) {
                            if (typeof code === 'object') {
                                language = code.lang;
                                code = code.text;
                            }
                            if (language === 'mermaid') {
                                // Return the raw, unescaped code inside a mermaid div
                                return '<div class="mermaid">' + code + '</div>';
                            }
                            // Default behavior for other languages (safely escape HTML)
                            const escapedCode = code.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
                            return '<pre><code class="language-' + language + '">' + escapedCode + '</code></pre>';
                        };
                        
                        // Parse using the custom renderer
                        document.getElementById('content').innerHTML = marked.parse(md, { renderer: renderer });
                    } catch (e) { logError('marked parse error:', e); return; }
                    
                    try {
                        // Tell mermaid to render all div.mermaid elements
                        await mermaid.run({ querySelector: '.mermaid' });
                    } catch (error) { logError('Mermaid rendering failed:', error); }
                }
            </script>
        </head>
        <body>
            <div id="content" class="content"></div>
            <script>
                // We encode the string to safely pass it down without breaking syntax
                try {
                    const rawMarkdown = decodeURIComponent(`\(markdown.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")`);
                    // Wait for components to be ready
                    let checkAttempts = 0;
                    const checkAndRender = () => {
                        if (window.renderMarkdown) {
                             window.renderMarkdown(rawMarkdown);
                        } else if (checkAttempts < 50) {
                             checkAttempts++;
                             setTimeout(checkAndRender, 50);
                        } else {
                             logError("window.renderMarkdown never became available.", "");
                        }
                    };
                    setTimeout(checkAndRender, 50);
                } catch(e) { logError("Decoded markdown error", e); }
            </script>
        </body>
        </html>
        """
        let baseURL = MermaidAssetManager.shared.appCacheDir
        webView.loadHTMLString(htmlContent, baseURL: baseURL)
    }
}
