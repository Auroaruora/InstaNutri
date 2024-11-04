//
//  User.swift
//  InstaNutri
//
//  Created by Aurora Weng on 11/3/24.
//

import Foundation

struct User: Identifiable, Codable{
    let id: String
    let fullname: String
    let email: String
    
    var initialis: String{
        let formatter = PersonNameComponentsFormatter()
        if let componets = formatter.personNameComponents(from: fullname){
            formatter.style = .abbreviated
            return formatter.string(from: componets)
        }
        return ""
    }
}

extension User{
    static var MOCK_USER = User(id:NSUUID().uuidString,fullname: "Aurora Weng",email:"test@gmail.com")
}
