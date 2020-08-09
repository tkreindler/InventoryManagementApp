//
//  ItemStatus.swift
//  InventoryManagement
//
//  Created by Tristan Kreindler on 7/21/20.
//  Copyright © 2020 Tristan Kreindler. All rights reserved.
//

import Foundation

// c# style enumeration
enum ItemStatus: Int32, Codable {
    case ordered = 0
    case inStock = 1
    case sold = 2
    var name: String {
        get {
            switch self {
            case .ordered:
                return "Ordered"
            case .inStock:
                return "In Stock"
            case .sold:
                return "Sold"
            }
        }
    }
}
