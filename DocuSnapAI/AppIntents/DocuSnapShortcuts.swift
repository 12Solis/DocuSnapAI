//
//  DocuSnapShortcuts.swift
//  DocuSnapAI
//
//  Created by Leonardo Solís on 26/12/25.
//

import AppIntents

struct DocuSnapShortcuts: AppShortcutsProvider {
    
    static var shortcutTileColor: ShortcutTileColor = .teal
    
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ScanDocumentIntent(),
            phrases: [
                "Scan a document with \(.applicationName)",
                "New scan in \(.applicationName)",
                "Start scanner in \(.applicationName)"
            ],
            shortTitle: "Scan Document",
            systemImageName: "doc.viewfinder"
        )
    }
}
