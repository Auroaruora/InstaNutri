//
//  LoginView.swift
//  InstaNutri
//
//  Created by Aurora Weng on 11/3/24.
//

import SwiftUI

struct LoginView: View {
    @State var email = ""
    @State var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    //TODO, try to use @State private var email = "" but not working
    var body: some View {
        
        NavigationStack{
            VStack{
                //image
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width:200)
                    .padding(.vertical,32)
                
                //from fields
                VStack(spacing:24){
                    InputView(text: $email,
                              title: "Email Address",
                              placeholder: "name@example.com")
                    .autocapitalization(.none)
                    
                    InputView(text: $password,
                              title: "Password",
                              placeholder: "Enter your password",
                              isSecureField:true)
                    
                }
                .padding(.horizontal)
                .padding(.top,12)
                //sign in button
                Button{
                    Task{
                        try await viewModel.signIn(withEmail: email, password: password)
                    }
                        
                }label:{
                    HStack{
                        Text("SIGN IN")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(.white)
                    .frame(width:UIScreen.main.bounds.width-32,height:48)
                }
                .background(Color(.systemBlue))
                .cornerRadius(10)
                .padding(.top,24)
                
                Spacer()
                //sign up button
                NavigationLink{
                    RegistrationView()
                        .navigationBarBackButtonHidden()
                }label:{
                    HStack(spacing:3){
                        Text("Don't have an account?")
                        Text("Sign up")
                            .fontWeight(.bold)
                    }
                    .font(.system(size:14))
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
