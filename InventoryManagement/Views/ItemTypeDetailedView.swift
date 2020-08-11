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
    @State var itemType: ItemType
    
    // for refreshing main page
    @Binding var itemTypes: [ItemType]
    @Environment(\.presentationMode) var presentationMode
    
    @State var newItem: Item? = nil
    @State var isItemSelected = false
    
    @State var showingNewItemPopup = false
    @State var showingEditItemPopup = false
    
    @ViewBuilder
    var body: some View {
        VStack {
            if self.newItem != nil {
                // special link for use with a new item
                NavigationLink("Next page", destination: ItemDetailedView(item: self.newItem!, httpManager: self.httpManager, parent: self.itemType), isActive: self.$isItemSelected).hidden()
            }
            
            ZStack {
                HStack {
                    Spacer()
                    NavigationLink(destination: EditingTypeView(showingEditTypePopup: $showingEditItemPopup, httpManager: httpManager, itemType: $itemType, itemTypes: $itemTypes), isActive: $showingEditItemPopup) {
                        Text("Edit")
                            .padding(.trailing)
                    }
                }
                HStack {
                    if self.itemType.imageURL != nil {
                        SquareImage(url: itemType.imageURL, size: 128)
                    }
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
