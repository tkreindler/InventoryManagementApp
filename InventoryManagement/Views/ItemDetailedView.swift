//
//  ItemView.swift
//  InventoryManagement
//
//  Created by Tristan Kreindler on 7/22/20.
//  Copyright © 2020 Tristan Kreindler. All rights reserved.
//

import SwiftUI

struct ItemDetailedView: View {
    private var httpManager: HttpManager
    @State var item: Item
    @State var editing = false
    @State var isPresentingScanner = false
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
                Text("Order number: \(item.orderNumber ?? "")")
                Spacer()
            }
        }
    }
    
    var scannerSheet : some View {
        CodeScannerView(
            codeTypes: [.qr],
            completion: { result in
                if case let .success(code) = result {
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
        )
    }
    
    
}

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
    @State private var orderNumber = ""
    
    // colors for text fields
    @State private var pricePaidBySellerColor = UIColor.white
    @State private var shippingCostToSellerColor = UIColor.white
    @State private var shippingCostToBuyerColor = UIColor.white
    @State private var feesColor = UIColor.white
    @State private var otherExpensesColor = UIColor.white
    @State private var pricePaidByBuyerColor = UIColor.white
    @State private var shippingPaidByBuyerColor = UIColor.white
    @State private var itemTypeUPCColor = UIColor.white
    @State private var orderNumberColor = UIColor.white
    
    @State private var keyboardHeight: CGFloat = 0
    
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
                        self.pricePaidBySellerColor = UIColor.red
                        return
                    }
                    guard let shippingCostToSeller = parseMoney(string: self.shippingCostToSeller) else {
                        self.shippingCostToSellerColor = UIColor.red
                        return
                    }
                    guard let shippingCostToBuyer = parseMoney(string: self.shippingCostToBuyer) else {
                        self.shippingCostToBuyerColor = UIColor.red
                        return
                    }
                    guard let fees = parseMoney(string: self.fees) else {
                        self.feesColor = UIColor.red
                        return
                    }
                    guard let otherExpenses = parseMoney(string: self.otherExpenses) else {
                        self.otherExpensesColor = UIColor.red
                        return
                    }
                    guard let pricePaidByBuyer = parseMoney(string: self.pricePaidByBuyer) else {
                        self.pricePaidByBuyerColor = UIColor.red
                        return
                    }
                    guard let shippingPaidByBuyer = parseMoney(string: self.shippingPaidByBuyer) else {
                        self.shippingPaidByBuyerColor = UIColor.red
                        return
                    }
                    guard let itemTypeUPC = unseparatedFormatter.number(from: self.itemTypeUPC)?.int64Value else {
                        self.itemTypeUPCColor = UIColor.red
                        return
                    }
                    guard let taxPaidBySeller = parseMoney(string: self.taxPaidBySeller) else {
                        return
                    }
                    
                    let item = ItemNoId(itemTypeUPC: itemTypeUPC, qrCode: self.item.qrCode, itemStatus: self.item.itemStatus, pricePaidBySeller: pricePaidBySeller, taxPaidBySeller: taxPaidBySeller, shippingCostToSeller: shippingCostToSeller, shippingCostToBuyer: shippingCostToBuyer, fees: fees, otherExpenses: otherExpenses, shippingPaidByBuyer: shippingPaidByBuyer, pricePaidByBuyer: pricePaidByBuyer, orderNumber: self.orderNumber.isEmpty ? nil : self.orderNumber)
                    
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
                        Text("Order Number:")
                        Spacer()
                        TextField("test", text: $orderNumber)
                            .keyboardType(.decimalPad)
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
                                    self.editing = false
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
        }
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
        let item = Item(id: 127, itemTypeUPC: 103846728399, qrCode: nil, itemStatus: .ordered, pricePaidBySeller: 23, taxPaidBySeller: 0, shippingCostToSeller: 1, shippingCostToBuyer: 43, fees: 3, otherExpenses: 7, shippingPaidByBuyer: 43, pricePaidByBuyer: 343, orderNumber: nil)
        let view = ItemDetailedView(item: item, httpManager: httpManager, parent: ItemType(name: "test", upc: 10238347))
        
        return NavigationView {
            NavigationLink("Next page", destination: view, isActive: .constant(true)).hidden()
        }
        
    }
}
