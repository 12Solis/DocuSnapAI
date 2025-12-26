//
//  DocuSnapAIApp.swift
//  DocuSnapAI
//
//  Created by Leonardo Solís on 24/12/25.
//

import SwiftUI
import SwiftData
import TipKit

@main
struct DocuSnapAIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    try? Tips.configure([
                        .datastoreLocation(.applicationDefault)
                    ])
                }
        }
        .modelContainer(for: [ScannedDocument.self, Tag.self])
    }
}
