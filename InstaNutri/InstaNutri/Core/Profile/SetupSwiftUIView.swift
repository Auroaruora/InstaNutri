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
                })
            } else if step == 5 {
                ConfirmationView()
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .animation(.easeInOut, value: step)
    }
    
    private func saveToJSON() {
        let userData: [String: Any] = [
            "gender": gender,
            "weight": [
                "value": weight,
                "unit": "kg"
            ],
            "height": [
                "value": height,
                "unit": "cm"
            ],
            "activityLevel": activityLevel,
            "goal": goal,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent("userData.json")
            
            do {
                let data = try JSONSerialization.data(withJSONObject: userData, options: .prettyPrinted)
                try data.write(to: fileURL, options: .atomic)
                print("User data saved to JSON at \(fileURL.path)")
            } catch {
                print("Failed to save user data: \(error.localizedDescription)")
            }
        }
    }
}

struct ConfirmationView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground) // Fixed background color
                .ignoresSafeArea() // Ensures it fills the entire screen
            
            VStack(spacing: 20) {
                Text("Nutrition Updated!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Your recommended nutrition has been updated on the home screen.")
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Close")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(radius: 5)
            )
            .padding()
        }
    }
}




struct GenderSelectionView: View {
    @Binding var selectedGender: String
    @Binding var step: Int
    
    var body: some View {
        VStack(spacing: 30) {
            Text("What's Your Gender?")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                GenderButton(label: "Male", isSelected: selectedGender == "Male") {
                    selectedGender = "Male"
                }
                GenderButton(label: "Female", isSelected: selectedGender == "Female") {
                    selectedGender = "Female"
                }
            }
            
            Spacer()
            
            ContinueButton(isEnabled: !selectedGender.isEmpty) {
                step += 1
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white).shadow(radius: 5))
        .padding()
    }
}

struct WeightSelectionView: View {
    @Binding var weight: Double
    @Binding var step: Int

    @State private var weightInput: String = ""

    var body: some View {
        VStack(spacing: 30) {
            Text("How much do you weigh?")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 20)

            // Weight Input with 'kg' Label
            HStack {
                TextField("Enter weight", text: $weightInput)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .frame(maxWidth: .infinity)
                    .onChange(of: weightInput) { newValue in
                        // Validate and update weight
                        if let weightValue = Double(newValue), weightValue >= 30.0, weightValue <= 200.0 {
                            weight = weightValue
                        }
                    }

                Text("kg")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.leading, 5)
            }
            .padding(.horizontal)

            Spacer()

            // Continue Button
            ContinueButton {
                if let weightValue = Double(weightInput), weightValue >= 30.0, weightValue <= 200.0 {
                    weight = weightValue
                    step += 1
                }
            }
            .disabled(weightInput.isEmpty || Double(weightInput) == nil)

        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white).shadow(radius: 5))
        .padding()
    }
}



struct HeightSelectionView: View {
    @Binding var height: Double
    @Binding var step: Int

    var body: some View {
        VStack(spacing: 30) {
            Text("How tall are you?")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 20)

            // Height Picker in cm
            Picker("Height in cm", selection: $height) {
                ForEach(100...220, id: \.self) { value in
                    Text("\(value) cm").tag(Double(value))
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)

            Spacer()

            ContinueButton {
                step += 1
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white).shadow(radius: 5))
        .padding()
    }
}


struct ActivityLevelView: View {
    @Binding var selectedActivity: String
    @Binding var step: Int
    
    var body: some View {
        VStack(spacing: 20) {
            Text("What's Your Physical Activity Level?")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(["Beginner", "Intermediate", "Advanced"], id: \.self) { level in
                Button(action: {
                    selectedActivity = level
                }) {
                    Text(level)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedActivity == level ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(selectedActivity == level ? .white : .black)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 10)
            }
            
            Spacer()
            
            ContinueButton(isEnabled: !selectedActivity.isEmpty) {
                step += 1
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white).shadow(radius: 5))
        .padding()
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
        VStack(spacing: 20) {
            Text("What's Your Goal?")
                .font(.title2)
                .fontWeight(.bold)
            
            // Display goal options
            ForEach(["Maintain Current Weight", "Weight Loss", "Weight Gain"], id: \.self) { goal in
                Button(action: {
                    selectedGoal = goal
                }) {
                    Text(goal)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedGoal == goal ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(selectedGoal == goal ? .white : .black)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 10)
            }
            
            Spacer()
            
            // Finish button to complete the selection and trigger the `onComplete` closure
            Button("Finish") {
                if !selectedGoal.isEmpty {
                    onComplete()
                    step += 1 // Move to the next step (confirmation view)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedGoal.isEmpty) // Disable button if no goal is selected
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white).shadow(radius: 5))
        .padding()
    }
}


struct ContinueButton: View {
    var isEnabled: Bool = true
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            Text("Continue")
                .frame(maxWidth: .infinity)
                .padding()
                .background(isEnabled ? Color.green : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(!isEnabled)
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
            ["role": "system", "content": """
            You are a helpful assistant that provides personalized nutritional recommendations. Based on user data, calculate and return the following:
            - Recommended daily calorie intake as a realistic and personalized integer value, not a multiple of 100.
            - Macronutrient breakdown including fat (grams), carbs (grams), and proteins (grams).
            Respond in the following JSON format:
            {
                "calories": <integer>,
                "fat": <grams>,
                "carbs": <grams>,
                "proteins": <grams>
            }
            Do not add any other information or text outside of this JSON format.
            """],
            ["role": "user", "content": "Based on the following user data, calculate the recommended daily intake:\n\(userData)"]
        ],
        "max_tokens": 100
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
               let contentString = message["content"] as? String,
               let contentData = contentString.data(using: .utf8),
               let nutritionData = try JSONSerialization.jsonObject(with: contentData) as? [String: Any],
               let calories = nutritionData["calories"] as? Int,
               let fat = nutritionData["fat"] as? Int,
               let carbs = nutritionData["carbs"] as? Int,
               let proteins = nutritionData["proteins"] as? Int {

                // Successfully parsed nutrient data
                DispatchQueue.main.async {
                    UserDefaults.standard.set(calories, forKey: "recommendedCalories")
                    UserDefaults.standard.set(fat, forKey: "recommendedFat")
                    UserDefaults.standard.set(carbs, forKey: "recommendedCarbs")
                    UserDefaults.standard.set(proteins, forKey: "recommendedProteins")
                    print("Recommended Nutritional Intake:")
                    print("Calories: \(calories) kcal")
                    print("Fat: \(fat) g")
                    print("Carbs: \(carbs) g")
                    print("Proteins: \(proteins) g")
                }
            } else {
                print("Failed to parse nutritional data from API response")
            }
        } catch {
            print("Failed to decode API response: \(error)")
        }
    }.resume()
}

