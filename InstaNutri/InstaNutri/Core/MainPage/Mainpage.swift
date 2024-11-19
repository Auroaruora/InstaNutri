import SwiftUI

struct MainPageView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var healthDataViewModel: HealthDataViewModel

    @State private var navigateToCamera = false
    @State private var navigateToProfile = false
    @State private var mealItems: [Meal] = [] // Stores meals loaded from JSON
    
    var body: some View {
        ZStack {
            VStack {
                // Header with Navigation to Profile Page
                HStack {
                    NavigationLink(
                        destination: ProfileView().environmentObject(viewModel)
                            .environmentObject(healthDataViewModel),
                        isActive: $navigateToProfile
                    ) {
                        EmptyView()
                    }
                    Button(action: {
                        navigateToProfile = true
                    }) {
                        Image(systemName: "person.circle.fill")
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
                
                // Calorie Gauge (static values for now)
                VStack {
                    ZStack {
                        // Background circle
                        Circle()
                            .trim(from: 0.0, to: CGFloat(min(Double(totalCaloriesToday) / 2213.0, 1.0)))
                            .stroke(
                                Color.red.opacity(0.5),
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 200, height: 200)
                        
                        // Text inside the circle
                        VStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 30)) // Flame icon size
                            
                            Text("\(totalCaloriesToday) Kcal")
                                .font(.system(size: 30)) // Dynamically resized text
                                .bold()
                                .lineLimit(1)
                            
                            Text("of 2213 kcal")
                                .font(.system(size: 16)) // Smaller text for total goal
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top)
                }

                // Scrollable Food List with Navigation Links
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(mealItems, id: \.time) { item in
                            NavigationLink(destination: MealDetailView(meal: item)) {
                                mealItemView(meal: item)
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
                NavigationLink(
                    destination: CameraView(),
                    isActive: $navigateToCamera
                ) {
                    EmptyView()
                }
                Button(action: {
                    navigateToCamera = true
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
        .onAppear(perform: loadMeals) // Load data when the view appears
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var totalCaloriesToday: Int {
        mealItems.reduce(0) { $0 + Int($1.totalCalories) }
    }
    // Load meals from JSON filtered by today's date
    private func loadMeals() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        
        if let url = MealDataManager.shared.fileURL,
           let data = try? Data(contentsOf: url),
           let meals = try? JSONDecoder().decode([Meal].self, from: data) {
            // Filter meals by today's date
            mealItems = meals.filter { $0.date == today }
        } else {
            print("Failed to load meals from JSON.")
        }
    }
}

// View for individual meal item
struct mealItemView: View {
    let meal: Meal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // Use AsyncImage to load the image from the URL
                if let imageUrl = meal.savedImageUrl {
                    AsyncImage(url: imageUrl) { phase in
                        switch phase {
                        case .empty:
                            ProgressView() // Show a loading indicator
                                .frame(width: 50, height: 50)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50) // Restrict the size
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading) {
                    Text(meal.time) // Display the time as the name
                        .font(.headline)
                    Text("\(Int(meal.totalCalories)) kcal") // Display total calories
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            HStack {
                NutrientInfoView(nutrient: "Protein", amount: Int(meal.totalProtein), color: .green)
                Spacer()
                NutrientInfoView(nutrient: "Fats", amount: Int(meal.totalFats), color: .red)
                Spacer()
                NutrientInfoView(nutrient: "Carbs", amount: Int(meal.totalCarbs), color: .yellow)
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

