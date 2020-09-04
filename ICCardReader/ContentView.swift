//
//  ContentView.swift
//  ICCardReader
//
//  Created by haruki on 2020/09/04.
//  Copyright © 2020 haruki. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var helper = NFCHelper()
    var body: some View {
        
        VStack(alignment: .center, spacing: 8.0){
            Button(action: {
                self.helper.scanning()
            }) {
                 Text("Scan")
                     .font(.system(size: 48, weight: .bold, design: .default))
                     .foregroundColor(Color.white)
                     .frame(width: 320.0)
                     
             }
            .padding(.vertical, 16.0)
            .background(Color(red: 56/255, green: 142/255, blue: 60/255))
            .cornerRadius(4.0)
            .compositingGroup()
            .shadow(color: Color(red: 27/255, green: 94/255, blue: 32/255), radius: 0, x:0 , y:4)
            
            Spacer()
                .frame(height: 32)
            
            Text("ICカードを背面にかざす")
                .font(.system(size: 24, design: .default))
            
            Spacer()
                .frame(height: 8)
            Image("introduction")
            .resizable()
            .scaledToFit()
            .frame(width: 320, height:320)
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
