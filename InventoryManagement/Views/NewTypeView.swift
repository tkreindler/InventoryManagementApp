//
//  NewTypeView.swift
//  InventoryManagement
//
//  Created by Tristan Kreindler on 8/10/20.
//  Copyright © 2020 Tristan Kreindler. All rights reserved.
//

import SwiftUI
import CarBode

struct NewTypeView: View {
    @State private var keyboardHeight: CGFloat = 0
    @State private var name: String = ""
    @State private var upc: String = ""
    @State private var imageURL: String = ""
    
    @Binding var showingNewTypePopup: Bool
    var httpManager: HttpManager
    @Binding var itemTypes: [ItemType]
    
    // image picking stuff
    @State private var showingImagePicker = false
    
    @State var isPresentingScanner = false
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.showingNewTypePopup = false
                }, label: {
                    Text("Cancel")
                })
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                Spacer()
                Button(action: {
                    guard let upc = unseparatedFormatter.number(from: self.upc)?.int64Value else {
                        print("Error parsing upc")
                        return
                    }
                    
                    let imageURL: String? = self.imageURL.isEmpty ? nil : self.imageURL
                    
                    let newItemType = ItemType(name: self.name, upc: upc, imageURL: imageURL)
                    
                    self.httpManager.postItemType(itemType: newItemType) {
                        responseStatus in
                        
                        guard responseStatus / 100 == 2 else {
                            print("Got unexpected response status \(responseStatus)")
                            return
                        }
                        
                        // success
                        // reload itemTypes
                        self.httpManager.getItemTypes(sender: {
                            itemTypesParam in
                            DispatchQueue.main.async {
                                self.itemTypes = itemTypesParam
                            }
                        })
                        
                        // go back
                        DispatchQueue.main.async {
                            self.showingNewTypePopup = false
                        }
                    }
                }) {
                    Text("Done")
                }
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
            }
            ScrollView {
                Section(header: Text("Mandatory").font(.system(size: 20))) {
                    HStack {
                        Text("Name:")
                        Spacer()
                        TextField("Name", text: self.$name)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack {
                        Text("UPC:")
                        Spacer()
                        TextField("UPC", text: self.$upc)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    Button(action: {
                        self.isPresentingScanner = true
                    }) {
                        Text("Scan UPC")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(.bottom)
                }
                Section(header: Text("Optional").font(.system(size: 20))) {
                    HStack {
                        Text("Image URL:")
                        Spacer()
                        TextField("Optional image url", text: self.$imageURL)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    Button(action: {
                        self.showingImagePicker = true
                    }) {
                        Text("Upload an image to imgur")
                    }
                    .padding(.bottom, self.keyboardHeight)
                }
            }
            .padding()
        .onReceive(keyboardHeightPublisher) {
            keyboardHeight in
            self.keyboardHeight = keyboardHeight
        }
        .sheet(isPresented: $showingImagePicker) {
            // image picker
            ImagePickerAndUploader(imageURL: self.$imageURL)
        }
        }
        .sheet(isPresented: $isPresentingScanner) {
            self.scannerSheet
        }
    }
    
    var scannerSheet : some View {
        CBScanner(supportBarcode: [.ean13])
            .interval(delay: 2.5)
            .found() {
                code in
                self.upc = code
                self.isPresentingScanner = false
            }
    }
}
