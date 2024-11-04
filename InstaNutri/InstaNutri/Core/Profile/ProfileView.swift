//
//  ProfileView.swift
//  InstaNutri
//
//  Created by Aurora Weng on 11/3/24.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        if let user = viewModel.currentUser{
            List{
                Section{
                    HStack{
                        Text(user.initialis)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width:72,height:72)
                            .background(Color(.systemGray3))
                            .clipShape(Circle())
                        VStack(alignment:.leading,spacing:4){
                            Text(user.fullname)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.top,4)
                            Text(user.email)
                                .font(.footnote)
                                //.accentColor(.gray)
                        }
                    }
                }
                Section("General"){
                    HStack{
                        Button{
                            print("Accessing Personal Information..")
                        }label:{
                            SettingRowView(imageName:"gear",
                                            title:"Personal Information",
                                           tintColor: .gray)
                        }
                    }
                    
                }
                Section("Account"){
                    Button{
                        print("Sign out..")
                    }label:{
                        SettingRowView(imageName:"arrow.left.circle.fill",
                                        title:"Sign Out",
                                       tintColor: .red)
                    }
                    Button{
                        print("Delete account..")
                    }label:{
                        SettingRowView(imageName:"xmark.circle.fill",
                                        title:"Delete Account",
                                       tintColor: .red)
                    }
                    
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
