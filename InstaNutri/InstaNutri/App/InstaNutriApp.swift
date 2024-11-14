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
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
