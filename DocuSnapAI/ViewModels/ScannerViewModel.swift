//
//  ScannerViewModel.swift
//  DocuSnapAI
//
//  Created by Leonardo Solís on 24/12/25.
//

import Combine
import SwiftData
import VisionKit

@MainActor
class ScannerViewModel: ObservableObject {
    private let ocrService = OCRService()
    
    
    @Published var isProcessing = false
    
    func processScan(scan: VNDocumentCameraScan, context: ModelContext) async {
        self.isProcessing = true
        
        
        let pageCount = scan.pageCount
        
        
        var results: [(imagePath: String, text: String, pdfPath: String)] = []
        
        
        await withTaskGroup(of: (String, String, String)?.self) { group in
            for i in 0 ..< pageCount {
                let image = scan.imageOfPage(at: i)
                
                group.addTask {
                    
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
                title: "Scan \(Date().formatted(date: .omitted, time: .shortened))",
                extractedText: result.text,
                imagePath: result.imagePath,
                pdfPath: result.pdfPath
            )
            context.insert(newDoc)
        }
        
        do {
            try context.save()
        } catch {
            print("Error guardando el contexto: \(error)")
        }
        
        self.isProcessing = false
        print("Processing complete. Saved \(results.count) documents.")
    }
}
