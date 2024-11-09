//
//  SwiftUIView.swift
//  InstaNutri
//
//  Created by Zeyu Qiu on 11/9/24.
//

import SwiftUI

struct FoodItem: Identifiable {
    let id = UUID()
    let name: String
    let calories: Int
    var weight: String
    let protein: Int
    let fats: Int
    let carbs: Int
}

struct DetectedView: View {
    @State private var foodItems = [
        FoodItem(name: "Tofu", calories: 100, weight: "100g", protein: 8, fats: 5, carbs: 2),
        FoodItem(name: "Edamame", calories: 100, weight: "100g", protein: 11, fats: 5, carbs: 9),
        FoodItem(name: "Hard-Boiled Egg", calories: 70, weight: "50g", protein: 6, fats: 5, carbs: 1),
        FoodItem(name: "Cherry Tomatoes", calories: 10, weight: "50g", protein: 1, fats: 0, carbs: 2),
        FoodItem(name: "Corn Kernels", calories: 25, weight: "50g", protein: 1, fats: 0, carbs: 6),
        FoodItem(name: "Cucumbers", calories: 5, weight: "50g", protein: 0, fats: 0, carbs: 1)
    ]
    
    var body: some View {
        VStack {
            Text("Detected")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 60)
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach($foodItems) { $item in
                        FoodDetailView(foodItem: $item) {
                            foodItems.removeAll { $0.id == item.id }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
            
            Button(action: {
                // Add finish action here
            }) {
                Text("Finish")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
            }
        }
        .background(Color(UIColor.systemGray6))
        .edgesIgnoringSafeArea(.all)
    }
}

struct FoodDetailView: View {
    @Binding var foodItem: FoodItem
    let deleteAction: () -> Void
    @State private var showDeleteAlert = false
    @State private var showEditWeightSheet = false
    @State private var showActionSheet = false

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                Text(foodItem.name)
                    .font(.headline)
                
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(foodItem.calories) kcal - \(foodItem.weight)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                HStack {
                    NutrientBar(color: .green, value: foodItem.protein, label: "Protein")
                    Spacer()
                    NutrientBar(color: .red, value: foodItem.fats, label: "Fats")
                    Spacer()
                    NutrientBar(color: .yellow, value: foodItem.carbs, label: "Carbs")
                }
            }
            .padding(.leading, 8)

            Spacer()

            VStack {
                Button(action: {
                    showActionSheet = true
                }) {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                .actionSheet(isPresented: $showActionSheet) {
                    ActionSheet(
                        title: Text("Options"),
                        buttons: [
                            .default(Text("Edit")) {
                                showEditWeightSheet = true
                            },
                            .cancel()
                        ]
                    )
                }
                .sheet(isPresented: $showEditWeightSheet) {
                    EditWeightView(foodItem: $foodItem) // Pass the food item binding to the edit view
                }

                Spacer()
                
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.gray)
                }
            }
            .padding(.trailing, 16)
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Delete Entry"),
                    message: Text("Are you sure you want to delete this entry?"),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteAction()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).stroke(Color.yellow.opacity(0.6), lineWidth: 1))
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct NutrientBar: View {
    let color: Color
    let value: Int
    let label: String

    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 10, height: 50)
                    .foregroundColor(.gray.opacity(0.2))
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 10, height: CGFloat(value))
                    .foregroundColor(color)
            }
            Text("\(value)g")
                .font(.subheadline)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct DetectedView_Previews: PreviewProvider {
    static var previews: some View {
        DetectedView()
    }
}

struct EditWeightView: View {
    @Binding var foodItem: FoodItem
    @Environment(\.presentationMode) var presentationMode // To dismiss the sheet

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Weight for \(foodItem.name)")
                .font(.title2)
                .padding()

            TextField("Enter new weight", text: $foodItem.weight)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Save") {
                presentationMode.wrappedValue.dismiss() // Dismiss the sheet after saving
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            Spacer()
        }
        .padding()
    }
}
