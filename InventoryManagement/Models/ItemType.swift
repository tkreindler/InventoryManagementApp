//
//  ItemType.swift
//  InventoryManagement
//
//  Created by Tristan Kreindler on 7/21/20.
//  Copyright © 2020 Tristan Kreindler. All rights reserved.
//

import Foundation

class ItemType: Codable {
    let name: String
    let upc: Int64
    let imageURL: String?
    
    init(name: String, upc: Int64, imageURL: String? = nil) {
        self.name = name
        self.upc = upc
        self.imageURL = imageURL
    }
}
