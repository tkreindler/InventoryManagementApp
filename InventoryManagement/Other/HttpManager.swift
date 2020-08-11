//
//  HttpAuth.swift
//  InventoryManagement
//
//  Created by Tristan Kreindler on 7/17/20.
//  Copyright © 2020 Tristan Kreindler. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class HttpManager : ObservableObject {
    // the published login status
    @Published var loginStatus: LoginStatus = .NotAttempted
    
    var errorMessage: String = ""
    
    /// check if the authentication stored in cookies is proper
    func checkAuth() {
        let url = URL(string: "\(DebugLoginInfo.baseURL)/checkauth")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // send asynchronous http request
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            // unwrap all values and do assertions
            guard let response = response as? HTTPURLResponse,
                // check for fundamental networking error
                error == nil else {
                print("error", error ?? "Unknown error")
                return
            }
            
            let localStatus: LoginStatus = response.statusCode / 100 == 2 ? .Success : .NotAttempted
            
            // run UI updates on the main thread
            DispatchQueue.main.async {
                // set the login status
                self.loginStatus = localStatus
            }
        }.resume()
    }
    
    /// Log the user in to the server using stored credentials
    func postAuth() {
        guard let username = KeychainWrapper.standard.string(forKey: "com.tristankreindler.InventoryManagement.username") else {
            print("Error fetching possibly nonexistant username")
            return
        }
        guard let password = KeychainWrapper.standard.string(forKey: "com.tristankreindler.InventoryManagement.password") else {
            print("Error fetching possibly nonexistant password")
            return
        }
        
        // post auth normally without storing info
        postAuth(username: username, password: password, storeInfo: false)
    }
    
    /// Log the user in to the server and store the login with cookies
    func postAuth(username: String, password: String, storeInfo: Bool = true) {
        guard !username.isEmpty, !password.isEmpty else {
            self.errorMessage = "You must submit a username and password"
            self.loginStatus = .Error
            return
        }
        
        if storeInfo {
            // store info in the keychain
            if !KeychainWrapper.standard.set(username, forKey: "com.tristankreindler.InventoryManagement.username") {
                print("Failed setting username in keychain")
            }
            if !KeychainWrapper.standard.set(password, forKey: "com.tristankreindler.InventoryManagement.password") {
                print("Failed setting password in keychain")
            }
        }
        
        let url = URL(string: "\(DebugLoginInfo.baseURL)/authenticate").unsafelyUnwrapped

        let body: [String: String] = ["username": username, "password": password]

        let finalBody = try! JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // send asynchronous http request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // unwrap all values and do assertions
            guard let data = data,
                let response = response as? HTTPURLResponse,
                // check for fundamental networking error
                error == nil else {
                print("error", error ?? "Unknown error")
                return
            }
            
            var localStatus: LoginStatus;
            
            let userDefaults = UserDefaults.standard
            
            if response.statusCode == 200 {
                
                let authtoken = response.allHeaderFields["Set-Cookie"] as! String;
                
                userDefaults.set(authtoken, forKey: "authstring");
                
                localStatus = .Success
            } else {
                localStatus = .Error
                if let localError = String(data: data, encoding: .utf8) {
                    self.errorMessage = localError
                } else {
                    self.errorMessage = "Unknown error"
                    print("Error: there was no error message provided with HTTP response \(response.statusCode)")
                }
            }
            
            // run UI updates on the main thread
            DispatchQueue.main.async {
                // set the login status
                self.loginStatus = localStatus
            }
        }.resume()
    }
    
    /// send a get request to itemTypes
    func getItemTypes(sender: @escaping ([ItemType]) -> Void) {
        let url = URL(string: "\(DebugLoginInfo.baseURL)/itemtypes").unsafelyUnwrapped
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // send asynchronous http request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // unwrap all values and do assertions
            guard let data = data,
                let response = response as? HTTPURLResponse,
                // check for fundamental networking error
                error == nil else {
                print("error", error ?? "Unknown error")
                return
            }
            
            // check for unauthorized which means we'd have to login again
            guard response.statusCode / 100 == 2 else {
                if response.statusCode == 401 {
                    print("Received unauthorized response, going back to login page.")
                } else {
                    print("Error, received unexpected response \(response.statusCode)")
                }
                // switch back to main page
                DispatchQueue.main.async {
                    // set the login status
                    self.loginStatus = .NotAttempted
                    self.postAuth()
                }
                return
            }
            
            guard let itemTypes = try? JSONDecoder().decode([ItemType].self, from: data) else {
                
                print("Error parsing response JSON")
                return
            }
            
            // send value back to sender
            sender(itemTypes)
            
        }.resume()
    }
    
    /// send a get request to itemTypes
    func getItems(sender: @escaping ([Item]) -> Void) {
        let url = URL(string: "\(DebugLoginInfo.baseURL)/items")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // send asynchronous http request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // unwrap all values and do assertions
            guard let data = data,
                let response = response as? HTTPURLResponse,
                // check for fundamental networking error
                error == nil else {
                print("error", error ?? "Unknown error")
                return
            }
            
            // check for unauthorized which means we'd have to login again
            guard response.statusCode / 100 == 2 else {
                if response.statusCode == 401 {
                    print("Received unauthorized response, going back to login page.")
                } else {
                    print("Error, received unexpected response \(response.statusCode)")
                }
                // switch back to main page
                DispatchQueue.main.async {
                    // set the login status
                    self.loginStatus = .NotAttempted
                    self.postAuth()
                }
                return
            }
            
            guard let items = try? JSONDecoder().decode([Item].self, from: data) else {
                
                print("Error parsing response JSON")
                return
            }
            
            // send value back to sender
            sender(items)
            
        }.resume()
    }
    
    /// send a get request to itemTypes
    func getItemsByType(upc: Int64, sender: @escaping ([Item]) -> Void) {
        let url = URL(string: "\(DebugLoginInfo.baseURL)/items/type/\(upc)").unsafelyUnwrapped
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // send asynchronous http request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // unwrap all values and do assertions
            guard let data = data,
                let response = response as? HTTPURLResponse,
                // check for fundamental networking error
                error == nil else {
                print("error", error ?? "Unknown error")
                return
            }
            
            // check for unauthorized which means we'd have to login again
            guard response.statusCode / 100 == 2 else {
                if response.statusCode == 401 {
                    print("Received unauthorized response, going back to login page.")
                } else {
                    print("Error, received unexpected response \(response.statusCode)")
                }
                // switch back to main page
                DispatchQueue.main.async {
                    // set the login status
                    self.loginStatus = .NotAttempted
                    self.postAuth()
                }
                return
            }
            
            guard let items = try? JSONDecoder().decode([Item].self, from: data) else {
                
                print("Error parsing response JSON")
                return
            }
            
            // send value back to sender
            sender(items)
            
        }.resume()
    }
    
    /// send a get request to itemTypes
    func getItemType(upc: Int64, sender: @escaping (ItemType) -> Void) {
        let url = URL(string: "\(DebugLoginInfo.baseURL)/itemtypes/\(upc)").unsafelyUnwrapped
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // send asynchronous http request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // unwrap all values and do assertions
            guard let data = data,
                let response = response as? HTTPURLResponse,
                // check for fundamental networking error
                error == nil else {
                print("error", error ?? "Unknown error")
                return
            }
            
            // check for unauthorized which means we'd have to login again
            guard response.statusCode / 100 == 2 else {
                if response.statusCode == 401 {
                    print("Received unauthorized response, going back to login page.")

                    // switch back to main page
                    DispatchQueue.main.async {
                        // set the login status
                        self.loginStatus = .NotAttempted
                        self.postAuth()
                    }
                } else {
                    print("Error, received unexpected response \(response.statusCode)")
                }
                return
            }
            
            guard let itemType = try? JSONDecoder().decode(ItemType.self, from: data) else {
                
                print("Error parsing response JSON")
                return
            }
            
            // send value back to sender
            sender(itemType)
            
        }.resume()
    }
    
    /// send a get request to itemTypes
    func getItem(id: Int64, sender: @escaping (Item) -> Void) {
        let url = URL(string: "\(DebugLoginInfo.baseURL)/items/id/\(id)").unsafelyUnwrapped
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // send asynchronous http request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // unwrap all values and do assertions
            guard let data = data,
                let response = response as? HTTPURLResponse,
                // check for fundamental networking error
                error == nil else {
                print("error", error ?? "Unknown error")
                return
            }
            
            // check for unauthorized which means we'd have to login again
            guard response.statusCode / 100 == 2 else {
                if response.statusCode == 401 {
                    print("Received unauthorized response, going back to login page.")

                    // switch back to main page
                    DispatchQueue.main.async {
                        // set the login status
                        self.loginStatus = .NotAttempted
                        self.postAuth()
                    }
                } else {
                    print("Error, received unexpected response \(response.statusCode)")
                }
                return
            }
            
            guard let item = try? JSONDecoder().decode(Item.self, from: data) else {
                
                print("Error parsing response JSON")
                return
            }
            
            // send value back to sender
            sender(item)
            
        }.resume()
    }
    
    /// send a get request to itemTypes
    func getItemByQR(qr: String, sender: @escaping (Item) -> Void) {
        let url = URL(string: "\(DebugLoginInfo.baseURL)/items/qr/\(qr.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // send asynchronous http request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // unwrap all values and do assertions
            guard let data = data,
                let response = response as? HTTPURLResponse,
                // check for fundamental networking error
                error == nil else {
                print("error", error ?? "Unknown error")
                return
            }
            
            // check for unauthorized which means we'd have to login again
            guard response.statusCode / 100 == 2 else {
                if response.statusCode == 401 {
                    print("Received unauthorized response, going back to login page.")

                    // switch back to main page
                    DispatchQueue.main.async {
                        // set the login status
                        self.loginStatus = .NotAttempted
                        self.postAuth()
                    }
                } else {
                    print("Error, received unexpected response \(response.statusCode)")
                }
                return
            }
            
            guard let item = try? JSONDecoder().decode(Item.self, from: data) else {
                
                print("Error parsing response JSON")
                return
            }
            
            // send value back to sender
            sender(item)
            
        }.resume()
    }
    
    /// send a get request to itemTypes
    func getItemsByOrder(orderNumber: String, sender: @escaping ([Item]) -> Void) {
        let url = URL(string: "\(DebugLoginInfo.baseURL)/items/order/\(orderNumber.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // send asynchronous http request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // unwrap all values and do assertions
            guard let data = data,
                let response = response as? HTTPURLResponse,
                // check for fundamental networking error
                error == nil else {
                print("error", error ?? "Unknown error")
                return
            }
            
            // check for unauthorized which means we'd have to login again
            guard response.statusCode / 100 == 2 else {
                if response.statusCode == 401 {
                    print("Received unauthorized response, going back to login page.")

                    // switch back to main page
                    DispatchQueue.main.async {
                        // set the login status
                        self.loginStatus = .NotAttempted
                        self.postAuth()
                    }
                } else {
                    print("Error, received unexpected response \(response.statusCode)")
                }
                return
            }
            
            guard let item = try? JSONDecoder().decode([Item].self, from: data) else {
                
                print("Error parsing response JSON")
                return
            }
            
            // send value back to sender
            sender(item)
            
        }.resume()
    }
    
    /// send a put request to the item with a given id
    func putItem(id: Int64, itemNoId: ItemNoId, sender: @escaping (Int) -> Void) {
        let url = URL(string: "\(DebugLoginInfo.baseURL)/items/id/\(id)").unsafelyUnwrapped
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        // encode item body to JSON
        let body = try! JSONEncoder().encode(itemNoId)
        
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // send asynchronous http request
        URLSession.shared.dataTask(with: request) { (_, response, _) in
            // unwrap all values and do assertions
            guard let response = response as? HTTPURLResponse else {
                return
            }
            
            guard response.statusCode != 401 else {
                print("Received unauthorized response, going back to login page.")

                // switch back to main page
                DispatchQueue.main.async {
                    // set the login status
                    self.loginStatus = .NotAttempted
                    self.postAuth()
                }
                return
            }
            
            // send value back to sender
            sender(response.statusCode)
            
        }.resume()
    }
    
    /// send a get request to itemTypes
    func postItems(itemNoIds: [ItemNoId], sender: @escaping ([Int64]) -> Void) {
        let url = URL(string: "\(DebugLoginInfo.baseURL)/items").unsafelyUnwrapped
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // encode item body to JSON
        let body = try! JSONEncoder().encode(itemNoIds)
        
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // send asynchronous http request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // unwrap all values and do assertions
            guard let data = data,
                let response = response as? HTTPURLResponse,
                // check for fundamental networking error
                error == nil else {
                print("error", error ?? "Unknown error")
                return
            }
            
            // check for unauthorized which means we'd have to login again
            guard response.statusCode / 100 == 2 else {
                if response.statusCode == 401 {
                    print("Received unauthorized response, going back to login page.")

                    // switch back to main page
                    DispatchQueue.main.async {
                        // set the login status
                        self.loginStatus = .NotAttempted
                        self.postAuth()
                    }
                } else {
                    print("Error, received unexpected response \(response.statusCode)")
                }
                return
            }
            
            guard let ids = try? JSONDecoder().decode([Int64].self, from: data) else {
                
                print("Error parsing response JSON")
                return
            }
            
            // send value back to sender
            sender(ids)
            
        }.resume()
    }
    
    /// send a get request to itemTypes
    func postItemType(itemType: ItemType, sender: @escaping (Int) -> Void) {
        let url = URL(string: "\(DebugLoginInfo.baseURL)/itemtypes")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // encode item body to JSON
        let body = try! JSONEncoder().encode(itemType)
        
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // send asynchronous http request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // unwrap all values and do assertions
            guard let response = response as? HTTPURLResponse,
                // check for fundamental networking error
                error == nil else {
                print("error", error ?? "Unknown error")
                return
            }
            
            // check for unauthorized which means we'd have to login again
            guard response.statusCode != 401 else {
                print("Received unauthorized response, going back to login page.")

                // switch back to main page
                DispatchQueue.main.async {
                    // set the login status
                    self.loginStatus = .NotAttempted
                    self.postAuth()
                }
                return
            }
            
            // send value back to sender
            sender(response.statusCode)
            
        }.resume()
    }
    
    /// send a put request to the item with a given id
    func deleteItem(id: Int64, sender: @escaping (Int) -> Void) {
        let url = URL(string: "\(DebugLoginInfo.baseURL)/items/id/\(id)").unsafelyUnwrapped
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        // send asynchronous http request
        URLSession.shared.dataTask(with: request) { (_, response, _) in
            // unwrap all values and do assertions
            guard let response = response as? HTTPURLResponse else {
                return
            }
            
            guard response.statusCode != 401 else {
                print("Received unauthorized response, going back to login page.")

                // switch back to main page
                DispatchQueue.main.async {
                    // set the login status
                    self.loginStatus = .NotAttempted
                    self.postAuth()
                }
                return
            }
            
            // send value back to sender
            sender(response.statusCode)
            
        }.resume()
    }
}
