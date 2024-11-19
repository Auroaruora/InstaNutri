//
//  DetailedSwiftUIView.swift
//  InstaNutri
//
//  Created by 谢xiansheng on 11/9/24.
//

import SwiftUI

struct MealDetailView: View {
    let meal: Meal
    
    var body: some View {
        VStack(spacing: 20) {
            // Title (Meal Time)
            Text(meal.time)
                .font(.title)
                .fontWeight(.semibold)
                .padding(.top, 20)
            
            // Display the actual photo or a fallback
            if let imageUrl = meal.savedImageUrl {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView() // Show loading indicator
                            .frame(width: 200, height: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                    case .failure:
                        Image(systemName: "photo") // Fallback image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "photo") // Fallback if URL is nil
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.gray)
            }
            
            // Ingredients List
            VStack(alignment: .leading, spacing: 10) {
                ForEach(0..<meal.ingredients.count, id: \.self) { index in
                    let ingredient = meal.ingredients[index]
                    HStack {
                        Text(ingredient.name) // Name of the ingredient
                        Spacer()
                        Text("~\(Int(ingredient.calories)) cal") // Approximate calories
                    }
                }
            }
            .padding(.horizontal, 40)
            .font(.body)
            
            // Total Calories
            HStack {
                Text("Total:")
                    .fontWeight(.bold)
                Spacer()
                Text("\(Int(meal.totalCalories)) calories")
                    .fontWeight(.bold)
            }
            .padding(.horizontal, 40)
            .font(.body)
            .padding(.bottom, 20)
        }
        .padding()
    }
}


