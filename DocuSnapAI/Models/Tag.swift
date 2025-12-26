//
//  Tag.swift
//  DocuSnapAI
//
//  Created by Leonardo Solís on 25/12/25.
//

import Foundation
import SwiftData

@Model
class Tag {
    var name : String
    
    @Relationship(inverse: \ScannedDocument.tags)
    var  documents: [ScannedDocument]
    
    init(name: String) {
        self.name = name
        self.documents = []
    }
}
