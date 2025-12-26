//
//  DocumentThumbnail.swift
//  DocuSnapAI
//
//  Created by Leonardo Solís on 26/12/25.
//

import SwiftUI

struct DocumentThumbnail: View {
    let imagePath: String
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .transition(.opacity)
            } else {
                Rectangle()
                    .fill(.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
                    .overlay {
                        ProgressView()
                            .scaleEffect(0.5)
                    }
            }
        }
        .task(id: imagePath) {
            if let loadedImage = await ImagePersistenceService.loadImageAsync(filename: imagePath) {
                withAnimation {
                    self.image = loadedImage
                }
            }
        }
    }
}

#Preview {
    DocumentThumbnail(imagePath: "")
}
