//
//  SwiftUIView.swift
//  InstaNutri
//
//  Created by Zeyu Qiu on 11/9/24.
//

import SwiftUI

struct FoodItem: Identifiable {
    let id = UUID()
    var name: String
    var weight: Double // Changed to match FoodItems
    var calories: Double
    var protein: Double
    var fats: Double
    var carbs: Double
}

struct DetectedView: View {
    @State private var foodItems: [FoodItem]

    // Initialization with FoodItem array
    init(foodItems: [FoodItem]) {
        self._foodItems = State(initialValue: foodItems)
    }

    var body: some View {
        VStack {
            Text("Detected")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)

            if foodItems.isEmpty {
                Text("No food items detected.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach($foodItems) { $item in
                            FoodDetailView(foodItem: $item) {
                                // Delete action
                                foodItems.removeAll { $0.id == item.id }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }

            Button(action: {
                // Handle finish action (e.g., navigate back)
            }) {
                Text("Finish")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
        }
        .background(Color(UIColor.systemGray6))
        .edgesIgnoringSafeArea(.all)
    }
}


// Define the FoodDetailView struct only once
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
                    Text("\(Int(foodItem.calories)) kcal - \(Int(foodItem.weight))g") // Display integers only
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                HStack {
                    NutrientBar(color: .green, value: Int(foodItem.protein), label: "Protein")
                    Spacer()
                    NutrientBar(color: .red, value: Int(foodItem.fats), label: "Fats")
                    Spacer()
                    NutrientBar(color: .yellow, value: Int(foodItem.carbs), label: "Carbs")
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



// Reusable NutrientBar View
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

// EditWeightView for editing weight
struct EditWeightView: View {
    @Binding var foodItem: FoodItem
    @Environment(\.presentationMode) var presentationMode // To dismiss the sheet

    // Computed property to bind the weight as a string
    private var weightBinding: Binding<String> {
        Binding<String>(
            get: { String(Int(foodItem.weight)) }, // Display weight as an integer
            set: { newValue in
                if let newWeight = Double(newValue) {
                    let ratio = newWeight / foodItem.weight // Calculate the ratio
                    foodItem.weight = newWeight
                    foodItem.calories *= ratio
                    foodItem.protein *= ratio
                    foodItem.fats *= ratio
                    foodItem.carbs *= ratio
                }
            }
        )
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Weight for \(foodItem.name)")
                .font(.title2)
                .padding()

            TextField("Enter new weight", text: weightBinding) // Use the computed binding
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
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


// Preview for DetectedView
//struct DetectedView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetectedView()
//    }
//}

