//
//  ContentView.swift
//  DocuSnapAI
//
//  Created by Leonardo Solís on 24/12/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \ScannedDocument.date, order: .reverse) var scannedDocs: [ScannedDocument]
    
    @StateObject var viewModel = ScannerViewModel()
    
    @State private var isShowingScanner = false
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            DocumentListView(filterString: searchText)
                .navigationTitle("DocuSnap")
                .searchable(text: $searchText, prompt: "Search title or text...")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        if viewModel.isProcessing {
                            ProgressView()
                        } else {
                            Button {
                                isShowingScanner = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                            }
                        }
                    }
                }
            .sheet(isPresented: $isShowingScanner) {
                CameraView { scan in
                    Task {
                        await viewModel.processScan(scan: scan, context: modelContext)
                        isShowingScanner = false
                    }
                } onCancel: {
                    isShowingScanner = false
                }
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            let doc = scannedDocs[index]
            ImagePersistenceService.deleteImage(filename: doc.imagePath)
            modelContext.delete(doc)
        }
    }
    
    
}

#Preview {
    ContentView()
}
