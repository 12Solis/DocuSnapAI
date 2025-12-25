//
//  OCRService.swift
//  DocuSnapAI
//
//  Created by Leonardo Solís on 24/12/25.
//

import Vision
import UIKit

class OCRService {
    func recognizeText(from image: UIImage) async throws -> String {

        return try await Task.detached(priority: .userInitiated) {
            guard let cgImage = image.cgImage else { return "" }
            
            return try await withCheckedThrowingContinuation { continuation in
                let request = VNRecognizeTextRequest { request, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let observations = request.results as? [VNRecognizedTextObservation] else {
                        continuation.resume(returning: "")
                        return
                    }
                    
                    let text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
                    continuation.resume(returning: text)
                }
                
                request.recognitionLevel = .accurate
                
                do {
                    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }.value
    }
}
