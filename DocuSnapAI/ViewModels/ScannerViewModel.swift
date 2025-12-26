//
//  ScannerViewModel.swift
//  DocuSnapAI
//
//  Created by Leonardo Solís on 24/12/25.
//

import Combine
import SwiftData
import VisionKit
import PhotosUI
import SwiftUI

@MainActor
class ScannerViewModel: ObservableObject {
    private let ocrService = OCRService()
    
    
    @Published var isProcessing = false
    
    func processScan(scan: VNDocumentCameraScan, context: ModelContext) async {
        self.isProcessing = true
        
        var images: [UIImage] = []
        
        for i in 0..<scan.pageCount {
            images.append(scan.imageOfPage(at: i))
        }
        
        await processImages(images, context: context)
        
        self.isProcessing = false
    }
    
    func processPhotoPickerSelection(_ items: [PhotosPickerItem], context: ModelContext) async {
        self.isProcessing = true
        
        var images: [UIImage] = []
        
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                images.append(image)
            }
        }
        
        await processImages(images, context: context)
        
        self.isProcessing = false
    }
    
    private func processImages(_ images: [UIImage], context: ModelContext) async {
        var results: [(imagePath: String, text: String, pdfPath: String)] = []
        
        await withTaskGroup(of: (String,String,String)? .self){ group in
            for image in images {
                group.addTask{
                    guard let filename = await ImagePersistenceService.saveImage(image: image) else { return nil }
                                        
                    let ocr = await OCRService()
                    let text = (try? await ocr.recognizeText(from: image)) ?? ""
                                        
                    guard let pdfPath = await ImagePersistenceService.convertImageToPDF(image: image) else { return nil }
                                        
                    return (filename, text, pdfPath)
                }
            }
            
            for await result in group {
                if let validResult = result {
                    results.append(validResult)
                }
            }
            
        }
        
        for result in results {
            let newDoc = ScannedDocument(
                title: "Import \(Date().formatted(date: .omitted, time: .shortened))",
                extractedText: result.text,
                imagePath: result.imagePath,
                pdfPath: result.pdfPath
            )
            context.insert(newDoc)
        }
        
        try? context.save()
        print("Processed \(results.count) images.")
    }
    
    
}


