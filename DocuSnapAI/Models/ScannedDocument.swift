//
//  ScannedDocument.swift
//  DocuSnapAI
//
//  Created by Leonardo Solís on 24/12/25.
//

import Foundation
import SwiftData

@Model
class ScannedDocument {
    var id: UUID
    var title: String
    var extractedText: String
    var imagePath: String
    var date: Date
    var pdfPath: String
    
    init(title: String, extractedText: String, imagePath: String, pdfPath: String) {
        self.id = UUID()
        self.title = title
        self.extractedText = extractedText
        self.imagePath = imagePath
        self.date = Date()
        self.pdfPath = pdfPath
    }
}
