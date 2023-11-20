import SwiftUI
import UIKit

/*
 La struttura ImagePicker è conforme al protocollo UIViewControllerRepresentable, il che significa che può essere utilizzata come parte di una vista SwiftUI.
 Ha due proprietà:
 selectedImage: Una variabile di binding a un'immagine UIImage?, che verrà aggiornata con l'immagine selezionata dall'utente.
 sourceType: Specifica il tipo di origine per il controller di immagini (ad esempio, fotocamera o libreria).
 */
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType

    @Environment(\.presentationMode) private var presentationMode

    /*
     Una classe interna Coordinator conforma ai protocolli UIImagePickerControllerDelegate e UINavigationControllerDelegate. Questa classe gestisce gli eventi del controller di immagini.
     Quando l'utente seleziona un'immagine, l'immagine viene estratta da info e assegnata a parent.selectedImage. Il coordinator è in grado di accedere a parent grazie alla sua relazione con la struttura principale.
     Il metodo imagePickerController(_:didFinishPickingMediaWithInfo:) viene chiamato quando l'utente ha selezionato un'immagine, e la presentazione del controller di immagini viene quindi chiusa.
     */
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
//Crea e restituisce un'istanza di UIImagePickerController, impostando il tipo di origine e assegnando il coordinator come delegato.
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
//Questo metodo viene chiamato quando la vista deve essere aggiornata, ma in questo caso, non è necessario fare nulla.
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    //Crea e restituisce un'istanza di Coordinator.
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}
/*
 Utilizza @Environment(\.presentationMode) per ottenere l'oggetto presentationMode dell'ambiente. Questo viene utilizzato per chiudere il controller di immagini dopo che l'utente ha selezionato un'immagine.

 */
