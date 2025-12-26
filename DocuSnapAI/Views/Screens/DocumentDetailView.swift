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
    
    @Query(sort: \Tag.name) var allTags : [Tag]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingTagPicker = false
    @State private var newTagName = ""
    
    var body: some View {
        if document.isPrivate{
            if authenticationManager.isAuthenticated {
                detailContent
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
            detailContent
        }
    }
    
    
    var detailContent: some View {
        Form{
            //Image
            Section{
                DetailImageView(imagePath: document.imagePath)
            }
            .listRowBackground(Color.clear)
            
            //Tags
            Section("Tags") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(document.tags ?? []) { tag in
                            HStack {
                                Text("#\(tag.name)")
                                    .font(.caption)
                                    .bold()
                                Button {
                                    if let index = document.tags?.firstIndex(of: tag) {
                                        document.tags?.remove(at: index)
                                    }
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.caption2)
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.blue.opacity(0.1))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                        }

                        Menu {
                            Button {
                                showingTagPicker = true
                            } label: {
                                Label("Create New Tag", systemImage: "plus")
                            }
                                        
                            Divider()

                            ForEach(allTags) { tag in
                                if !(document.tags?.contains(tag) ?? false) {
                                    Button(tag.name) {
                                        document.tags?.append(tag)
                                    }
                                }
                            }
                                        
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Tag")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .alert("New Tag", isPresented: $showingTagPicker) {
                TextField("Tag Name", text: $newTagName)
                Button("Cancel", role: .cancel) { newTagName = "" }
                Button("Create") {
                    addTag(name: newTagName)
                    newTagName = ""
                }
            }
            
            //Info
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
    
    private func addTag(name: String) {
            let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !cleanedName.isEmpty else { return }
            
            if let existingTag = allTags.first(where: { $0.name.localizedCaseInsensitiveContains(cleanedName) }) {
                if !(document.tags?.contains(existingTag) ?? false) {
                    document.tags?.append(existingTag)
                }
            } else {
                let newTag = Tag(name: cleanedName)
                modelContext.insert(newTag)
                document.tags?.append(newTag)
            }
        }
    
}

    
    

#Preview {
    DocumentDetailView(document: ScannedDocument(title: "", extractedText: "", imagePath: "", pdfPath: ""))
}
