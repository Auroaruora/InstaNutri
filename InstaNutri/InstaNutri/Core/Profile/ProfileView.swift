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
                }
                
                // Account Section
                Section("Account") {
                    Button {
                        Task {
                            try await viewModel.signOut()
                        }
                    } label: {
                        SettingRowView(imageName: "arrow.left.circle.fill",
                                       title: "Sign Out",
                                       tintColor: .red)
                    }
                    
                    Button {
                        print("Delete account...")
                    } label: {
                        SettingRowView(imageName: "xmark.circle.fill",
                                       title: "Delete Account",
                                       tintColor: .red)
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(HealthDataViewModel())
}
