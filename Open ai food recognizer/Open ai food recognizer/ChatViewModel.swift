//
//  ChatViewModel.swift
//  Open ai food recognizer
//
//  Created by 陈淑祚 on 11/12/24.
//

import SwiftUI
import Foundation

struct FoodItem: Codable, Identifiable {
    let id = UUID()
    let name: String
    let weight: Double
    let calories: Double
}

struct FoodResponse: Codable {
    let food_items: [FoodItem]
}

struct ContentView: View {
    @State private var foodItems: [FoodItem] = []
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            if let image = UIImage(named: "fo") {  // Replace "YourImageName" with the name of your image in assets
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .padding()
            }
            
            Button("Analyze Image") {
                isLoading = true
                analyzeImage()
            }
            .padding()
            
            if isLoading {
                ProgressView()
            }
            
            List(foodItems) { item in
                VStack(alignment: .leading) {
                    Text(item.name)
                        .font(.headline)
                    Text("Weight: \(item.weight, specifier: "%.2f")g")
                    Text("Calories: \(item.calories, specifier: "%.2f") kcal")
                }
                .padding(.vertical, 5)
            }
        }
        .navigationTitle("Food Analysis")
    }
    
    func analyzeImage() {
        guard let image = UIImage(named: "fo"),  // Replace with your asset image name
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to load image from assets")
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

        
        // Construct the JSON payload
        let jsonBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant identifying food items from an image and providing calorie details."],
                ["role": "user", "content": [
                    ["type": "text", "text": "Please analyze the following image to list the food items with their estimated calories and weights."],
                    ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]]
                ]]
            ],
            "functions": [functionSchema],
            "max_tokens": 500
        ]
        
        // Serialize the JSON payload
        guard let httpBody = try? JSONSerialization.data(withJSONObject: jsonBody, options: []) else {
            print("Failed to serialize JSON body")
            return
        }
        
        request.httpBody = httpBody
        
        // Perform the API request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API error: \(error)")
                DispatchQueue.main.async {
                    isLoading = false
                }
                return
            }
            
            guard let data = data else {
                print("No data received from API")
                DispatchQueue.main.async {
                    isLoading = false
                }
                return
            }
            
            // Log the raw response to check for unexpected characters or errors
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw response:\n\(rawResponse)")
            }
            
            // Decode the response to get the nested content JSON string
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = jsonObject["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let contentString = message["content"] as? String,
                   let contentData = contentString.data(using: .utf8) {
                    
                    // Decode the JSON string within `content` into `FoodResponse`
                    let decodedResponse = try JSONDecoder().decode(FoodResponse.self, from: contentData)
                    DispatchQueue.main.async {
                        foodItems = decodedResponse.food_items
                        isLoading = false
                    }
                }
            } catch {
                print("Failed to decode API response: \(error)")
                DispatchQueue.main.async {
                    isLoading = false
                }
            }
        }.resume()
    }

}





