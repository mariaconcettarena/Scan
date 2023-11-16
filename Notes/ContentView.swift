//
//  ContentView.swift
//  Notes
//
//  Created by Maria Concetta on 13/11/23.

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos
import PDFKit
/*
class SharedViewModel: ObservableObject {
    @Published var scannedImage: UIImage?
    @Published var savedDocuments: [URL] = []
}

struct ContentView: View {
    @StateObject private var viewModel = SharedViewModel()
    @State private var isImagePickerPresented: Bool = false
    @State private var showAlert: Bool = false
    @State private var isShowingDocumentsModal: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                if let scannedImage = viewModel.scannedImage {
                    Image(uiImage: scannedImage)
                        .resizable()
                        .scaledToFit()
                        .padding()

                    Button("Done") {
                        applyFilter()
                        saveImageAsPDF()
                        // Reset scannedImage and return to "Capture Photo" screen
                        viewModel.scannedImage = nil
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 15).fill(Color.blue))
                    .padding(.horizontal, 20)
                    .shadow(radius: 5)
                    .padding()
                } else {
                    Button(action: {
                        isImagePickerPresented.toggle()
                    }) {
                        HStack {
                            Text("Capture photo")
                                .foregroundColor(.white)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 15).fill(Color.blue))
                                .padding(.horizontal, 20)
                                .shadow(radius: 5)
                                .bold()
                        }
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

                Button("View Documents") {
                    isShowingDocumentsModal.toggle()
                } .padding()
                    .foregroundColor(.blue)
                    .bold()
                    .padding(.horizontal, 20)
                    .padding()
                .sheet(isPresented: $isShowingDocumentsModal) {
                    DocumentsModalView(savedDocuments: $viewModel.savedDocuments)
                }.padding()
            }
            .navigationBarTitle("Scan Document")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Success"), message: Text("Document saved as PDF"), dismissButton: .default(Text("OK")))
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

    private func saveImageAsPDF() {
        guard let scannedImage = viewModel.scannedImage else { return }

        let pdfDocument = PDFDocument()
        let pdfPage = PDFPage(image: scannedImage)
        pdfDocument.insert(pdfPage!, at: 0)

        if let data = pdfDocument.dataRepresentation() {
            do {
                let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let fileName = "scannedDocument_\(Date().timeIntervalSince1970).pdf"
                let fileURL = documentsURL.appendingPathComponent(fileName)
                try data.write(to: fileURL)
                showAlert = true // Attiva la notifica
                viewModel.savedDocuments.append(fileURL)
            } catch {
                print("Error saving document as PDF: \(error.localizedDescription)")
            }
        }
    }
}

struct DocumentsModalView: View {
    @Binding var savedDocuments: [URL]

    var body: some View {
        NavigationView {
            List {
                ForEach(savedDocuments, id: \.self) { documentURL in
                    NavigationLink(destination: PDFViewer(url: documentURL)) {
                        Text(documentURL.lastPathComponent)
                    }
                }
            }
            .navigationBarTitle("Saved Documents")
        }
    }
}

struct PDFViewer: View {
    let url: URL

    var body: some View {
        PDFKitView(url: url)
            .navigationBarTitle(Text(url.lastPathComponent), displayMode: .inline)
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}*/


class SharedViewModel: ObservableObject {
    @Published var scannedImage: UIImage?
    @Published var savedDocuments: [URL] = []
}

struct ContentView: View {
    @StateObject private var viewModel = SharedViewModel()
    @State private var isImagePickerPresented: Bool = false
    @State private var showAlert: Bool = false
    @State private var isShowingDocumentsModal: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                if let scannedImage = viewModel.scannedImage {
                    Image(uiImage: scannedImage)
                        .resizable()
                        .scaledToFit()
                        .padding()

                    Button("Save") {
                        applyFilter()
                        saveImageAsPDF()
                        // Reset scannedImage and return to "Capture Photo" screen
                        withAnimation {
                            viewModel.scannedImage = nil
                        }
                    }
                    .buttonStyle(DoneButtonStyle())
                    .padding()
                } else {
                    Button(action: {
                        isImagePickerPresented.toggle()
                    }) {
                        CapturePhotoButton()
                    }
                    .sheet(isPresented: $isImagePickerPresented) {
                        ImagePicker(selectedImage: $viewModel.scannedImage, sourceType: .camera)
                            .onDisappear {
                                if viewModel.scannedImage != nil {
                                    applyFilter()
                                }
                            }
                    }

                    Spacer().frame(height: 20)
                    

                    Button("View Documents") {
                        isShowingDocumentsModal.toggle()
                    }
                    .buttonStyle(ViewDocumentsButtonStyle())
                    .sheet(isPresented: $isShowingDocumentsModal) {
                        DocumentsModalView(savedDocuments: $viewModel.savedDocuments)
                    }
                    .padding()
                    Spacer().frame(height: 10)
                    
                    
                }
            }
            .navigationBarTitle("Scan Document")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Success"), message: Text("Document saved as PDF"), dismissButton: .default(Text("OK")))
            }
        }
        .background(Color("BackgroundColor").ignoresSafeArea())
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

    private func saveImageAsPDF() {
        guard let scannedImage = viewModel.scannedImage else { return }

        let pdfDocument = PDFDocument()
        let pdfPage = PDFPage(image: scannedImage)
        pdfDocument.insert(pdfPage!, at: 0)

        if let data = pdfDocument.dataRepresentation() {
            do {
                let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let fileName = "scannedDocument_\(Date().timeIntervalSince1970).pdf"
                let fileURL = documentsURL.appendingPathComponent(fileName)
                try data.write(to: fileURL)
                showAlert = true // Attiva la notifica
                viewModel.savedDocuments.append(fileURL)
            } catch {
                print("Error saving document as PDF: \(error.localizedDescription)")
            }
        }
    }
}

struct DocumentsModalView: View {
    @Binding var savedDocuments: [URL]

    var body: some View {
        NavigationView {
            List {
                ForEach(savedDocuments, id: \.self) { documentURL in
                    NavigationLink(destination: PDFViewer(url: documentURL)) {
                        Text(documentURL.lastPathComponent)
                    }
                }
            }
            .navigationBarTitle("Saved Documents")
        }
    }
}

struct PDFViewer: View {
    let url: URL

    var body: some View {
        PDFKitView(url: url)
            .navigationBarTitle(Text(url.lastPathComponent), displayMode: .inline)
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}

// Aggiungi queste strutture per definire stili personalizzati per i pulsanti
struct DoneButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .background(RoundedRectangle(cornerRadius: 15).fill(Color.blue))
            .padding(.horizontal, 20)
            .shadow(radius: 5)
    }
}

struct CapturePhotoButton: View {
    var body: some View {
        HStack {
            Image(systemName: "camera.fill")
                .font(.title)
            Text("Capture photo")
                .foregroundColor(.white)
                .padding()
            
        }
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.blue))
        .padding(.horizontal, 20)
        .shadow(radius: 5)
        .padding()
        
    }
    
}

struct ViewDocumentsButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.blue)
            .font(.headline)
            .background(RoundedRectangle(cornerRadius: 15).fill(Color("ViewDocumentsButtonColor")))
            .padding(.horizontal, 20)
            .padding()
    }
}


#Preview {
    ContentView()
}
