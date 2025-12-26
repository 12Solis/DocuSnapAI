//
//  DetailImageView.swift
//  DocuSnapAI
//
//  Created by Leonardo Solís on 26/12/25.
//

import SwiftUI

struct DetailImageView: View {
    let imagePath: String
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .listRowInsets(EdgeInsets())
                    .frame(maxHeight: 350)
                    .transition(.opacity)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 350)
                    .overlay {
                        ProgressView()
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
    DetailImageView(imagePath: "")
}
