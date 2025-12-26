//
//  TagManagerView.swift
//  DocuSnapAI
//
//  Created by Leonardo Solís on 25/12/25.
//

import SwiftUI
import SwiftData

struct TagManagerView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Tag.name) var tags: [Tag]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(tags) { tag in
                    Text(tag.name)
                        .font(.body)
                }
                .onDelete(perform: deleteTags)
            }
            .navigationTitle("Manage Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
            .overlay {
                if tags.isEmpty {
                    ContentUnavailableView("No Tags Created", systemImage: "tag.slash")
                }
            }
        }
    }
    
    private func deleteTags(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let tag = tags[index]
                modelContext.delete(tag)
            }
        }
    }
}

#Preview {
    TagManagerView()
}
