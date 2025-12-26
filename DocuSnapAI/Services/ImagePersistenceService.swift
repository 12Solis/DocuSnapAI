//
//  PersistanceService.swift
//  DocuSnapAI
//
//  Created by Leonardo Solís on 24/12/25.
//

import Foundation
import UIKit

struct ImagePersistenceService {
    
    // MARK:  Save Image
    static func saveImage(image: UIImage) -> String? {
        let filename = UUID().uuidString + ".jpg"
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error: Could not find documents directory")
            return nil
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            print("Error: Could not convert image to data")
            return nil
        }
        
        do {
            try data.write(to: fileURL)
            print("Image saved successfully at: \(filename)")
            return filename
        } catch {
            print("Error saving image: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK:  Load Image
    static func loadImage(filename: String) -> UIImage? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            let data = try Data(contentsOf: fileURL)
            return UIImage(data: data)
        } catch {
            print("Error loading image: \(error.localizedDescription)")
            return nil
        }
    }
    static func loadImageAsync(filename: String) async -> UIImage? {
        return await Task.detached(priority: .userInitiated) {
            guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            
            do {
                let data = try Data(contentsOf: fileURL)
                return UIImage(data: data)
            } catch {
                return nil
            }
        }.value
    }
    
    // MARK:  Delete Image
    static func deleteImage(filename: String) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("Image deleted: \(filename)")
        } catch {
            print("Error deleting image: \(error.localizedDescription)")
        }
    }
    
    //MARK: Convert to pdf
    
    static func convertImageToPDF(image: UIImage) -> String? {
        let filename = UUID().uuidString + ".pdf"
        let imageBounds = CGRect(origin: .zero, size: image.size)
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: imageBounds)
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error: Could not find documents directory")
            return nil
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        

        do {
            try pdfRenderer.writePDF(to: fileURL) { context in
                context.beginPage()
                image.draw(in: imageBounds)
            }
            print("PDF successfully saved to: \(fileURL.path)")
            return filename
        } catch {
            print("Could not create PDF file: \(error)")
            return nil
        }
    }
    
    // MARK: Helper
    static func getFileURL(filename: String) -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documentsDirectory.appendingPathComponent(filename)
    }
}
