# Explorer Ext (Explore Txt View)

A native macOS application built with SwiftUI that serves as a file explorer and text viewer. It features a modern split-pane interface with a directory tree on the left and a content viewer on the right.

## Features

- **Split View Interface:** Navigate your file system easily with a resizable sidebar.
- **Text Editor:** View and edit plain text code files with syntax highlighting support.
- **Live Markdown Preview:** Supports rendering standard Markdown files (`.md`).
- **Mermaid Diagram Support:** Natively parses and renders [Mermaid](https://mermaid.js.org/) diagrams (like sequence diagrams, flowcharts, etc.) embedded inside your Markdown files beautifully using a custom WebKit integration.
- **QuickLook Integration:** Quickly preview supported image and PDF formats.

## How it works (Mermaid Rendering)
The application leverages a `WKWebView` to render Markdown. It uses the `marked.js` library with a custom code block renderer to safely extract ````mermaid` blocks, decoding any HTML entities before passing the raw text to the local `mermaid.min.js` rendering engine. By injecting the scripts directly into the HTML string, it bypasses strict macOS App Sandbox local-file restrictions without compromising the system.

## Requirements
- macOS 14.0+
- Xcode 15+ (for building from source)
