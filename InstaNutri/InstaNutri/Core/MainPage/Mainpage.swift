import SwiftUI

struct MainPageView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var healthDataViewModel: HealthDataViewModel

    @State private var navigateToCamera = false
    @State private var navigateToProfile = false
    @State private var mealItems: [Meal] = [] // Stores meals loaded from JSON
    
    @State private var selectedDate: Date = Date()
    @State private var scrollViewDateRangeBase: Date = Date() // Base date for ScrollView date range
    @State private var isDatePickerPresented: Bool = false
    
    @AppStorage("recommendedCalories") var calorieIntake: Int = 2000
    @AppStorage("recommendedFat") var recommendedFat: Int = 67
    @AppStorage("recommendedCarbs") var recommendedCarbs: Int = 250
    @AppStorage("recommendedProteins") var recommendedProteins: Int = 100
    
    //@State private var navigateToCamera = false
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
                        if let user = viewModel.currentUser {
                            Text("Welcome")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(user.fullname)
                                .font(.title2)
                                .bold()
                        } else {
                            Text("Welcome, Guest")
                                .font(.title2)
                                .bold()
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top)
                
                VStack {
                    HStack {
                        // Horizontal Scrollable Section
                        ScrollViewReader { proxy in
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    let dateRange = (-3...3).map { offset in
                                        Calendar.current.date(byAdding: .day, value: offset, to: scrollViewDateRangeBase)!
                                    }
                                    ForEach(dateRange, id: \.self) { currentDate in
                                        let isSelected = Calendar.current.isDate(currentDate, inSameDayAs: selectedDate)
                                        
                                        Button(action: {
                                            selectedDate = currentDate
                                        }) {
                                            VStack(spacing: 5) {
                                                Text(shortDayLabel(for: currentDate)) // Day abbreviation (e.g., "Thu")
                                                    .font(.caption)
                                                    .foregroundColor(isSelected ? .white : .gray)
                                                
                                                Text(dateLabel(for: currentDate)) // Day number (e.g., "22")
                                                    .font(.headline)
                                                    .foregroundColor(isSelected ? .white : .black)
                                            }
                                            .frame(width: 50, height: 70)
                                            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                                            .cornerRadius(10)
                                        }
                                        .id(currentDate) // Assign a unique ID for each date
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .onChange(of: selectedDate) { _ in
                                loadMeals() // Reload meals when the selected date changes
                            }
                            .onChange(of: scrollViewDateRangeBase) { _ in
                                proxy.scrollTo(selectedDate, anchor: .center)
                            }
                            .onAppear {
                                // Center the ScrollView on the default selected date
                                proxy.scrollTo(selectedDate, anchor: .center)
                            }
                        }

                        // Calendar Icon
                        VStack {
                            Button(action: {
                                isDatePickerPresented.toggle()
                            }) {
                                Image(systemName: "calendar")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.blue)
                            }
                            
                            Text(formattedMonth(for: selectedDate))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .sheet(isPresented: $isDatePickerPresented) {
                            VStack {
                                DatePicker(
                                    "Pick a Date",
                                    selection: $selectedDate, // Syncs automatically
                                    displayedComponents: [.date]
                                )
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .padding()
                                
                                Button("Done") {
                                    // Update scrollViewDateRangeBase when closing the calendar
                                    scrollViewDateRangeBase = selectedDate
                                    loadMeals() // Reload meals for the newly selected date
                                    isDatePickerPresented = false
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .padding()
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6)) // Background color
                    .cornerRadius(15) // Rounded corners
                    .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 3) // Shadow effect
                    .padding(5)
                    .padding(.horizontal, 15)

                    
                    Spacer() // Optional spacer for alignment
                    
                    // Calorie Gauge
                    VStack {
                        HStack {
                            // Circle Gauge closer to the center
                            ZStack {
                                Circle()
                                    .stroke(
                                        Color.gray.opacity(0.3),
                                        style: StrokeStyle(lineWidth: 15, lineCap: .round)
                                    )
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 150, height: 150) // Smaller size

                                Circle()
                                    .trim(from: 0.0, to: CGFloat(min(Double(totalCaloriesToday) / Double(calorieIntake), 1.0)))
                                    .stroke(
                                        Color.red.opacity(0.5),
                                        style: StrokeStyle(lineWidth: 15, lineCap: .round)
                                    )
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 150, height: 150)

                                VStack {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(.red)
                                        .font(.system(size: 25))

                                    Text("\(totalCaloriesToday) Kcal")
                                        .font(.system(size: 25))
                                        .bold()
                                        .lineLimit(1)

                                    Text("of \(calorieIntake) kcal")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.trailing, 20) // Space between the circle and text

                            // Macronutrients on the Right
                            VStack(alignment: .leading, spacing: 10) {
                                VStack(alignment: .leading) {
                                    Text("\(totalProteinToday)g / \(recommendedProteins)g")
                                        .font(.system(size: 16))
                                        .bold()
                                        .foregroundColor(.green)
                                    Text("Protein")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }

                                VStack(alignment: .leading) {
                                    Text("\(totalFatsToday)g / \(recommendedFat)g")
                                        .font(.system(size: 16))
                                        .bold()
                                        .foregroundColor(.red)
                                    Text("Fats")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }

                                VStack(alignment: .leading) {
                                    Text("\(totalCarbsToday)g / \(recommendedCarbs)g")
                                        .font(.system(size: 16))
                                        .bold()
                                        .foregroundColor(.yellow)
                                    Text("Carbs")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: 150) // Ensure consistent height and center alignment
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(15)
                        .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 3)
                        .padding(5)
                        .padding(.horizontal, 15)
                    }

                    // Scrollable Food List
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(mealItems, id: \.time) { item in
                                NavigationLink(destination: MealDetailView(meal: item)) {
                                    mealItemView(meal: item)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 80)
                }
            }
            
            // Fixed Add Button
            VStack {
                Spacer()
                NavigationLink(
                    destination: CameraView(onFinish: {
                        navigateToCamera = false // Return to MainPage when finished
                    }),
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
        .onAppear(perform: loadMeals)
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
    }

    func shortDayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE" // Abbreviation of the day (e.g., "Mo", "Tu")
        return formatter.string(from: date)
    }
    
    func formattedMonth(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM" // e.g., "Nov"
        return formatter.string(from: date)
    }

    func dateLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d" // Day number (e.g., "23")
        return formatter.string(from: date)
    }
    
    private var totalCaloriesToday: Int {
        mealItems.reduce(0) { $0 + Int($1.totalCalories) }
    }
    
    private var totalProteinToday: Int {
        mealItems.reduce(0) { $0 + Int($1.totalProtein) }
    }

    private var totalFatsToday: Int {
        mealItems.reduce(0) { $0 + Int($1.totalFats) }
    }

    private var totalCarbsToday: Int {
        mealItems.reduce(0) { $0 + Int($1.totalCarbs) }
    }
    
    private func loadMeals() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedDateString = dateFormatter.string(from: selectedDate)
        
        if let url = MealDataManager.shared.fileURL,
           let data = try? Data(contentsOf: url),
           let meals = try? JSONDecoder().decode([Meal].self, from: data) {
            mealItems = meals.filter { $0.date == selectedDateString }
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
        .background(Color(UIColor.systemGray6)) // Background color
        .cornerRadius(15) // Rounded corners
        .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 3) // Shadow effect
        .padding(5)
        .padding(.horizontal, 15)
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
        .environmentObject(AuthViewModel())
        .environmentObject(HealthDataViewModel())
}
