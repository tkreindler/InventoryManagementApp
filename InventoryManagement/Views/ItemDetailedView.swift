//
//  ItemView.swift
//  InventoryManagement
//
//  Created by Tristan Kreindler on 7/22/20.
//  Copyright © 2020 Tristan Kreindler. All rights reserved.
//

import SwiftUI
import CarBode

struct ItemDetailedView: View {
    private var httpManager: HttpManager
    @State var item: Item
    @State var editing = false
    @State var isPresentingScanner = false
    @State var isPresentingSeller = false
    var parent: ItemType
    
    init(item: Item, httpManager: HttpManager, parent: ItemType) {
        self._item = State(initialValue: item)
        self.httpManager = httpManager
        self.parent = parent
    }
    
    var body: some View {
        VStack {
            List {
                self.overview
                self.expenses
                self.revenues
                self.other
            }
            .navigationBarTitle(Text("\(parent.name), Id: \(item.id)"), displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    self.editing = true
                }) {
                    Text("Edit")
                }
                .sheet(isPresented: $editing) {
                    EditingItemView(httpManager: httpManager, item: $item, editing: $editing)
                }
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 5))
            )
        }
    }
    
    var overview: some View {
        Section(header: Text("Overview").font(.system(.title)).bold()) {
            HStack {
                Text("Item Status: \(item.itemStatus.name)")
                Spacer()
                
                #if !targetEnvironment(macCatalyst)
                if item.itemStatus == .ordered {
                    Button(action: {
                        self.isPresentingScanner = true
                    }) {
                        Text("Check in")
                    }
                    .sheet(isPresented: $isPresentingScanner) {
                        self.scannerSheet
                    }
                    .buttonStyle(BorderlessButtonStyle())
                } else if item.itemStatus == .inStock {
                    Button(action: {
                        self.isPresentingSeller = true
                    }) {
                        Text("Sell")
                    }
                    .sheet(isPresented: $isPresentingSeller) {
                        SellItemView(item: $item, httpManager: httpManager, isPresentingSeller: $isPresentingSeller)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                #endif
            }
            HStack {
                Text("Profit: \(item.profit.formattedAsMoney)")
                Spacer()
            }
            HStack {
                Text("Expenses: \(item.expenses.formattedAsMoney)")
                Spacer()
            }
            HStack {
                Text("Revenues: \(item.revenues.formattedAsMoney)")
                Spacer()
            }
        }
    }
    
    var expenses: some View {
        Section(header: Text("Expenses")) {
            HStack {
                Text("Price we paid: \(item.pricePaidBySeller.formattedAsMoney)")
                Spacer()
            }
            HStack {
                Text("Tax we paid: \(item.taxPaidBySeller.formattedAsMoney)")
                Spacer()
            }
            HStack {
                Text("Shipping we paid to get the item: \(item.shippingCostToSeller.formattedAsMoney)")
                Spacer()
            }
            HStack {
                Text("Shipping we paid to send the item: \(item.shippingCostToBuyer.formattedAsMoney)")
                Spacer()
            }
            HStack {
                Text("Seller fees: \(item.fees.formattedAsMoney)")
                Spacer()
            }
            HStack {
                Text("Other expenses: \(item.otherExpenses.formattedAsMoney)")
                Spacer()
            }
        }
    }
    
    var revenues: some View {
        Section(header: Text("Revenues")) {
            HStack {
                Text("Price buyer paid: \(item.pricePaidByBuyer.formattedAsMoney)")
                Spacer()
            }
            HStack {
                Text("Shipping buyer paid: \(item.shippingPaidByBuyer.formattedAsMoney)")
                Spacer()
            }
        }
    }
    
    var other: some View {
        Section(header: Text("Other")) {
            if item.itemStatus != .ordered {
                HStack {
                    Text("QR string: \(item.qrCode ?? "")")
                    Spacer()
                }
            }
            HStack {
                Text("Item Type UPC: \(item.itemTypeUPC.formattedAsUPC)")
                Spacer()
            }
            HStack {
                Text("Order number to seller: \(item.orderNumberToSeller ?? "")")
                Spacer()
            }
            HStack {
                Text("Order number to buyer: \(item.orderNumberToBuyer ?? "")")
                Spacer()
            }
        }
    }
    
    var scannerSheet : some View {
        CBScanner(supportBarcode: [.qr])
            .interval(delay: 2.5)
            .found() {
                code in
                self.isPresentingScanner = false
                
                // create a copy
                let item = ItemNoId(item: self.item)
                
                item.qrCode = code
                item.itemStatus = .inStock
                
                self.httpManager.putItem(id: self.item.id, itemNoId: item) {
                    responseStatus in
                    if responseStatus / 100 == 2 {
                        // success
                        self.httpManager.getItem(id: self.item.id) {
                            item in
                            self.item = item
                        }
                    } else {
                        print("Got unexpected error response on put \(responseStatus)")
                    }
                }
            }
    }
    
    
}

struct SellItemView: View {
    @Binding var item: Item
    var httpManager: HttpManager
    
    @Binding var isPresentingSeller: Bool
    
    @State var pricePaidByBuyer: String = ""
    @State var shippingPaidByBuyer: String = ""
    @State var shippingCostToBuyer: String = ""
    @State var fees: String = ""
    @State var orderNumber: String = ""
    
    @State var keyboardHeight: CGFloat = 0
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.isPresentingSeller = false
                }, label: {
                    Text("Cancel")
                })
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                Spacer()
                Button(action: {
                    // parse info into item
                    guard let pricePaidByBuyer = parseMoney(string: self.pricePaidByBuyer) else {
                        return
                    }
                    guard let shippingPaidByBuyer = parseMoney(string: self.shippingPaidByBuyer) else {
                        return
                    }
                    guard let shippingCostToBuyer = parseMoney(string: self.shippingCostToBuyer) else {
                        return
                    }
                    guard let fees = parseMoney(string: self.fees) else {
                        return
                    }
                    
                    let orderNumberToBuyer = self.orderNumber.isEmpty ? nil : self.orderNumber
                    
                    let itemNoId = ItemNoId(itemTypeUPC: self.item.itemTypeUPC, qrCode: self.item.qrCode, itemStatus: .sold, pricePaidBySeller: self.item.pricePaidBySeller, taxPaidBySeller: self.item.taxPaidBySeller, shippingCostToSeller: self.item.shippingCostToSeller, shippingCostToBuyer: shippingCostToBuyer, fees: fees, otherExpenses: 0, shippingPaidByBuyer: shippingPaidByBuyer, pricePaidByBuyer: pricePaidByBuyer, orderNumberToSeller: self.item.orderNumberToSeller, orderNumberToBuyer: orderNumberToBuyer)
                    
                    self.httpManager.putItem(id: self.item.id, itemNoId: itemNoId) {
                        responseStatus in
                        if responseStatus / 100 == 2 {
                            // success
                            
                            // get item from server to double check
                            self.httpManager.getItem(id: self.item.id) {
                                item in
                                // update item and go back
                                self.item = item
                                self.isPresentingSeller = false
                            }
                        }
                    }
                }) {
                    Text("Done")
                }
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
            }
            ScrollView {
                Section(header: Text("Revenues").font(.system(size: 20))) {
                    HStack {
                        Text("Price buyer paid:")
                        Spacer()
                        TextField("0", text: $pricePaidByBuyer)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack {
                        Text("Shipping buyer paid:")
                        Spacer()
                        TextField("0", text: $shippingPaidByBuyer)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                Section(header: Text("Expenses").font(.system(size: 20))) {
                    HStack {
                        Text("Shipping we paid:")
                        Spacer()
                        TextField("0", text: $shippingCostToBuyer)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack {
                        Text("Fees we paid:")
                        Spacer()
                        TextField("0", text: $fees)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                Section(header: Text("Other").font(.system(size: 20)).padding(.top)) {
                    HStack {
                        Text("Order Number:")
                        Spacer()
                        TextField("n/a", text: $orderNumber)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
            }
            .padding()
            .onReceive(keyboardHeightPublisher) {
                keyboardHeight in
                self.keyboardHeight = keyboardHeight
            }
        }
    }
}

struct ItemDetailedView_Previews: PreviewProvider {
    static var previews: some View {
        let httpManager = HttpManager()
        httpManager.postAuth(username: DebugLoginInfo.username, password: DebugLoginInfo.password)
        let item = Item(id: 127, itemTypeUPC: 103846728399, qrCode: nil, itemStatus: .ordered, pricePaidBySeller: 23, taxPaidBySeller: 0, shippingCostToSeller: 1, shippingCostToBuyer: 43, fees: 3, otherExpenses: 7, shippingPaidByBuyer: 43, pricePaidByBuyer: 343, orderNumberToSeller: nil, orderNumberToBuyer: nil)
        let view = ItemDetailedView(item: item, httpManager: httpManager, parent: ItemType(name: "test", upc: 10238347))
        
        return NavigationView {
            NavigationLink("Next page", destination: view, isActive: .constant(true)).hidden()
        }
        
    }
}
