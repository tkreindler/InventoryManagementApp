//
//  ItemTypeDetailedView.swift
//  InventoryManagement
//
//  Created by Tristan Kreindler on 7/27/20.
//  Copyright © 2020 Tristan Kreindler. All rights reserved.
//

import SwiftUI

struct ItemTypeDetailedView: View {
    @State var items: [Item] = []
    var httpManager: HttpManager
    var itemType: ItemType
    @Environment(\.presentationMode) var presentationMode
    
    @State var newItem: Item? = nil
    @State var isItemSelected = false
    
    @State var showingNewItemPopup = false
    
    @ViewBuilder
    var body: some View {
        VStack {
            if self.newItem != nil {
                // special link for use with a new item
                NavigationLink("Next page", destination: ItemDetailedView(item: self.newItem!, httpManager: self.httpManager, parent: self.itemType), isActive: self.$isItemSelected).hidden()
            }
            
            HStack {
                if self.itemType.imageURL != nil {
                    SquareImage(url: itemType.imageURL, size: 128)
                }
            }
            
            Text("UPC: \(itemType.upc.formattedAsUPC)")
                .padding(.bottom)
            List() {
                Section(header: Text("Items of this type:").font(.system(size: 24)).bold()) {
                    ForEach(self.items, id: \.id) {
                        item in
                        NavigationLink(destination: ItemDetailedView(item: item, httpManager: self.httpManager, parent: self.itemType)) {
                            HStack {
                                Text("Item #\(item.id)")
                                Spacer()
                                Text(item.itemStatus.name)
                            }
                        }
                    }
                }
                 
            }
            .onAppear() {
                self.httpManager.getItemsByType(upc: self.itemType.upc, sender: {
                    itemsOut in
                    self.items = itemsOut
                })
            }
        }
        .navigationBarTitle(Text(itemType.name), displayMode: .inline)
        .navigationBarItems(trailing:
            Button(action: {
                // add a new item to this item type
                self.showingNewItemPopup = true
            }) {
                Text("+")
                    .font(.system(size: 36)).padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 10))
            }
            .sheet(isPresented: $showingNewItemPopup) {
                NewItemView(httpManager: httpManager, showingNewItemPopup: $showingNewItemPopup, parent: self.itemType, newItem: $newItem, isItemSelected: $isItemSelected, items: $items)
            }
        )
        .padding(.top, 10)
    }
}

struct NewItemView: View {
    // strings for text fields
    @State private var pricePaidBySeller = "$0.00"
    @State private var shippingCostToSeller = "$0.00"
    @State private var orderNumber = ""
    @State private var itemCount = "1"
    
    // colors for text fields
    @State private var pricePaidBySellerColor = UIColor.white
    @State private var shippingCostToSellerColor = UIColor.white
    @State private var orderNumberColor = UIColor.white
    
    @State private var keyboardHeight: CGFloat = 0
    
    var httpManager: HttpManager
    @Binding var showingNewItemPopup: Bool
    var parent: ItemType
    @Binding var newItem: Item?
    @Binding var isItemSelected: Bool
    @Binding var items: [Item]
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.showingNewItemPopup = false
                }, label: {
                    Text("Cancel")
                })
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                Spacer()
                Button(action: {
                    // parse info into item
                    guard let pricePaidBySeller = parseMoney(string: self.pricePaidBySeller) else {
                        self.pricePaidBySellerColor = UIColor.red
                        return
                    }
                    guard let shippingCostToSeller = parseMoney(string: self.shippingCostToSeller) else {
                        self.shippingCostToSellerColor = UIColor.red
                        return
                    }
                    guard let itemCount = unseparatedFormatter.number(from: self.itemCount)?.intValue, itemCount > 0 else {
                        return
                    }
                    
                    let item = ItemNoId(itemTypeUPC: parent.upc, qrCode: nil, itemStatus: .ordered, pricePaidBySeller: pricePaidBySeller, shippingCostToSeller: shippingCostToSeller, shippingCostToBuyer: 0, fees: 0, otherExpenses: 0, shippingPaidByBuyer: 0, pricePaidByBuyer: 0, orderNumber: self.orderNumber.isEmpty ? nil : self.orderNumber)
                    
                    let items = Array(repeating: item, count: itemCount)
                    
                    self.httpManager.postItems(itemNoIds: items) {
                        itemIds in
                        self.httpManager.getItemsByType(upc: parent.upc) {
                            items in
                            DispatchQueue.main.async {
                                self.showingNewItemPopup = false
                                self.items = items
                                
                                
                                if(itemIds.count == 1) {
                                    self.httpManager.getItem(id: itemIds[0]) {
                                        item in
                                        self.newItem = item
                                        self.isItemSelected = true
                                    }
                                }
                            }
                        }
                    }
                }) {
                    Text("Done")
                }
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
            }
            ScrollView {
                Section(header: Text("Expenses").font(.system(size: 20))) {
                    HStack {
                        Text("Price we paid:")
                        Spacer()
                        TextField("test", text: $pricePaidBySeller)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack {
                        Text("Shipping we paid to get the item:")
                        Spacer()
                        TextField("test", text: $shippingCostToSeller)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                Section(header: Text("Other").font(.system(size: 20)).padding(.top)) {
                    HStack {
                        Text("Order Number:")
                        Spacer()
                        TextField("test", text: $orderNumber)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack {
                        Text("Item Count:")
                        Spacer()
                        TextField("test", text: $itemCount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding(.top, 100)
            }
            .padding()
            .onReceive(keyboardHeightPublisher) {
                keyboardHeight in
                self.keyboardHeight = keyboardHeight
            }
        }
    }
}

struct ItemTypeDetailedView_Previews: PreviewProvider {
    static var previews: some View {
        let httpManager = HttpManager()
        httpManager.postAuth(username: DebugLoginInfo.username, password: DebugLoginInfo.password)
        let itemType = ItemType(name: "Lea", upc: 887961202007, imageURL: "https://images-na.ssl-images-amazon.com/images/I/71ctTzF9FfL._AC_SL1137_.jpg")
        let view = ItemTypeDetailedView(httpManager: httpManager, itemType: itemType)
        
        return NavigationView {
            NavigationLink("Next page", destination: view, isActive: .constant(true)).hidden()
        }
    }
}
