import SwiftUI
import UIKit

struct CameraView: View {
    @State private var isCameraPresented = false
    @State private var capturedImage: UIImage? = nil
    @State private var savedImagePath: URL? = nil
    @State private var isAnalyzing = false
    @State private var navigateToDetectedView = false
    @State private var foodItems: [FoodItem] = []

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

                    Button(action: {
                        saveImage()
                        analyzeImage()
                        navigateToDetectedView = true
                    }) {
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
        .background(
            NavigationLink(destination: DetectedView(), isActive: $navigateToDetectedView) {
                EmptyView() // NavigationLink is hidden until triggered
            }
        )
    }

    func saveImage() {
        guard let image = capturedImage else { return }

        if let data = image.jpegData(compressionQuality: 0.8) {
            // Generate a unique filename with timestamp
            let timestamp = Date().timeIntervalSince1970
            let filename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("captured_image_\(Int(timestamp)).jpg")

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
    func analyzeImage() {
        guard let image = capturedImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to load image")
            return
        }

        let base64Image = imageData.base64EncodedString()
        let apiKey = "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"
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let functionSchema: [String: Any] = [
            "name": "get_food_info",
            "description": "Analyze an image to identify food items, their weights, and estimated calorie counts.",
            "parameters": [
                "type": "object",
                "properties": [
                    "food_items": [
                        "type": "array",
                        "items": [
                            "type": "object",
                            "properties": [
                                "name": ["type": "string"],
                                "weight": ["type": "number"],
                                "calories": ["type": "number"]
                            ],
                            "required": ["name", "weight", "calories"]
                        ]
                    ]
                ],
                "required": ["food_items"]
            ]
        ]
        
        let jsonBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant identifying food items from an image and providing calorie details."],
                ["role": "user", "content": "Please analyze the following image to list the food items with their estimated calories and weights."],
                ["type": "image_url", "image_url": "data:image/jpeg;base64,\(base64Image)"]
            ],
            "functions": [functionSchema],
            "max_tokens": 500
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: jsonBody, options: []) else {
            print("Failed to serialize JSON body")
            return
        }
        
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API error: \(error)")
                return
            }

            guard let data = data else {
                print("No data received from API")
                return
            }

            // Print raw JSON response
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw JSON response:\n\(rawResponse)")
            }

//            do {
//                if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
//                   let choices = jsonObject["choices"] as? [[String: Any]],
//                   let message = choices.first?["message"] as? [String: Any],
//                   let functionCall = message["function_call"] as? [String: Any],
//                   let argumentsString = functionCall["arguments"] as? String,
//                   let argumentsData = argumentsString.data(using: .utf8) {
//                    
//                    let decodedResponse = try JSONDecoder().decode(FoodResponse.self, from: argumentsData)
//                    DispatchQueue.main.async {
//                        foodItems = decodedResponse.food_items
//                        navigateToDetectedView = true
//                    }
//                }
//            } catch {
//                print("Failed to decode API response: \(error)")
//            }
        }.resume()
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


struct FoodItems: Codable, Identifiable {
    var id = UUID()
    let name: String
    let weight: Double
    let calories: Double
}
