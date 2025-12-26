//
//  Tips.swift
//  DocuSnapAI
//
//  Created by Leonardo Solís on 26/12/25.
//

import Foundation
import TipKit

struct ScanDocumentTip: Tip {
    static let documentScannedEvent = Event(id: "documentScanned")
    static let contentViewVisitedEvent = Event(id: "contentViewVisited")
    
    var title: Text{
        Text("Scan a document")
            .foregroundStyle(.secondary)
    }
    var message: Text?{
        Text("Use the camera to scan a document or use the library to upload one")
    }
    var image: Image?{
        Image(systemName: "document.viewfinder")
    }
    
    var rules: [Rule] = [
        #Rule(Self.documentScannedEvent){event in
            event.donations.count == 0
        },
        #Rule(Self.contentViewVisitedEvent){event in
            event.donations.count > 1
        }
    ]
}
