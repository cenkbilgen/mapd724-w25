//
//  ContentView.swift
//  PhotosSample
//
//  Created by cenk on 2025-03-21.
//

import SwiftUI
import Photos
import PhotosUI

struct ContentView: View {
    
    @State var showPhotoSelector = false
    @State var selectedPhoto: PhotosPickerItem?
    @State var selectedImage: Image?
    
    var body: some View {
        VStack {
            Button("Select Photo") {
                showPhotoSelector = true
            }
            
            if let selectedImage {
                selectedImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            
        }
        .photosPicker(isPresented: $showPhotoSelector, selection: $selectedPhoto, matching: .images, preferredItemEncoding: .compatible)
        .padding()
        .onChange(of: selectedPhoto) { _, newValue in
            Task {
                if let newValue {
                    do {
                        self.selectedImage = try await loadImage(from: newValue)
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    private func loadImage(from item: PhotosPickerItem) async throws -> Image {
        guard let image = try await item.loadTransferable(type: Image.self) else {
            throw PHPhotosError(.invalidResource)
        }
        return image
    }
}

#Preview {
    ContentView()
}
