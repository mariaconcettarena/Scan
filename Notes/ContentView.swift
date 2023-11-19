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

class SharedViewModel: ObservableObject {
    @Published var scannedImage: UIImage?
    @Published var savedDocuments: [URL] = []
}

struct ContentView: View {
    @StateObject private var viewModel = SharedViewModel()
    @State private var isImagePickerPresented: Bool = false
    @State private var showAlert: Bool = false
    @State private var isShowingDocumentsModal: Bool = false
    @State private var isEditingImage: Bool = false
    @State private var rotationAngle: Angle = .degrees(0)
    @State private var isCroppingActive: Bool = false
    @State private var selectedCropRectangle: CGRect = CGRect(x: 0, y: 0, width: 200, height: 200)
    @State private var imageViewOrigin: CGPoint = .zero
    
    // for the background
    let gradient = LinearGradient(
        gradient: Gradient(colors: [Color.white, Color.gray, Color.black]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        NavigationView {
            ZStack {
                gradient
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if let scannedImage = viewModel.scannedImage {
                        Image(uiImage: scannedImage)
                            .resizable()
                            .scaledToFit()
                            .rotationEffect(rotationAngle)
                            .gesture(rotationGesture())
                            .clipped()
                            .overlay(croppingOverlay(isActive: isCroppingActive)
                                .gesture(DragGesture()
                                    .onChanged { value in
                                        // Aggiorna la posizione del rettangolo di selezione durante il trascinamento
                                        let translation = value.translation
                                        selectedCropRectangle = CGRect(
                                            x: selectedCropRectangle.origin.x + translation.width,
                                            y: selectedCropRectangle.origin.y + translation.height,
                                            width: selectedCropRectangle.width,
                                            height: selectedCropRectangle.height
                                        )
                                    }
                                )
                            )
                            .padding()
                        
                        Button("Save") {
                            applyFilter()
                            saveImageAsPDF()
                            withAnimation {
                                viewModel.scannedImage = nil
                                rotationAngle = .degrees(0)
                                isCroppingActive = true
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
                        
                        Spacer().frame(height: 40)
                        
                        HStack(spacing: 0) {
                            Button(action: {
                                isShowingDocumentsModal.toggle()
                            }) {
                                Text("View Documents")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            
                            Image(systemName: "doc.text")
                                .foregroundColor(.white)
                                .font(.title2)
                                .offset(x: -40)
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
                    Alert(title: Text("Success!"), message: Text("Document saved as PDF in Saved Documents"), dismissButton: .default(Text("OK")))
                }
            }
            .onAppear {
                // Imposta la posizione dell'angolo in alto a sinistra dell'immagine nella vista
                imageViewOrigin = getImageOrigin()
            }
            .background(Color("BackgroundColor").ignoresSafeArea())
        }
    }
    
    private func getImageOrigin() -> CGPoint {
        guard let scannedImage = viewModel.scannedImage else { return .zero }
        
        let imageSize = scannedImage.size
        let frameSize = UIScreen.main.bounds.size
        
        let x = (frameSize.width - imageSize.width) / 2
        let y = (frameSize.height - imageSize.height) / 2
        
        return CGPoint(x: x, y: y)
    }
    
    private func applyCropping() {
        guard let scannedImage = viewModel.scannedImage else { return }
        
        // Calcola il rettangolo di selezione
        let imageSize = scannedImage.size
        let scale = UIScreen.main.scale
        let selectedRect = CGRect(
            x: (selectedCropRectangle.origin.x - imageViewOrigin.x) * scale,
            y: (selectedCropRectangle.origin.y - imageViewOrigin.y) * scale,
            width: selectedCropRectangle.width * scale,
            height: selectedCropRectangle.height * scale
        )
        
        // Esegue il ritaglio dell'immagine
        guard let croppedImage = scannedImage.cropped(to: selectedRect) else { return }
        
        // Aggiorna l'immagine ritagliata
        viewModel.scannedImage = croppedImage
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
    
    private func croppingOverlay(isActive: Bool) -> some View {
        Group {
            if isActive {
                Color.black
                    .opacity(0.4)
                    .overlay(
                        Rectangle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: selectedCropRectangle.width, height: selectedCropRectangle.height)
                            .position(x: selectedCropRectangle.midX, y: selectedCropRectangle.midY)
                            .gesture(DragGesture()
                                .onChanged { value in
                                    // Aggiorna la posizione del rettangolo di selezione durante il trascinamento
                                    let translation = value.translation
                                    selectedCropRectangle = CGRect(
                                        x: selectedCropRectangle.origin.x + translation.width,
                                        y: selectedCropRectangle.origin.y + translation.height,
                                        width: selectedCropRectangle.width,
                                        height: selectedCropRectangle.height
                                    )
                                }
                            )
                    )
                    .onTapGesture {
                        // Disattiva la modalità di ritaglio quando tocco l'overlay
                        isCroppingActive = false
                    }
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    

private func rotationGesture() -> some Gesture {
    RotationGesture()
        .onChanged { angle in
            rotationAngle = angle
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
    @State private var isEditing: Bool = false
    @State private var newName: String = ""
    @State private var selectedDocument: URL?
    @State private var navigateToDocument: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(savedDocuments, id: \.self) { documentURL in
                    HStack {
                        if documentURL == selectedDocument && isEditing {
                            TextField("Enter new name", text: $newName, onCommit: {
                                renameDocument()
                                isEditing = false
                            })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.leading, 8)
                            .onAppear {
                                newName = documentURL.lastPathComponent
                                
                            }
                        } else {
                            NavigationLink(destination: PDFViewer(url: documentURL), isActive: $navigateToDocument) {
                                EmptyView()
                            }
                            .hidden()
                            .frame(width: 0, height: 0)
                            .disabled(true)
                            .onAppear {
                                if navigateToDocument {
                                    selectedDocument = documentURL
                                    navigateToDocument = false
                                }
                            }
                            
                            Text(documentURL.lastPathComponent)
                                .onTapGesture {
                                    guard !isEditing else { return }
                                    selectedDocument = documentURL
                                    navigateToDocument = true
                                }
                                .onLongPressGesture {
                                    withAnimation {
                                        selectedDocument = documentURL
                                        isEditing = true
                                    }
                                }
                        }
                        
                        Spacer()
                        
                        if documentURL != selectedDocument {
                            Button(action: {
                                deleteDocument(at: documentURL)
                            }) {
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteDocuments)
            }
            .navigationBarTitle("Saved Documents")
            .navigationBarItems(trailing: EditButton())
        }
    }
    
    
    
    private func renameDocument() {
        guard let selectedDocument = selectedDocument, !newName.isEmpty else {
            selectedDocument = nil
            return
        }
        
        do {
            let newURL = selectedDocument.deletingLastPathComponent().appendingPathComponent(newName)
            try FileManager.default.moveItem(at: selectedDocument, to: newURL)
            
            if let index = savedDocuments.firstIndex(of: selectedDocument) {
                savedDocuments[index] = newURL
            }
            
            self.selectedDocument = nil
        } catch {
            print("Error renaming document: \(error.localizedDescription)")
        }
    }
    
    private func deleteDocument(at documentURL: URL) {
        do {
            try FileManager.default.removeItem(at: documentURL)
            if let index = savedDocuments.firstIndex(of: documentURL) {
                savedDocuments.remove(at: index)
            }
        } catch {
            print("Error deleting document: \(error.localizedDescription)")
        }
    }
    
    private func deleteDocuments(offsets: IndexSet) {
        savedDocuments.remove(atOffsets: offsets)
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
        HStack(spacing: 0) {
            Image(systemName: "camera.fill")
                .font(.title)
                .foregroundColor(.white)
                .offset(x: 10)
            
            Text("Capture photo")
                .foregroundColor(.white)
                .bold()
                .padding()
        }
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.black))
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

extension UIImage {
    func cropped(to rect: CGRect) -> UIImage? {
        guard let cgImage = cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }
}


#Preview {
    ContentView()
}
