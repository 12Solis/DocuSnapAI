//
//  ContentView.swift
//  DocuSnapAI
//
//  Created by Leonardo Solís on 24/12/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject var viewModel = ScannerViewModel()
    
    @Query(sort: \ScannedDocument.date, order: .reverse) var scannedDocs: [ScannedDocument]
    
    
    @State private var isShowingScanner = false
    
    @State private var searchText = ""
    
    @State private var isShowingPhotoPicker = false
    @State private var selectedPickerItems: [PhotosPickerItem] = []
    
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
                            Menu {
                                Button {
                                    isShowingScanner = true
                                } label: {
                                    Label("Scan Document", systemImage: "camera.viewfinder")
                                }

                                Button {
                                    isShowingPhotoPicker = true
                                } label: {
                                    Label("Import from Photos", systemImage: "photo.on.rectangle")
                                }
                                        
                                
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
            .photosPicker(
                isPresented: $isShowingPhotoPicker,
                selection: $selectedPickerItems,
                matching: .images,
                photoLibrary: .shared()
            )
            .onChange(of: selectedPickerItems) { _, newItems in
                if !newItems.isEmpty {
                    Task {
                        await viewModel.processPhotoPickerSelection(newItems, context: modelContext)
                        selectedPickerItems = []
                    }
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
