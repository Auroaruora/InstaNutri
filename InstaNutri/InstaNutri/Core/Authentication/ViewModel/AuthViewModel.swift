//
//  AuthViewModel.swift
//  InstaNutri
//
//  Created by Aurora Weng on 11/4/24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel:ObservableObject{
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init(){
        self.userSession = Auth.auth().currentUser
        Task{
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String)async throws{
        do{
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        }catch{
            print("DEBUG: Failed to sign in with error\(error.localizedDescription)")
            throw error
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname:String)async throws{
        do{
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id:result.user.uid,fullname:fullname,email:email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
        }catch{
            print("DEBUG:Failed to create user with error\(error.localizedDescription)")
        }
    }
    func signOut() async {
        do {
            try Auth.auth().signOut() // Sign out user on backend
            
            // Ensure UI updates are on the main thread
            await MainActor.run {
                self.userSession = nil // Wipes out user session
                self.currentUser = nil // Wipes out current user data model
            }
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    func deleteAccount() async {
        guard let user = Auth.auth().currentUser else {
            print("DEBUG: No authenticated user found.")
            return
        }
        
        // Step 1: Delete user data from Firestore
        do {
            try await Firestore.firestore().collection("users").document(user.uid).delete()
            print("DEBUG: User data successfully deleted from Firestore.")
        } catch {
            print("DEBUG: Failed to delete user data from Firestore with error \(error.localizedDescription)")
            return
        }
        
        // Step 2: Delete the user's Firebase Authentication account
        do {
            try await user.delete()
            print("DEBUG: User account successfully deleted from Firebase Authentication.")
            
            // Step 3: Clear local user session
            await MainActor.run {
                self.userSession = nil
                self.currentUser = nil
            }
        } catch {
            print("DEBUG: Failed to delete user account with error \(error.localizedDescription)")
        }
    }
    func fetchUser() async{
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument()else{return}
        self.currentUser = try? snapshot.data(as:User.self)
        //print("DEBUG: Current user is \(self.currentUser)")
        
    }
}
