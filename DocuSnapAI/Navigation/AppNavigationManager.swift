//
//  AppNavigationManager.swift
//  DocuSnapAI
//
//  Created by Leonardo Solís on 26/12/25.
//

import SwiftUI
import Combine

class AppNavigationManager: ObservableObject {
    static let shared = AppNavigationManager()
    
    @Published var shouldOpenScanner = false
    
    private init() {}
}
