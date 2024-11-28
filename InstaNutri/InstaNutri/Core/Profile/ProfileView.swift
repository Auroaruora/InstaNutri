//
//  ProfileView.swift
//  InstaNutri
//
//  Created by Aurora Weng on 11/3/24.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var healthDataViewModel: HealthDataViewModel
    
    var body: some View {
        if let user = viewModel.currentUser {
            List {
                // User Information Section
                Section {
                    HStack {
                        Text(user.initialis)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Color(.systemGray3))
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.fullname)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.top, 4)
                            Text(user.email)
                                .font(.footnote)
                        }
                    }
                }
                
                // General Section
                Section("General") {
                    Button {
                        print("Accessing Personal Information...")
                    } label: {
                        SettingRowView(imageName: "gear",
                                       title: "Personal Information",
                                       tintColor: .gray)
                    }
                    
                    // HealthKit Permission Button
                    Button {
                        healthDataViewModel.requestHealthAuthorization()
                    } label: {
                        SettingRowView(imageName: "heart.fill",
                                       title: "Enable Health Data",
                                       tintColor: .pink)
                    }
                    
                    NavigationLink(destination: SetupPage()) {
                        SettingRowView(imageName: "person.crop.circle.fill",
                                       title: "Ask AI for Calorie Recommendation",
                                       tintColor: Color(UIColor(red: 154 / 255.0, green: 194 / 255.0, blue: 208 / 255.0, alpha: 1.0))
)
                    }
                    NavigationLink(destination: AdviceSwiftUIView()) {
                                            SettingRowView(imageName: "person.crop.circle.fill",
                                                           title: "Ask AI for Nutrition Advice",
                                                           tintColor: Color(UIColor(red: 154 / 255.0, green: 194 / 255.0, blue: 208 / 255.0, alpha: 1.0))
)
                                        }
                }
                
                // Account Section
                Section("Account") {
                    Button {
                        Task {
                            await viewModel.signOut()
                        }
                    } label: {
                        SettingRowView(imageName: "arrow.left.circle.fill",
                                       title: "Sign Out",
                                       tintColor: Color(UIColor(red: 255 / 255.0, green: 93 / 255.0, blue: 55 / 255.0, alpha: 1.0)))
                    }
                    
                    Button {
                        print("Delete account...")
                    } label: {
                        SettingRowView(imageName: "xmark.circle.fill",
                                       title: "Delete Account",
                                       tintColor: Color(UIColor(red: 255 / 255.0, green: 93 / 255.0, blue: 55 / 255.0, alpha: 1.0)))
                    }
                }
            }
            .alert(isPresented: $healthDataViewModel.showHealthSettingsAlert) {
                Alert(
                    title: Text("Health App Permission"),
                    message: Text("You are redirecting to the Health app to change permissions. Do you want to continue?"),
                    primaryButton: .default(Text("Yes")) {
                        healthDataViewModel.openHealthSettings()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(HealthDataViewModel())
}
