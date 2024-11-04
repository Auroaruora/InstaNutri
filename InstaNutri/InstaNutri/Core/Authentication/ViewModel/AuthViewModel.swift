//
//  AuthViewModel.swift
//  InstaNutri
//
//  Created by Aurora Weng on 11/4/24.
//

import Foundation
import Firebase
import FirebaseAuth


class AuthViewModel:ObservableObject{
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init(){
        
    }
    
    func signIn(withEmail email: String, password: String)async throws{
        print("Sign in ...")
    }
    
    func createUser(withEmail email: String, password: String, fullname:String)async throws{
        print("Create user ...")
    }
    func signOut(){
        
    }
    func deleteAccount(){
        
    }
    func fetchUser() async{
        
    }
}
