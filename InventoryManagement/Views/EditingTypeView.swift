//
//  EditingTypeView.swift
//  InventoryManagement
//
//  Created by Tristan Kreindler on 8/10/20.
//  Copyright © 2020 Tristan Kreindler. All rights reserved.
//

import SwiftUI
import CarBode

struct EditingTypeView: View {
    @State private var keyboardHeight: CGFloat = 0
    @State private var name: String = ""
    @State private var imageURL: String = ""
    
    @Binding var showingEditTypePopup: Bool
    var httpManager: HttpManager
    
    // the item type we're changing
    @Binding var itemType: ItemType
    
    // for updating changes after
    @Binding var itemTypes: [ItemType]
    
    // image picking stuff
    @State private var showingImagePicker = false
    
    @State var isPresentingScanner = false
    
    @State var showingActionSheet = false
    @State var cameraOrPhotos: UIImagePickerController.SourceType = .camera
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            scrolling
            .navigationBarItems(trailing:
                Button(action: {
                    guard !self.name.isEmpty else {
                        print("ItemType must have a name")
                        return
                    }
                    
                    let newItemType = ItemType(name: self.name, upc: self.itemType.upc, imageURL: self.imageURL.isEmpty ? nil : self.imageURL)
                    
                    self.httpManager.putItemType(upc: self.itemType.upc, itemType: newItemType) {
                        responseStatus in
                        
                        guard responseStatus / 100 == 2 else {
                            print("Got unexpected response status \(responseStatus)")
                            return
                        }
                        
                        self.httpManager.getItemType(upc: itemType.upc) {
                            itemType in
                            DispatchQueue.main.async {
                                self.itemType = itemType
                            }
                        }
                        
                        // success
                        // reload itemTypes list
                        self.httpManager.getItemTypes(sender: {
                            itemTypesParam in
                            DispatchQueue.main.async {
                                self.itemTypes = itemTypesParam
                            }
                        })
                        
                        // go back
                        DispatchQueue.main.async {
                            self.showingEditTypePopup = false
                        }
                    }
                }) {
                    Text("Done")
                }
            )
        }
    }
    
    var scrolling: some View {
        ScrollView {
            Section(header: Text("Mandatory").font(.system(size: 20))) {
                HStack {
                    Text("Name:")
                    Spacer()
                    TextField("Name", text: self.$name)
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
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
                    self.showingActionSheet = true
                }) {
                    Text("Upload an image to imgur")
                }
                .padding(.bottom, self.keyboardHeight)
                .actionSheet(isPresented: $showingActionSheet) {
                    ActionSheet(title: Text("Choose where to upload from"), buttons: [
                        .default(Text("Camera")) {
                            self.cameraOrPhotos = .camera
                            self.showingImagePicker = true
                        },
                        .default(Text("Photos Library")) {
                            self.cameraOrPhotos = .photoLibrary
                            self.showingImagePicker = true
                        },
                        .cancel()
                    ])
                }
                .sheet(isPresented: $showingImagePicker) {
                    // image picker
                    ImagePickerAndUploader(imageURL: self.$imageURL, sourceType: self.cameraOrPhotos)
                }
            }
            Section(header: Text("DANGER ZONE").font(.system(size: 20)).padding(.top)) {
                Button(action: {
                    self.httpManager.deleteItemType(upc: self.itemType.upc) {
                        responseStatus in
                        if responseStatus / 100 == 2 {
                            DispatchQueue.main.async {
                                // go back to item type
                                // TODO this doesn't work
                                self.showingEditTypePopup = false
                                DispatchQueue.main.async {
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            }
                        } else {
                            print("Error deleting item with status code \(responseStatus)")
                        }
                    }
                }) {
                    Text("Delete Item")
                }
                .padding(.bottom, keyboardHeight * 0.8)
            }
            .padding(.top, 100)
        }
        .padding()
        .onReceive(keyboardHeightPublisher) {
            keyboardHeight in
            self.keyboardHeight = keyboardHeight
        }
        .onAppear() {
            self.imageURL = self.itemType.imageURL ?? ""
            self.name = self.itemType.name
        }
    }
}

