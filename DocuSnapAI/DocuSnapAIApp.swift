//
//  DocuSnapAIApp.swift
//  DocuSnapAI
//
//  Created by Leonardo Solís on 24/12/25.
//

import SwiftUI
import SwiftData

@main
struct DocuSnapAIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [ScannedDocument.self, Tag.self])
    }
}
