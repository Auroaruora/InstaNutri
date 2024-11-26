//
//  ContentView.swift
//  InstaNutri
//
//  Created by Aurora Weng on 11/3/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel:AuthViewModel
    @EnvironmentObject var healthDataViewModel: HealthDataViewModel

    var body: some View {
        Group{
            if viewModel.userSession != nil{
                if let _ = viewModel.currentUser {
                    MainPageView()
                } else {
                    LoadingView()
                }
            }else{
                LoginView()
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
            Text("Fetching your data...")
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    ContentView()
}
