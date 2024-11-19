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
            
            // Placeholder Image
            Image("salad") // Replace "salad" with your image asset's name
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .clipShape(Circle())
            
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



