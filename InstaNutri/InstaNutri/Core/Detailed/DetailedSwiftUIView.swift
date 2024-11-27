//
//  DetailedSwiftUIView.swift
//  InstaNutri
//
//  Created by 谢xiansheng on 11/9/24.
//

import SwiftUI
import Foundation

struct MealDetailView: View {
    let meal: Meal
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with Meal Time
            HStack {
                Spacer() // Center-align the time
                Text(meal.time)
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.top, 20)
                Spacer()
            }
            
            // Image Section
            if let imageUrl = meal.savedImageUrl {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 150, height: 150)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 2))
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.gray)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.gray)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
            
            // Nutritional Breakdown
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Total Calories:")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Spacer()
                    Text("\(Int(meal.totalCalories)) kcal")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                HStack {
                    Text("Protein:")
                        .foregroundColor(.primary)
                    Spacer()
                    Text("\(Int(meal.totalProtein))g")
                        .foregroundColor(Color(UIColor(red: 110 / 255.0, green: 168 / 255.0, blue: 126 / 255.0, alpha: 1.0)))
                }
                HStack {
                    Text("Fats:")
                        .foregroundColor(.primary)
                    Spacer()
                    Text("\(Int(meal.totalFats))g")
                        .foregroundColor(Color(UIColor(red: 254 / 255.0, green: 179 / 255.0, blue: 66 / 255.0, alpha: 1.0)))
                }
                HStack {
                    Text("Carbs:")
                        .foregroundColor(.primary)
                    Spacer()
                    Text("\(Int(meal.totalCarbs))g")
                        .foregroundColor(Color(UIColor(red: 254 / 255.0, green: 93 / 255.0, blue: 55 / 255.0, alpha: 1.0)))
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal, 20)
            
            // Scrollable Ingredients List
            VStack(alignment: .leading, spacing: 12) {
                Text("Ingredients")
                    .font(.headline)
                    .padding(.bottom, 5)
                ScrollView {
                    ForEach(0..<meal.ingredients.count, id: \.self) { index in
                        let ingredient = meal.ingredients[index]
                        HStack {
                            Text(ingredient.name)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(Int(ingredient.calories)) kcal")
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 5)
                    }
                }
                .frame(height: 200) // Set a fixed height for the ingredients list
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal, 20)
            
            Spacer() // Push everything to the top
        }
        .padding()
        .background(Color(.systemBackground))
    }
}


#Preview {
    
    let fakeMeal = Meal(
        date: "2024-11-22",
        time: "12:30 PM",
        totalCalories: 650.0,
        totalProtein: 45.0,
        totalFats: 20.0,
        totalCarbs: 75.0,
        ingredients: [
            FoodItem(
                name: "Grilled Chicken Breast",
                weight: 150.0,
                calories: 165.0,
                protein: 31.0,
                fats: 3.5,
                carbs: 0.0
            ),
            FoodItem(
                name: "Steamed Broccoli",
                weight: 100.0,
                calories: 35.0,
                protein: 3.0,
                fats: 0.4,
                carbs: 7.0
            ),
            FoodItem(
                name: "Brown Rice",
                weight: 200.0,
                calories: 216.0,
                protein: 5.0,
                fats: 1.8,
                carbs: 45.0
            ),
            FoodItem(
                name: "Olive Oil",
                weight: 10.0,
                calories: 88.0,
                protein: 0.0,
                fats: 10.0,
                carbs: 0.0
            )
        ],
        savedImageUrl: Bundle.main.url(forResource: "salad", withExtension: "png")
    )

    MealDetailView(meal: fakeMeal)
}

