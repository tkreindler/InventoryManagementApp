//
//  ContentView.swift
//  InventoryManagement
//
//  Created by Tristan Kreindler on 7/16/20.
//  Copyright © 2020 Tristan Kreindler. All rights reserved.
//

import SwiftUI

let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)

let darkGreyColor = Color(red: 32.0/255.0, green: 32.0/255.0, blue: 32.0/255.0, opacity: 1.0)

struct ContentView: View {
    
    @ObservedObject var httpManager = HttpManager()
    
    init() {
        self.httpManager.postAuth()
    }
    
    var body: some View {
        ZStack {
            if httpManager.loginStatus == LoginStatus.Success {
                TabbedView(httpManager: httpManager)
            } else {
                LoginView(httpManager: httpManager)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
