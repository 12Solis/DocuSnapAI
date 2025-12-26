//
//  DocumentListView.swift
//  DocuSnapAI
//
//  Created by Leonardo Solís on 25/12/25.
//

import SwiftUI
import SwiftData

struct DocumentListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var scannedDocs: [ScannedDocument]
    
    init(filterString: String){
        if filterString.isEmpty {
            _scannedDocs = Query(sort: \ScannedDocument.date, order: .reverse)
        } else {
            _scannedDocs = Query(
                    filter: #Predicate { doc in
                        doc.title.localizedStandardContains(filterString) ||
                        doc.extractedText.localizedStandardContains(filterString)
                    },
                    sort: \ScannedDocument.date,
                    order: .reverse
                )
        }
    }
    
    init(filterString: String, tagSelected: Tag?) {

            let sortDescriptors = [SortDescriptor(\ScannedDocument.date, order: .reverse)]
            
            if let tag = tagSelected {
                let tagName = tag.name
                
                if filterString.isEmpty {
                    _scannedDocs = Query(
                        filter: #Predicate { doc in
                            doc.tags?.contains { $0.name == tagName } == true
                        },
                        sort: sortDescriptors
                    )
                } else {
                    _scannedDocs = Query(
                        filter: #Predicate { doc in
                            doc.tags?.contains { $0.name == tagName } == true &&
                            (doc.title.localizedStandardContains(filterString) ||
                             doc.extractedText.localizedStandardContains(filterString))
                        },
                        sort: sortDescriptors
                    )
                }
            } else {
                if filterString.isEmpty {
                    _scannedDocs = Query(sort: sortDescriptors)
                } else {
                    _scannedDocs = Query(
                        filter: #Predicate { doc in
                            doc.title.localizedStandardContains(filterString) ||
                            doc.extractedText.localizedStandardContains(filterString)
                        },
                        sort: sortDescriptors
                    )
                }
            }
        }
    
    var body: some View {
        if scannedDocs.isEmpty {
            ContentUnavailableView(
                "No Documents",
                systemImage: "doc.viewfinder",
                description: Text("Tap the + button to scan your first document.")
            )
        } else {
            List{
                ForEach(scannedDocs){ doc in
                    NavigationLink(destination: DocumentDetailView(document: doc)) {
                        HStack {
                            if doc.isPrivate {
                                Image(systemName: "lock.document")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 50)
                                VStack(alignment: .leading){
                                    Text(doc.title)
                                        .font(.headline)
                                    Spacer()
                                }
                            }else{
                                DocumentThumbnail(imagePath: doc.imagePath)
                                VStack(alignment: .leading) {
                                    Text(doc.title)
                                        .font(.headline)
                                    Text(doc.extractedText)
                                        .font(.caption)
                                        .lineLimit(2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                        }
                    }
                    
                }
                .onDelete(perform: deleteItems)
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            let doc = scannedDocs[index]
            ImagePersistenceService.deleteImage(filename: doc.imagePath)
            ImagePersistenceService.deleteImage(filename: doc.pdfPath)
            modelContext.delete(doc)
        }
    }
}

#Preview {
    DocumentListView(filterString: "")
}
