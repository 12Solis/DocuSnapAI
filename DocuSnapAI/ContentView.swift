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
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    @ObservedObject var navManager = AppNavigationManager.shared
    
    @Query(sort: \Tag.name) var allTags : [Tag]
    
    
    @State private var isShowingScanner = false
    
    @State private var searchText = ""
    @State private var selectedTag : Tag?
    
    @State private var isShowingPhotoPicker = false
    @State private var selectedPickerItems: [PhotosPickerItem] = []
    
    @State private var isShowingTagManager = false
    
    var body: some View {
        NavigationStack {
            if !allTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Button {
                            withAnimation { selectedTag = nil }
                        } label: {
                            Text("All")
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedTag == nil ? Color.blue : Color.gray.opacity(0.1))
                                .foregroundStyle(selectedTag == nil ? .white : .primary)
                                .clipShape(Capsule())
                        }
                        ForEach(allTags) { tag in
                            Button {
                                withAnimation { selectedTag = tag }
                            } label: {
                                Text(tag.name)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedTag == tag ? Color.blue : Color.gray.opacity(0.1))
                                    .foregroundStyle(selectedTag == tag ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                        }
                        Rectangle()
                            .fill(.gray.opacity(0.3))
                            .frame(width: 1, height: 20)
                            .padding(.horizontal, 4)
                        
                        Button {
                            isShowingTagManager = true
                        } label: {
                            Label("Manage", systemImage: "gearshape")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.1))
                                .foregroundStyle(.primary)
                                .clipShape(Capsule())
                        }
                    }
                    .padding()
                }
            }
            VStack{
                
                DocumentListView(filterString: searchText, tagSelected: selectedTag)
            }
                .navigationTitle("DocuSnapAI")
                .searchable(text: $searchText, prompt: "Search title or text...")
                .onChange(of: navManager.shouldOpenScanner) { _, newValue in
                    if newValue {
                        isShowingScanner = true
                        navManager.shouldOpenScanner = false
                    }
                }
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
                .sheet(isPresented: $isShowingTagManager) {
                    TagManagerView()
                        .presentationDetents([.medium, .large])
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
        .fullScreenCover(isPresented: Binding(
            get: { !hasSeenOnboarding },
            set: { hasSeenOnboarding = !$0 }
        )) {
            OnboardingView(isPresented: Binding(
                get: { true },
                set: { _ in hasSeenOnboarding = true }
            ))
        }
    }
    
    
}


#Preview {
    ContentView()
}
