//
//  explore_txt_viewApp.swift
//  explore_txt_view
//
//  Created by admin on 2/21/26.
//

import SwiftUI

@main
struct explore_txt_viewApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: explore_txt_viewDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
