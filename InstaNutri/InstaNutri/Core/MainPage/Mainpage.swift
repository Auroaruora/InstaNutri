import SwiftUI

struct MainPageView: View {
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    // Header with Navigation to Profile Page
                    HStack {
                        NavigationLink(destination: Text("Profile Page Placeholder")) {
                            Image(systemName: "person.circle.fill") // Placeholder for profile image
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .padding(.leading)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Welcome")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("CU Student")
                                .font(.title2)
                                .bold()
                        }
                        
                        Spacer()
                    }
                    .padding(.top)
                    
                    // Calorie Gauge
                    VStack {
                        ZStack {
                            Circle()
                                .trim(from: 0.0, to: 0.75)
                                .stroke(Color.red.opacity(0.5), lineWidth: 20)
                                .rotationEffect(.degrees(180))
                                .frame(width: 150, height: 150)
                            
                            VStack {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.red)
                                Text("1721 Kcal")
                                    .font(.title)
                                    .bold()
                                Text("of 2213 kcal")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top)
                        
                        Spacer().frame(height: 20)
                    }

                    // Scrollable Food List with Navigation Links
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(foodItems, id: \.name) { item in
                                NavigationLink(destination: Text("\(item.name) Details Placeholder")) {
                                    FoodItemView(foodItem: item)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 80)
                }
                
                // Fixed Add Button
                VStack {
                    Spacer()
                    Button(action: {
                        // Action to add food (optional)
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Color.green)
                            .clipShape(Circle())
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Data structure for FoodItem
struct FoodItem: Identifiable {
    let id = UUID()
    let name: String
    let calories: Int
    let protein: Int
    let fats: Int
    let carbs: Int
    let emoji: String
}

// List of hardcoded food items
let foodItems = [
    FoodItem(name: "Salad with eggs", calories: 294, protein: 12, fats: 22, carbs: 42, emoji: "🥗"),
    FoodItem(name: "Pancakes", calories: 294, protein: 12, fats: 22, carbs: 42, emoji: "🥞"),
    FoodItem(name: "Avocado Dish", calories: 294, protein: 12, fats: 32, carbs: 12, emoji: "🥑"),
    FoodItem(name: "Fruit Salad", calories: 150, protein: 2, fats: 0, carbs: 38, emoji: "🍇"),
    FoodItem(name: "Grilled Chicken", calories: 200, protein: 30, fats: 5, carbs: 0, emoji: "🍗"),
    FoodItem(name: "Smoothie", calories: 180, protein: 5, fats: 3, carbs: 32, emoji: "🍹")
]

// Food Item View
struct FoodItemView: View {
    let foodItem: FoodItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(foodItem.emoji)
                    .font(.largeTitle)
                VStack(alignment: .leading) {
                    Text(foodItem.name)
                        .font(.headline)
                    Text("\(foodItem.calories) kcal - 100g")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
            }
            
            HStack {
                NutrientInfoView(nutrient: "Protein", amount: foodItem.protein, color: .green)
                Spacer()
                NutrientInfoView(nutrient: "Fats", amount: foodItem.fats, color: .red)
                Spacer()
                NutrientInfoView(nutrient: "Carbs", amount: foodItem.carbs, color: .yellow)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
}

// Nutrient Info View
struct NutrientInfoView: View {
    let nutrient: String
    let amount: Int
    let color: Color
    
    var body: some View {
        VStack {
            Text("\(amount)g")
                .bold()
            Text(nutrient)
                .font(.footnote)
                .foregroundColor(color)
        }
    }
}

#Preview {
    MainPageView()
}

