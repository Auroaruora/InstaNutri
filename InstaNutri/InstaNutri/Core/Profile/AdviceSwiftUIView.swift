//
//  AdviceSwiftUIView.swift
//  InstaNutri
//
//  Created by 邱邱 on 11/26/24.
//

import SwiftUI

struct AdviceSwiftUIView: View {
    @State private var isLoading = true
    @State private var insufficientData = false
    @State private var missingPerosnalInfo = false
    @State private var adviceData: AdviceContent?
    @Environment(\.presentationMode) var presentationMode
    


    private let fileName = "meals.json"

    var body: some View {
        VStack {
            if insufficientData {
                VStack(spacing: 20) {
                    Text("Not Enough Data")
                        .font(.title)
                        .bold()
                    Text("You need to log at least 6 meals in the past 7 days for meaningful insights.")
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .padding(.horizontal)
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Go Back")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                }
            } else if missingPerosnalInfo{
                VStack(spacing: 20) {
                    Text("Missing Personal Information")
                        .font(.title)
                        .bold()
                    Text("You need to Provide you Information in 'Ask AI for Calorie Recommendation' get personalized advice.")
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .padding(.horizontal)
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Go Back")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                }
            } else if isLoading {
                VStack(spacing: 20) {
                    Text("Analyzing your meals... Please wait.")
                        .font(.headline)
                        .padding()
                    ProgressView()
                }
            } else if let adviceData = adviceData {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            Text(adviceData.title)
                                .font(.title2)
                                .bold()
                            Spacer()
                        }
                        .padding(.horizontal)

                        // Analysis Summary Card
                        cardView(title: "Analysis Summary", content: adviceData.analysisSummary)

                        // Diet Highlights Card
                        cardView(title: "Diet Highlights", content: adviceData.dietHighlights)

                        // Recommendations Card
                        cardView(title: "Personalized Recommendations", content: adviceData.recommendations)
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            if let url = MealDataManager.shared.fileURL {
                print("meals.json URL: \(url.absoluteString)")
            } else {
                print("meals.json file URL not found.")
            }
            validateAndFetchMealData()
        }
    }

    private func cardView(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .bold()
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }

    private func validateAndFetchMealData() {
        isLoading = true
        insufficientData = false

        DispatchQueue.main.async {
            // Load meal data for the past 7 days
            guard let meals = MealDataManager.shared.loadMealsForLast7Days() else {
                insufficientData = true
                isLoading = false
                return
            }

            // Load user data
            guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("Failed to access document directory")
                missingPerosnalInfo = true
                isLoading = false
                return
            }

            let userFileURL = documentDirectory.appendingPathComponent("userData.json")
            guard let userData = try? Data(contentsOf: userFileURL),
                  let userDictionary = try? JSONSerialization.jsonObject(with: userData, options: []) as? [String: Any] else {
                print("Failed to load user data")
                missingPerosnalInfo = true
                isLoading = false
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
                    You are a helpful assistant providing personalized nutritional insights. Based on the provided meal data:
                    1. Evaluate the completeness of the meal data:
                       - If the data appears incomplete (e.g., fewer than 2 meals per day or gaps between days), adjust your analysis to focus on individual meals, highlighting patterns and recommendations on a per-meal basis. Also reminds the user that analysis may affect the accuracy of the analysis due to incomplete data in the analysisSummary part.
                       - If the data appears complete (e.g., meals logged consistently for all 7 days), provide a comprehensive weekly analysis, aggregating insights and patterns.
                    2. Your response should include:
                       - Title: A meaningful title summarizing the analysis period (e.g., "Your Weekly Meal Analysis").
                       - Analysis Summary: A short summary of the user's overall intake for the past 7 days or key highlights for individual meals, depending on the completeness of the data.
                       - Diet Highlights: Highlight positive aspects of the user's eating habits.
                       - Recommendations: Provide specific suggestions for improvement.

                    Respond in the following JSON format:
                    {
                        "title": "<string>",
                        "analysisSummary": "<string>",
                        "dietHighlights": "<string>",
                        "recommendations": "<string>"
                    }
                    Do not include any other information or text outside of this JSON format.
                    """],
                    ["role": "user", "content": """
                    Here is the user's data for analysis:
                    User Data: \(userDictionary)
                    Meal Data: \(meals)
                    """]
                ],
                "max_tokens": 200
            ]

            guard let httpBody = try? JSONSerialization.data(withJSONObject: jsonBody, options: []) else {
                print("Failed to serialize JSON body")
                isLoading = false
                return
            }

            request.httpBody = httpBody

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

                // Parse the API response
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let choices = jsonObject["choices"] as? [[String: Any]],
                       let message = choices.first?["message"] as? [String: Any],
                       let contentString = message["content"] as? String,
                       let contentData = contentString.data(using: .utf8),
                       let adviceResponse = try JSONSerialization.jsonObject(with: contentData, options: []) as? [String: Any],
                       let title = adviceResponse["title"] as? String,
                       let analysisSummary = adviceResponse["analysisSummary"] as? String,
                       let dietHighlights = adviceResponse["dietHighlights"] as? String,
                       let recommendations = adviceResponse["recommendations"] as? String {

                        // Successfully parsed response
                        DispatchQueue.main.async {
                            adviceData = AdviceContent(
                                title: title,
                                analysisSummary: analysisSummary,
                                dietHighlights: dietHighlights,
                                recommendations: recommendations
                            )
                            isLoading = false
                        }
                    } else {
                        print("Failed to parse advice content from API response")
                        DispatchQueue.main.async {
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

}

// AdviceContent struct for holding advice data
struct AdviceContent {
    let title: String
    let analysisSummary: String
    let dietHighlights: String
    let recommendations: String
}

#Preview {
    AdviceSwiftUIView()
}
