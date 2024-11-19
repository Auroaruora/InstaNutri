//
//  MealDataManager.swift
//  InstaNutri
//
//  Created by Zeyu Qiu on 11/19/24.
//

import Foundation

struct Meal: Codable {
    let date: String
    let time: String
    let totalCalories: Double
    let totalProtein: Double
    let totalFats: Double
    let totalCarbs: Double
    let ingredients: [FoodItem]
}

class MealDataManager {
    static let shared = MealDataManager()
    private init() {}

    private let fileName = "meals.json"
    private var fileURL: URL? {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return documentDirectory?.appendingPathComponent("\(fileName)")
    }

    func saveMeal(_ meal: Meal) {
        guard let url = fileURL else {
            print("File URL is nil.")
            return
        }

        var meals: [Meal] = []
        if let existingData = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            if let decodedMeals = try? decoder.decode([Meal].self, from: existingData) {
                meals = decodedMeals
            }
        }

        meals.append(meal)

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(meals)
            // Ensure the directory exists before saving
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: url)
            print("Meal data saved to: \(url.path)")
        } catch {
            print("Error saving meal data: \(error.localizedDescription)")
        }
    }
}
