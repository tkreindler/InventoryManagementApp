//
//  TabbedView.swift
//  InventoryManagement
//
//  Created by Tristan Kreindler on 7/22/20.
//  Copyright © 2020 Tristan Kreindler. All rights reserved.
//

import SwiftUI

struct TabbedView: View {
    @ObservedObject var httpManager: HttpManager
    @State var selectedTab: Tab = .itemTypes
    
    var body: some View {
        TabView(selection: self.$selectedTab) {
            ItemTypesView(httpManager: httpManager)
                .tabItem {
                    Text("Item Types")
                }
                .tag(Tab.itemTypes)
            // exclude the camera heavy functionaliry from the mac version
            #if !targetEnvironment(macCatalyst)
            ScannerTabView(httpManager: httpManager, tabSelected: self.$selectedTab)
                .tabItem {
                    Text("Scanner")
                }
                .tag(Tab.scanner)
            #endif
            OrdersView(httpManager: httpManager)
                .tabItem {
                    Text("Orders")
                }
                .tag(Tab.orders)
            OtherView(httpManager: httpManager)
                .tabItem {
                    Text("Other")
                }
                .tag(Tab.other)
        }
    }
}

struct TabbedView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = HttpManager()
        manager.postAuth(username: DebugLoginInfo.username, password: DebugLoginInfo.password)
        return TabbedView(httpManager: manager)
    }
}

enum Tab: Hashable {
    case itemTypes
    case scanner
    case orders
    case other
}
