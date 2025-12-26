//
//  ScanDocumentIntent.swift
//  DocuSnapAI
//
//  Created by Leonardo Solís on 26/12/25.
//

import AppIntents
import SwiftUI

struct ScanDocumentIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Scan Document"
    
    static var description = IntentDescription("Scan a new document.")
    
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        AppNavigationManager.shared.shouldOpenScanner = true
        return .result()
    }
}
