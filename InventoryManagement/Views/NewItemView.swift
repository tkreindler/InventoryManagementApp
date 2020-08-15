//
//  NewItemView.swift
//  InventoryManagement
//
//  Created by Tristan Kreindler on 8/10/20.
//  Copyright © 2020 Tristan Kreindler. All rights reserved.
//

import SwiftUI

struct NewItemView: View {
    // strings for text fields
    @State private var pricePaidBySeller = ""
    @State private var taxCostToSeller = ""
    @State private var shippingCostToSeller = ""
    @State private var orderNumberToSeller = ""
    @State private var itemCount = ""
    
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
                    guard let itemCount = self.itemCount.isEmpty ? 1 : unseparatedFormatter.number(from: self.itemCount)?.intValue, itemCount > 0 else {
                        return
                    }
                    guard let pricePaidBySeller = self.pricePaidBySeller.isEmpty ? 0 : parseMoney(string: self.pricePaidBySeller) else {
                        self.pricePaidBySellerColor = UIColor.red
                        return
                    }
                    guard let shippingCostToSeller = self.shippingCostToSeller.isEmpty ? 0 : parseMoney(string: self.shippingCostToSeller) else {
                        self.shippingCostToSellerColor = UIColor.red
                        return
                    }
                    guard let taxCostToSeller = self.taxCostToSeller.isEmpty ? 0 : parseMoney(string: self.taxCostToSeller) else {
                        return
                    }
                    
                    let orderNumber = self.orderNumberToSeller.isEmpty ? nil : self.orderNumberToSeller
                    
                    let item = ItemNoId(itemTypeUPC: parent.upc, qrCode: nil, itemStatus: .ordered, pricePaidBySeller: pricePaidBySeller / Decimal(itemCount), taxPaidBySeller: taxCostToSeller / Decimal(itemCount), shippingCostToSeller: shippingCostToSeller / Decimal(itemCount), shippingCostToBuyer: 0, fees: 0, otherExpenses: 0, shippingPaidByBuyer: 0, pricePaidByBuyer: 0, orderNumberToSeller: orderNumberToSeller, orderNumberToBuyer: nil)
                    
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
                        Text("Total price we paid:")
                        Spacer()
                        TextField("0", text: $pricePaidBySeller)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack {
                        Text("Total tax we paid:")
                        Spacer()
                        TextField("0", text: $taxCostToSeller)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack {
                        Text("Shipping we paid to get the items:")
                        Spacer()
                        TextField("0", text: $shippingCostToSeller)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                Section(header: Text("Other").font(.system(size: 20)).padding(.top)) {
                    HStack {
                        Text("Order Number:")
                        Spacer()
                        TextField("n/a", text: $orderNumberToSeller)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack {
                        Text("Item Count:")
                        Spacer()
                        TextField("1", text: $itemCount)
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
