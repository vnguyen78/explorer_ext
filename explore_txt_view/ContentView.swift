//
//  ContentView.swift
//  explore_txt_view
//
//  Created by admin on 2/21/26.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: explore_txt_viewDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

#Preview {
    ContentView(document: .constant(explore_txt_viewDocument()))
}
