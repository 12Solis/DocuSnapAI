//
//  DocumentDetailView.swift
//  DocuSnapAI
//
//  Created by Leonardo Solís on 24/12/25.
//

import SwiftUI
import SwiftData

struct DocumentDetailView: View {
    @StateObject private var authenticationManager = AuthenticationManager()
    @Bindable var document: ScannedDocument
    
    var body: some View {
        if document.isPrivate{
            if authenticationManager.isAuthenticated {
                DetailsView(document: document)
            } else {
                VStack {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.gray)
                        .font(.largeTitle)
                    Text("Use Face ID to see this document")
                        .font(Font.title3.bold())
                    Button("View Document") {
                        Task {
                            _ = await authenticationManager.authenticate()
                        }
                    }
                    .padding()
                }
                .ignoresSafeArea()
            }
        }else{
            DetailsView(document: document)
        }
    }
}

struct DetailsView: View{
    
    @Bindable var document: ScannedDocument
    @StateObject private var authenticationManager = AuthenticationManager()
    
    @State private var errorMessage = ""
    @State private var isShowingAlert = false
    
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
                HStack {
                    
                    Button {
                        Task {
                            if document.isPrivate {
                                let success = await authenticationManager.authenticate()
                                if success {
                                    document.isPrivate = false
                                }
                            } else {
                                document.isPrivate = true
                            }
                        }
                    } label: {
                        Image(systemName: document.isPrivate ? "lock.fill" : "lock.open.fill")
                            .foregroundStyle(document.isPrivate ? .red : .green)
                    }
                    
                    
                    Menu{
                        ShareLink(item: document.extractedText){
                            Label("Share Text", systemImage: "character.cursor.ibeam")
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
    
}

#Preview {
    DocumentDetailView(document: ScannedDocument(title: "", extractedText: "", imagePath: "", pdfPath: ""))
}
