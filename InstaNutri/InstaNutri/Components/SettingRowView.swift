//
//  SettingRowView.swift
//  InstaNutri
//
//  Created by Aurora Weng on 11/3/24.
//

import SwiftUI

struct SettingRowView: View {
    let imageName: String
    let title: String
    let tintColor: Color
    
    var body: some View {
        HStack(spacing:12){
            Image(systemName: imageName)
                .imageScale(.small)
                .font(.title)
                .foregroundColor(tintColor)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.black)
        }
    }
}
    

#Preview {
    SettingRowView(imageName:"gear",title:"Version",tintColor: Color(.systemGray))
}
