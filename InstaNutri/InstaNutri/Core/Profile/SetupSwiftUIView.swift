//
//  SetupSwiftUIView.swift
//  InstaNutri
//
//  Created by Zeyu Qiu on 11/21/24.
//

import SwiftUI

struct SetupPage: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var step = 0
    @State private var gender: String = ""
    @State private var weight: Double = 70
    @State private var height: Double = 170
    @State private var activityLevel: String = ""
    @State private var goal: String = ""
    
    var body: some View {
        VStack {
            if step == 0 {
                GenderSelectionView(selectedGender: $gender, step: $step)
            } else if step == 1 {
                WeightSelectionView(weight: $weight, step: $step)
            } else if step == 2 {
                HeightSelectionView(height: $height, step: $step)
            } else if step == 3 {
                ActivityLevelView(selectedActivity: $activityLevel, step: $step)
            } else if step == 4 {
                GoalSelectionView(selectedGoal: $goal, step: $step, gender: gender, weight: weight, height: height, activityLevel: activityLevel, onComplete: {
                    saveToJSON()
                    analyzeCalorieIntake()
                    presentationMode.wrappedValue.dismiss() // Redirect to ProfileView
                })
            }
        }
        .animation(.easeInOut, value: step)
        .padding()
    }
    
    private func saveToJSON() {
        let userData: [String: Any] = [
            "gender": gender,
            "weight": weight,
            "height": height,
            "activityLevel": activityLevel,
            "goal": goal,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent("userData.json")
            
            do {
                // Serialize the user data into JSON
                let data = try JSONSerialization.data(withJSONObject: userData, options: .prettyPrinted)
                
                // Write the data to the file, overwriting any existing file
                try data.write(to: fileURL, options: .atomic)
                
                print("User data saved to JSON at \(fileURL.path)")
            } catch {
                print("Failed to save user data: \(error.localizedDescription)")
            }
        }
    }
}

struct GenderSelectionView: View {
    @Binding var selectedGender: String
    @Binding var step: Int
    
    var body: some View {
        VStack {
            Text("What's Your Gender?")
                .font(.title)
                .padding()
            
            HStack {
                GenderButton(label: "Male", isSelected: selectedGender == "Male") {
                    selectedGender = "Male"
                }
                GenderButton(label: "Female", isSelected: selectedGender == "Female") {
                    selectedGender = "Female"
                }
            }
            
            Spacer()
            Button("Continue") {
                if !selectedGender.isEmpty {
                    step += 1
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct WeightSelectionView: View {
    @Binding var weight: Double
    @Binding var step: Int
    
    var body: some View {
        VStack {
            Text("What's Your Weight?")
                .font(.title)
                .padding()
            
            Slider(value: $weight, in: 30...200, step: 0.5) {
                Text("Weight")
            }
            Text("\(weight, specifier: "%.1f") Kg")
                .font(.title2)
                .padding()
            
            Spacer()
            Button("Continue") {
                step += 1
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct HeightSelectionView: View {
    @Binding var height: Double
    @Binding var step: Int
    
    var body: some View {
        VStack {
            Text("What's Your Height?")
                .font(.title)
                .padding()
            
            Slider(value: $height, in: 100...220, step: 1) {
                Text("Height")
            }
            Text("\(height, specifier: "%.0f") cm")
                .font(.title2)
                .padding()
            
            Spacer()
            Button("Continue") {
                step += 1
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct ActivityLevelView: View {
    @Binding var selectedActivity: String
    @Binding var step: Int
    
    var body: some View {
        VStack {
            Text("What's Your Physical Activity Level?")
                .font(.title)
                .padding()
            
            ForEach(["Beginner", "Intermediate", "Advanced"], id: \.self) { level in
                Button(action: {
                    selectedActivity = level
                }) {
                    Text(level)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedActivity == level ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.vertical, 5)
                }
            }
            
            Spacer()
            Button("Continue") {
                if !selectedActivity.isEmpty {
                    step += 1
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct GoalSelectionView: View {
    @Binding var selectedGoal: String
    @Binding var step: Int
    var gender: String
    var weight: Double
    var height: Double
    var activityLevel: String
    var onComplete: () -> Void
    
    var body: some View {
        VStack {
            Text("What's Your Goal?")
                .font(.title)
                .padding()
            
            ForEach(["Maintain Current Weight", "Weight Loss", "Weight Gain"], id: \.self) { goal in
                Button(action: {
                    selectedGoal = goal
                }) {
                    Text(goal)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedGoal == goal ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.vertical, 5)
                }
            }
            
            Spacer()
            Button("Done") {
                if !selectedGoal.isEmpty {
                    onComplete()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct GenderButton: View {
    var label: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.headline)
                .frame(width: 120, height: 50)
                .background(isSelected ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(25)
                .padding()
        }
    }
}

struct SetupPage_Previews: PreviewProvider {
    static var previews: some View {
        SetupPage()
    }
}


func analyzeCalorieIntake() {
    // Load user data from the JSON file
    guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("Failed to access document directory")
        return
    }

    let fileURL = documentDirectory.appendingPathComponent("userData.json")
    guard let jsonData = try? Data(contentsOf: fileURL),
          let userData = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
        print("Failed to load user data")
        return
    }

    // Prepare the API request
    let apiKey = "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"
    let url = URL(string: "https://api.openai.com/v1/chat/completions")!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // Construct the JSON payload
    let jsonBody: [String: Any] = [
        "model": "gpt-4o-mini",
        "messages": [
            ["role": "system", "content": "You are a helpful assistant. Respond only with an integer value representing the recommended daily calorie intake, without any additional information."],
            ["role": "user", "content": "Based on the following user data, calculate the recommended daily calorie intake as an integer: \(userData)"]
        ],
        "max_tokens": 50
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

        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = jsonObject["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String,
               let calorieIntake = Int(content.trimmingCharacters(in: .whitespacesAndNewlines)) {
                
                // Successfully parsed calorie intake as an integer
                DispatchQueue.main.async {
                    UserDefaults.standard.set(calorieIntake, forKey: "recommendedCalorieIntake")
                    print("Recommended Calorie Intake: \(calorieIntake)")
                }
            } else {
                print("Failed to parse calorie intake from API response")
            }
        } catch {
            print("Failed to decode API response: \(error)")
        }
    }.resume()
}

