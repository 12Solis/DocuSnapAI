//
//  OnboardingView.swift
//  DocuSnapAI
//
//  Created by Leonardo Solís on 26/12/25.
//

import SwiftUI
import PhotosUI
import LocalAuthentication
import AVFoundation

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentPage) {
                    OnboardingPage(
                        imageName: "doc.viewfinder",
                        title: "Scan Documents",
                        description: "Digitize your paper documents instantly with AI-powered text recognition.",
                        color: .blue
                    )
                    .tag(0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .gesture(DragGesture())
                    
                    OnboardingPage(
                        imageName: "tag.fill",
                        title: "Organize Smartly",
                        description: "Group your files with custom tags and find them instantly with powerful search.",
                        color: .orange
                    )
                    .tag(1)
                    
                    OnboardingPage(
                        imageName: "lock.shield",
                        title: "Secure & Private",
                        description: "Protect your sensitive documents with FaceID. Your data stays on your device.",
                        color: .green
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                VStack(spacing: 20) {
                    if currentPage == 0 {
                        Button {
                            requestCameraPermission()
                            withAnimation { currentPage += 1 }
                        } label: {
                            Text("Enable Camera Access")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    } else if currentPage == 2 {
                        Button {
                            isPresented = false
                        } label: {
                            Text("Get Started")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    } else {
                        Button {
                            withAnimation { currentPage += 1 }
                        } label: {
                            Text("Next")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .foregroundColor(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }
    
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
        }
    }
}

struct OnboardingPage: View {
    let imageName: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 32, weight: .bold))
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
