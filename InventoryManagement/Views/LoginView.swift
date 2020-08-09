//
//  LoginView.swift
//  InventoryManagement
//
//  Created by Tristan Kreindler on 7/21/20.
//  Copyright © 2020 Tristan Kreindler. All rights reserved.
//

import SwiftUI
import Combine

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @ObservedObject var httpManager: HttpManager
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        VStack {
            WelcomeText()
            UserImage()
            UsernameField(username: $username)
            PasswordField(password: $password)
            if httpManager.loginStatus == LoginStatus.Error {
                Text(httpManager.errorMessage)
                    .offset(y: -10)
                    .foregroundColor(.red)
            }
            Button(action: {
                self.httpManager.postAuth(username: self.username, password: self.password);
            }) {
                LoginButtonContext()
            }
        }
        .padding(.bottom, keyboardHeight)
        .onReceive(keyboardHeightPublisher) {
            keyboardHeight in
            self.keyboardHeight = keyboardHeight
        }
        .padding()
    }
}

struct WelcomeText: View {
    var body: some View {
        Text("Welcome!")
            .font(.largeTitle)
            .fontWeight(.semibold)
            .padding(.bottom, 20)
    }
}

struct UserImage: View {
    var body: some View {
        Image("boomboom")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 150, height: 150)
            .clipped()
            .cornerRadius(150)
            .padding(.bottom, 75)
    }
}

struct UsernameField: View {
    @Binding var username: String
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        TextField("Username", text: $username)
            .padding()
            .background(
                colorScheme == .light ?
                    lightGreyColor :
                    darkGreyColor
        )
        .cornerRadius(5.0)
        .padding(.bottom, 20)
    }
}

struct PasswordField: View {
    @Binding var password: String
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        SecureField("Password", text: $password)
            .padding()
            .background(
                colorScheme == .light ?
                    lightGreyColor :
                darkGreyColor
        )
            .cornerRadius(5.0)
            .padding(.bottom, 20)
    }
}

struct LoginButtonContext: View {
    var body: some View {
        Text("Login")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(Color.green)
            .cornerRadius(15.0)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(httpManager: HttpManager())
    }
}
