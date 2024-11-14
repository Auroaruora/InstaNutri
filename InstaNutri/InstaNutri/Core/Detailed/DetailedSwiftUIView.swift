//
//  DetailedSwiftUIView.swift
//  InstaNutri
//
//  Created by 谢xiansheng on 11/9/24.
//

import SwiftUI

struct FoodDetailView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("Mixed vegetable salad")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.top, 20)
            
            // Image
            Image("salad") // Replace "saladImage" with the name of your image asset
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .clipShape(Circle())
            
            // Food items and calories
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Grilled Tofu:")
                    Spacer()
                    Text("~150-200")
                }
                HStack {
                    Text("Hard-Boiled Eggs:")
                    Spacer()
                    Text("~140")
                }
                HStack {
                    Text("Edamame:")
                    Spacer()
                    Text("~50-60")
                }
                HStack {
                    Text("Corn Kernels:")
                    Spacer()
                    Text("~30-40")
                }
                HStack {
                    Text("Cherry Tomatoes:")
                    Spacer()
                    Text("~15-20")
                }
                HStack {
                    Text("Cucumber:")
                    Spacer()
                    Text("~5-10")
                }
                HStack {
                    Text("Red Cabbage:")
                    Spacer()
                    Text("~5")
                }
                HStack {
                    Text("Lettuce:")
                    Spacer()
                    Text("~5")
                }
            }
            .padding(.horizontal, 40)
            .font(.body)
            
            // Total Calories
            HStack {
                Text("Total:")
                    .fontWeight(.bold)
                Spacer()
                Text("~485 calories")
                    .fontWeight(.bold)
            }
            .padding(.horizontal, 40)
            .font(.body)
            .padding(.bottom, 20)
        }
        .padding()
    }
}

// Preview Setup
struct FoodDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FoodDetailView()
            .previewDevice("iPhone 14 Pro") // Choose device for preview
    }
}
