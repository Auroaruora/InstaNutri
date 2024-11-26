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
    let savedImageUrl: URL?
}

class MealDataManager {
    static let shared = MealDataManager()
    private init() {}

    private let fileName = "meals.json"
    var fileURL: URL? {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return documentDirectory?.appendingPathComponent(fileName)
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

extension MealDataManager {
    func loadMealsForLast7Days() -> [Meal]? {
        guard let url = fileURL else {
            print("File URL is nil.")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            var meals = try decoder.decode([Meal].self, from: data)

            // Create a DateFormatter to parse "yyyy-MM-dd"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

            // Get the current date and calculate the date 7 days ago
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date()) // Start of today's day
            guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: today) else {
                print("Failed to calculate the date 7 days ago.")
                return nil
            }

            // Filter meals from the last 7 days
            meals = meals.filter {
                if let mealDate = dateFormatter.date(from: $0.date) {
                    return mealDate >= sevenDaysAgo && mealDate <= today
                } else {
                    print("Invalid date format for meal: \($0.date)")
                    return false
                }
            }

            // Ensure there are at least 6 meals in the last 7 days
            guard meals.count >= 6 else {
                print("Not enough meals in the past 7 days for analysis.")
                return nil
            }

            return meals
        } catch {
            print("Error loading meal data: \(error.localizedDescription)")
            return nil
        }
    }
}
