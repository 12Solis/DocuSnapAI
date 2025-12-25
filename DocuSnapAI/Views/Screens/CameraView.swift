//
//  CameraView.swift
//  DocuSnapAI
//
//  Created by Leonardo Solís on 24/12/25.
//

import SwiftUI
import VisionKit

struct CameraView: UIViewControllerRepresentable {
    var onScanDidFinish: (VNDocumentCameraScan) -> Void
    var onCancel: () -> Void
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = context.coordinator
        return scannerViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
   
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: CameraView
        
        init(parent: CameraView) {
            self.parent = parent
        }
        
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            parent.onScanDidFinish(scan)
        }
        
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.onCancel()
        }
        
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("Scanner failed: \(error.localizedDescription)")
            parent.onCancel()
        }
    }
}

