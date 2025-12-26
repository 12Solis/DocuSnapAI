//
//  AuthenticationManager.swift
//  DocuSnapAI
//
//  Created by Leonardo Solís on 25/12/25.
//

import LocalAuthentication
import Combine
import SwiftUI

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var authenticationError: String?

    @MainActor
    func authenticate() async -> Bool {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            self.authenticationError = error?.localizedDescription ?? "Biometrics not available"
            self.isAuthenticated = false
            return false
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Authenticate to access private documents"
            )
            
            self.isAuthenticated = success
            return success
            
        } catch {
            self.authenticationError = error.localizedDescription
            self.isAuthenticated = false
            return false
        }
    }
}

