//
//  CameraView.swift
//  Notes
//
//  Created by Maria Concetta on 13/11/23.
//
import SwiftUI
//FUNZIONANTE
/*struct CameraView: View {
    @Binding var scannedImage: UIImage?
    @State private var isImagePickerPresented: Bool = false

    var body: some View {
        VStack {
            Button("Capture Photo") {
                isImagePickerPresented.toggle()
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $scannedImage, sourceType: .camera)
            }
        }
    }
}*/
        
/*import CoreImage
import CoreImage.CIFilterBuiltins

struct CameraView: View {
    @Binding var scannedImage: UIImage?
    @State private var isImagePickerPresented: Bool = false

    var body: some View {
        VStack {
            Button("Capture Photo") {
                isImagePickerPresented.toggle()
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $scannedImage, sourceType: .camera)
                    .onDisappear {
                        if scannedImage != nil {
                            applyFilter()
                        }
                    }
            }
        }
    }

    private func applyFilter() {
        guard let uiImage = scannedImage else { return }

        // Convert UIImage to CIImage
        let ciImage = CIImage(image: uiImage)

        // Apply a grayscale filter
        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        filter.saturation = 0.0

        if let outputCIImage = filter.outputImage {
            // Convert CIImage back to UIImage
            let context = CIContext()
            if let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) {
                scannedImage = UIImage(cgImage: cgImage)
            }
        }
    }
}*/

import CoreImage
import CoreImage.CIFilterBuiltins

struct CameraView: View {
    @ObservedObject var viewModel: SharedViewModel
    @State private var isImagePickerPresented: Bool = false

    var body: some View {
        VStack {
            Button("Capture Photo") {
                isImagePickerPresented.toggle()
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $viewModel.scannedImage, sourceType: .camera)
                    .onDisappear {
                        if viewModel.scannedImage != nil {
                            applyFilter()
                        }
                    }
            }
        }
    }

    private func applyFilter() {
        guard let uiImage = viewModel.scannedImage else { return }

        // Convert UIImage to CIImage
        let ciImage = CIImage(image: uiImage)

        // Apply a grayscale filter
        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        filter.saturation = 0.0

        if let outputCIImage = filter.outputImage {
            // Convert CIImage back to UIImage
            let context = CIContext()
            if let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) {
                viewModel.scannedImage = UIImage(cgImage: cgImage)
            }
        }
    }
}


#Preview {
    CameraView(viewModel: SharedViewModel())
}
