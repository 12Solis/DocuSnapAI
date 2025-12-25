//
//  DocumentDetailView.swift
//  DocuSnapAI
//
//  Created by Leonardo Solís on 24/12/25.
//

import SwiftUI
import SwiftData

struct DocumentDetailView: View {
    @Bindable var document: ScannedDocument
    
    var body: some View {
        Form{
            Section{
                if let image = ImagePersistenceService.loadImage(filename: document.imagePath){
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .listRowInsets(EdgeInsets())
                        .frame(maxHeight: 350)
                }else{
                    ContentUnavailableView("Image missing", systemImage: "photo.badge.exclamationmark")
                }
            }
            .listRowBackground(Color.clear)
            Section("Info") {
                TextField("Document Title", text: $document.title)
                    .font(.headline)
                    .autocorrectionDisabled()
                            
                LabeledContent("Date Scanned", value: document.date, format: .dateTime.year().month().day().hour().minute())
                    .foregroundStyle(.secondary)
            }
            Section("Extracted Text") {
                TextEditor(text: $document.extractedText)
                    .frame(minHeight: 200)
                    .font(.body)
            }
        }
        .navigationTitle("Document Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .topBarTrailing){
                Menu{
                    ShareLink(item: document.extractedText){
                        Label("Share Text", systemImage: "character.cursor.ibeam") //character.cursor.ibeam
                    }
                    
                    if let fileUrl = ImagePersistenceService.getFileURL(filename: document.imagePath){
                        ShareLink(item: fileUrl){
                            Label("Share Image", systemImage: "photo")
                        }
                    }
                    
                    if let pdfUrl = ImagePersistenceService.getFileURL(filename: document.pdfPath){
                        ShareLink(item: pdfUrl){
                            Label("Share PDF", systemImage: "doc.text")
                        }
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
}

#Preview {
    DocumentDetailView(document: ScannedDocument(title: "", extractedText: "", imagePath: "", pdfPath: ""))
}
