//
//  ScannerTabView.swift
//  InventoryManagement
//
//  Created by Tristan Kreindler on 7/28/20.
//  Copyright © 2020 Tristan Kreindler. All rights reserved.
//

import SwiftUI

struct ScannerTabView: View {
    var httpManager: HttpManager
    @State var selectedItem: Item? = nil
    @State var selectedItemParent: ItemType? = nil
    @State var showingFocused: Bool = false
    
    @Binding private var tabSelected: Tab
    
    init(httpManager: HttpManager, tabSelected: Binding<Tab>) {
        self.httpManager = httpManager
        self._tabSelected = tabSelected
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if tabSelected == .scanner {
                    if selectedItem != nil && selectedItemParent != nil {
                        NavigationLink(
                            destination: ItemDetailedView(item: self.selectedItem!, httpManager: self.httpManager, parent: selectedItemParent!),
                            isActive: self.$showingFocused,
                            label: {
                                Text("")
                            })
                            .hidden()
                    }
                    if showingFocused == false {
                        CodeScannerView(
                            codeTypes: [.qr],
                            completion: { result in
                                if case let .success(code) = result {
                                    self.httpManager.getItemByQR(qr: code) {
                                        item in
                                        self.httpManager.getItemType(upc: item.itemTypeUPC) {
                                            parent in
                                            self.selectedItem = item
                                            self.showingFocused = true
                                            self.selectedItemParent = parent
                                        }
                                    }
                                }
                            }
                        )
                        .navigationBarHidden(true)
                    }
                } else {
                    Text("")
                }
            }
        }
    }
}
