//
//  Item.swift
//  InventoryManagement
//
//  Created by Tristan Kreindler on 7/21/20.
//  Copyright © 2020 Tristan Kreindler. All rights reserved.
//

import Foundation

class Item : ItemNoId {
    init(id: Int64, itemTypeUPC: Int64, qrCode: String?, itemStatus: ItemStatus, pricePaidBySeller: Decimal, shippingCostToSeller: Decimal, shippingCostToBuyer: Decimal, fees: Decimal, otherExpenses: Decimal, shippingPaidByBuyer: Decimal, pricePaidByBuyer: Decimal, orderNumber: String?) {
        self.id = id
        super.init(itemTypeUPC: itemTypeUPC, qrCode: qrCode, itemStatus: itemStatus, pricePaidBySeller: pricePaidBySeller, shippingCostToSeller: shippingCostToSeller, shippingCostToBuyer: shippingCostToBuyer, fees: fees, otherExpenses: otherExpenses, shippingPaidByBuyer: shippingPaidByBuyer, pricePaidByBuyer: pricePaidByBuyer, orderNumber: orderNumber)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(Int64.self, forKey: .id)
        try super.init(from: decoder)
    }
    
    var id: Int64
    
    var profit: Decimal {
        get {
            return revenues - expenses
        }
    }
    
    // Expenses
    var expenses: Decimal {
        get {
            return pricePaidBySeller + shippingCostToBuyer + shippingCostToSeller + fees + otherExpenses;
        }
    }
}

class ItemNoId : Codable {
    init(itemTypeUPC: Int64, qrCode: String?, itemStatus: ItemStatus, pricePaidBySeller: Decimal, shippingCostToSeller: Decimal, shippingCostToBuyer: Decimal, fees: Decimal, otherExpenses: Decimal, shippingPaidByBuyer: Decimal, pricePaidByBuyer: Decimal, orderNumber: String?) {
        self.itemTypeUPC = itemTypeUPC
        self.qrCode = qrCode
        self.itemStatus = itemStatus
        self.pricePaidBySeller = pricePaidBySeller
        self.shippingCostToSeller = shippingCostToSeller
        self.shippingCostToBuyer = shippingCostToBuyer
        self.fees = fees
        self.otherExpenses = otherExpenses
        self.shippingPaidByBuyer = shippingPaidByBuyer
        self.pricePaidByBuyer = pricePaidByBuyer
        self.orderNumber = orderNumber
    }
    
    convenience init(itemTypeUPC: Int64) {
        self.init(itemTypeUPC: itemTypeUPC, qrCode: nil, itemStatus: .ordered, pricePaidBySeller: 0, shippingCostToSeller: 0, shippingCostToBuyer: 0, fees: 0, otherExpenses: 0, shippingPaidByBuyer: 0, pricePaidByBuyer: 0, orderNumber: nil)
    }
    
    convenience init(item: Item) {
        self.init(itemTypeUPC: item.itemTypeUPC, qrCode: item.qrCode, itemStatus: item.itemStatus, pricePaidBySeller: item.pricePaidBySeller, shippingCostToSeller: item.shippingCostToSeller, shippingCostToBuyer: item.shippingCostToBuyer, fees: item.fees, otherExpenses: item.otherExpenses, shippingPaidByBuyer: item.shippingPaidByBuyer, pricePaidByBuyer: item.pricePaidByBuyer, orderNumber: nil)
    }
    
    var itemTypeUPC: Int64
    var qrCode: String?
    var orderNumber: String?
    var itemStatus: ItemStatus
    
    var pricePaidBySeller: Decimal
    var shippingCostToSeller: Decimal
    var shippingCostToBuyer: Decimal
    var fees: Decimal
    var otherExpenses: Decimal
    
    // Revenues
    var revenues: Decimal {
        get {
            return shippingPaidByBuyer + pricePaidByBuyer;
        }
    }
    
    var shippingPaidByBuyer: Decimal
    var pricePaidByBuyer: Decimal
}