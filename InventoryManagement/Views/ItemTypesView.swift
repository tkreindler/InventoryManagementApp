//
//  MainView.swift
//  InventoryManagement
//
//  Created by Tristan Kreindler on 7/21/20.
//  Copyright © 2020 Tristan Kreindler. All rights reserved.
//

import SwiftUI

struct ItemTypesView: View {
    
    @State var itemTypes: [ItemType] = []
    var httpManager: HttpManager
    @State var detailedViewItemTypeUPC: Int64? = nil
    @State var showDetailedView = false
    @State var showingNewTypePopup = false
    
    var body: some View {
        NavigationView {
            List(itemTypes, id: \.upc) {
                itemType in
                NavigationLink(destination: ItemTypeDetailedView(httpManager: self.httpManager, itemType: itemType, itemTypes: $itemTypes)) {
                    HStack {
                        Text(itemType.name)
                        Spacer()
                        SquareImage(url: itemType.imageURL, size: 96)
                    }
                }
            }
            .onAppear {
                self.httpManager.getItemTypes(sender: {
                    itemTypesParam in
                    DispatchQueue.main.async {
                        self.itemTypes = itemTypesParam
                    }
                })
            }
            .navigationBarTitle("Item Types")
            .navigationBarItems(trailing:
                                    
                Button(action: {
                    // add a new item to this item type
                    self.showingNewTypePopup = true
                }) {
                    Text("+")
                        .font(.system(size: 36)).padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 10))
                }
                .sheet(isPresented: $showingNewTypePopup) {
                    NewTypeView(showingNewTypePopup: $showingNewTypePopup, httpManager: httpManager, itemTypes: $itemTypes)
                }
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 5))
            )
        }
    }
}

struct ItemTypeView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = HttpManager()
        manager.postAuth(username: DebugLoginInfo.username, password: DebugLoginInfo.password)
        
        let itemTypes = [
            ItemType(name: "Isabelle", upc: 550402308674, imageURL: "https://images.mattel.com/scene7//wcsstore/MattelCAS/F9437_isabelle_mini_doll_1?storeId=10651&SKU=F9437"),
            ItemType(name: "Saige", upc: 550402284381, imageURL: "https://images-na.ssl-images-amazon.com/images/I/617krsaYcAL._AC_SY550_.jpg"),
            ItemType(name: "Lea", upc: 887961202007, imageURL: "https://images-na.ssl-images-amazon.com/images/I/71ctTzF9FfL._AC_SL1137_.jpg")
        ]
        
        let view = ItemTypesView(itemTypes: itemTypes, httpManager: manager, detailedViewItemTypeUPC: nil, showDetailedView: false)
        
        
        return  TabView {
            view
                .tabItem {
                    Image(systemName: "1.square.fill")
                    Text("Item Types")
                }
            view
                .tabItem {
                    Image(systemName: "2.square.fill")
                    Text("Second")
                }
            view
                .tabItem {
                    Image(systemName: "3.square.fill")
                    Text("Third")
                }
        }
    }
}
