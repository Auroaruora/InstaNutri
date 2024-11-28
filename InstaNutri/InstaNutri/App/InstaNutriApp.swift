//
//  InstaNutriApp.swift
//  InstaNutri
//
//  Created by Aurora Weng on 11/3/24.
//

import SwiftUI
import Firebase

@main
struct InstaNutriApp: App {
    @StateObject var viewModel = AuthViewModel()
    @StateObject var healthDataViewModel = HealthDataViewModel() // Add HealthDataViewModel
    @StateObject private var networkMonitor = NetworkMonitor()


    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
                    .environmentObject(viewModel) // Inject AuthViewModel
                    .environmentObject(healthDataViewModel) // Inject HealthDataViewModel
                    .environmentObject(networkMonitor)

            }
        }
    }
}
