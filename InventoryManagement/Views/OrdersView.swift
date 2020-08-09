//
//  OrdersView.swift
//  InventoryManagement
//
//  Created by Tristan Kreindler on 7/31/20.
//  Copyright © 2020 Tristan Kreindler. All rights reserved.
//

import SwiftUI

struct OrdersView: View {
    var httpManager: HttpManager
    @State var orderNumber: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("test", text: $orderNumber)
                    .multilineTextAlignment(.trailing)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                NavigationLink(destination: OrderDetailedView(httpManager: httpManager, orderNumber: orderNumber)) {
                    Text("Go")
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct OrderDetailedView: View {
    // a list of items with their parents
    @State var items: [(Item, ItemType)] = []
    var httpManager: HttpManager
    var orderNumber: String
    
    @ViewBuilder
    var body: some View {
        VStack {
            List() {
                Section(header: Text("Items of this type:").font(.system(size: 24)).bold()) {
                    ForEach(self.items, id: \.0.id) {
                        (item, itemType) in
                        NavigationLink(destination: ItemDetailedView(item: item, httpManager: self.httpManager, parent: itemType)) {
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
                self.items = []
                self.httpManager.getItemTypes() {
                    itemTypes in
                    let dict = Dictionary(uniqueKeysWithValues: itemTypes.map{ ($0.upc, $0) })
                    self.httpManager.getItemsByOrder(orderNumber: orderNumber, sender: {
                        items in
                        self.items = items.map({
                            item in
                            let parent = dict[item.itemTypeUPC]!
                            return (item, parent)
                        })
                    })
                }
            }
        }
        .navigationBarTitle(Text("Order #\(self.orderNumber)"), displayMode: .inline)
        .padding(.top, 10)
    }
}
