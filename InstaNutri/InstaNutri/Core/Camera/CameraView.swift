import SwiftUI
import UIKit

struct CameraView: View {
    @State private var isCameraPresented = false
    @State private var capturedImage: UIImage? = nil
    @State private var savedImagePath: URL? = nil
    @State private var isAnalyzing = false

    var body: some View {
        VStack {
            if let image = capturedImage {
                // Show the captured image and save button
                VStack {
                    Text("Captured Image")
                        .font(.title)
                        .padding()

                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(10)
                        .padding()

                    Button(action: saveImage) {
                        Text("Save for Analysis")
                            .font(.headline)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()

                    if let path = savedImagePath {
                        Text("Image saved at: \(path.lastPathComponent)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding()
                    }

                    Button(action: resetCamera) {
                        Text("Retake")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            } else {
                // Show camera button
                VStack {
                    Text("Take a Photo of Your Food")
                        .font(.title2)
                        .padding()

                    Button(action: {
                        isCameraPresented = true
                    }) {
                        Text("Open Camera")
                            .font(.headline)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .sheet(isPresented: $isCameraPresented) {
            ImagePicker(image: $capturedImage, isAnalyzing: $isAnalyzing)
        }
    }

    // Save the captured image to the app's documents directory
    func saveImage() {
        guard let image = capturedImage else { return }

        if let data = image.jpegData(compressionQuality: 0.8) {
            let filename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("captured_image.jpg")

            do {
                try data.write(to: filename)
                savedImagePath = filename
                print("Image saved at \(filename)")
            } catch {
                print("Error saving image: \(error.localizedDescription)")
            }
        }
    }

    func resetCamera() {
        capturedImage = nil
        savedImagePath = nil
        isAnalyzing = false
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isAnalyzing: Bool

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                parent.isAnalyzing = true
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CameraView()
        }
    }
}
