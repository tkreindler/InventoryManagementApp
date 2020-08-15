//
//  EditingItemView.swift
//  InventoryManagement
//
//  Created by Tristan Kreindler on 8/10/20.
//  Copyright © 2020 Tristan Kreindler. All rights reserved.
//

import SwiftUI

struct EditingItemView: View {
    // strings for text fields
    @State private var pricePaidBySeller = ""
    @State private var taxPaidBySeller = ""
    @State private var shippingCostToSeller = ""
    @State private var shippingCostToBuyer = ""
    @State private var fees = ""
    @State private var otherExpenses = ""
    @State private var pricePaidByBuyer = ""
    @State private var shippingPaidByBuyer = ""
    @State private var itemTypeUPC = ""
    @State private var orderNumberToSeller = ""
    @State private var orderNumberToBuyer = ""
    
    @State private var keyboardHeight: CGFloat = 0
    
    @Environment(\.presentationMode) var presentationMode
    
    var httpManager: HttpManager
    @Binding var item: Item
    @Binding var editing: Bool
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.editing = false
                }, label: {
                    Text("Cancel")
                })
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                Spacer()
                Button(action: {
                    // parse info into item
                    guard let pricePaidBySeller = parseMoney(string: self.pricePaidBySeller) else {
                        return
                    }
                    guard let shippingCostToSeller = parseMoney(string: self.shippingCostToSeller) else {
                        return
                    }
                    guard let shippingCostToBuyer = parseMoney(string: self.shippingCostToBuyer) else {
                        return
                    }
                    guard let fees = parseMoney(string: self.fees) else {
                        return
                    }
                    guard let otherExpenses = parseMoney(string: self.otherExpenses) else {
                        return
                    }
                    guard let pricePaidByBuyer = parseMoney(string: self.pricePaidByBuyer) else {
                        return
                    }
                    guard let shippingPaidByBuyer = parseMoney(string: self.shippingPaidByBuyer) else {
                        return
                    }
                    guard let itemTypeUPC = unseparatedFormatter.number(from: self.itemTypeUPC)?.int64Value else {
                        return
                    }
                    guard let taxPaidBySeller = parseMoney(string: self.taxPaidBySeller) else {
                        return
                    }
                    
                    let orderNumberToSeller = self.orderNumberToSeller.isEmpty ? nil : self.orderNumberToSeller
                    
                    let orderNumberToBuyer = self.orderNumberToBuyer.isEmpty ? nil : self.orderNumberToBuyer
                    
                    
                    let item = ItemNoId(itemTypeUPC: itemTypeUPC, qrCode: self.item.qrCode, itemStatus: self.item.itemStatus, pricePaidBySeller: pricePaidBySeller, taxPaidBySeller: taxPaidBySeller, shippingCostToSeller: shippingCostToSeller, shippingCostToBuyer: shippingCostToBuyer, fees: fees, otherExpenses: otherExpenses, shippingPaidByBuyer: shippingPaidByBuyer, pricePaidByBuyer: pricePaidByBuyer, orderNumberToSeller: orderNumberToSeller,
                                        orderNumberToBuyer: orderNumberToBuyer)
                    
                    self.httpManager.putItem(id: self.item.id, itemNoId: item) {
                        responseStatus in
                        if responseStatus / 100 == 2 {
                            // get the new changes back
                            self.httpManager.getItem(id: self.item.id) {
                                item in
                                self.item = item
                            }
                            
                            // go back to non-editing view
                            DispatchQueue.main.async {
                                // go back a page
                                self.editing = false
                            }
                        } else {
                            print("Got unexpected error response on put \(responseStatus)")
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
                        Text("Tax we paid:")
                        Spacer()
                        TextField("test", text: $taxPaidBySeller)
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
                    HStack {
                        Text("Shipping we paid to send the item:")
                        Spacer()
                        TextField("test", text: $shippingCostToBuyer)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack {
                        Text("Seller fees:")
                        Spacer()
                        TextField("test", text: $fees)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack {
                        Text("Other expenses:")
                        Spacer()
                        TextField("test", text: $otherExpenses)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                Section(header: Text("Revenues").font(.system(size: 20)).padding(.top)) {
                    HStack {
                        Text("Price buyer paid:")
                        Spacer()
                        TextField("test", text: $pricePaidByBuyer)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack {
                        Text("Shipping buyer paid:")
                        Spacer()
                        TextField("test", text: $shippingPaidByBuyer)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                Section(header: Text("Other").font(.system(size: 20)).padding(.top)) {
                    HStack {
                        Text("Item Type UPC:")
                        Spacer()
                        TextField("test", text: $itemTypeUPC)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack {
                        Text("Order Number to seller:")
                        Spacer()
                        TextField("test", text: $orderNumberToSeller)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack {
                        Text("Order Number to buyer:")
                        Spacer()
                        TextField("test", text: $orderNumberToBuyer)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                Section(header: Text("DANGER ZONE").font(.system(size: 20)).padding(.top)) {
                    Button(action: {
                        self.httpManager.deleteItem(id: self.item.id) {
                            responseStatus in
                            if responseStatus / 100 == 2 {
                                DispatchQueue.main.async {
                                    // go back to item type
                                    // TODO this doesn't work
                                    self.editing = false
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
        .onAppear() {
            self.pricePaidBySeller = self.item.pricePaidBySeller.formattedAsMoney
            self.shippingCostToSeller = self.item.shippingCostToSeller.formattedAsMoney
            self.shippingCostToBuyer = self.item.shippingCostToBuyer.formattedAsMoney
            self.fees = self.item.fees.formattedAsMoney
            self.otherExpenses = self.item.otherExpenses.formattedAsMoney
            self.pricePaidByBuyer = self.item.pricePaidByBuyer.formattedAsMoney
            self.shippingPaidByBuyer = self.item.shippingPaidByBuyer.formattedAsMoney
            self.itemTypeUPC = self.item.itemTypeUPC.formattedAsUPC
            self.taxPaidBySeller = self.item.taxPaidBySeller.formattedAsMoney
            self.orderNumberToSeller = self.item.orderNumberToSeller ?? ""
            self.orderNumberToBuyer = self.item.orderNumberToBuyer ?? ""
        }
        .onReceive(keyboardHeightPublisher) {
            keyboardHeight in
            self.keyboardHeight = keyboardHeight
        }
        }
    }
}
