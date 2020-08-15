//
//  Item.swift
//  InventoryManagement
//
//  Created by Tristan Kreindler on 7/21/20.
//  Copyright © 2020 Tristan Kreindler. All rights reserved.
//

import Foundation

class Item : ItemNoId {
    init(id: Int64, itemTypeUPC: Int64, qrCode: String?, itemStatus: ItemStatus, pricePaidBySeller: Decimal, taxPaidBySeller: Decimal, shippingCostToSeller: Decimal, shippingCostToBuyer: Decimal, fees: Decimal, otherExpenses: Decimal, shippingPaidByBuyer: Decimal, pricePaidByBuyer: Decimal, orderNumberToSeller: String?, orderNumberToBuyer: String?) {
        self.id = id
        super.init(itemTypeUPC: itemTypeUPC, qrCode: qrCode, itemStatus: itemStatus, pricePaidBySeller: pricePaidBySeller, taxPaidBySeller: taxPaidBySeller, shippingCostToSeller: shippingCostToSeller, shippingCostToBuyer: shippingCostToBuyer, fees: fees, otherExpenses: otherExpenses, shippingPaidByBuyer: shippingPaidByBuyer, pricePaidByBuyer: pricePaidByBuyer, orderNumberToSeller: orderNumberToSeller, orderNumberToBuyer: orderNumberToBuyer)
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
            return pricePaidBySeller + taxPaidBySeller + shippingCostToBuyer + shippingCostToSeller + fees + otherExpenses;
        }
    }
}

class ItemNoId : Codable {
    init(itemTypeUPC: Int64, qrCode: String?, itemStatus: ItemStatus, pricePaidBySeller: Decimal, taxPaidBySeller: Decimal, shippingCostToSeller: Decimal, shippingCostToBuyer: Decimal, fees: Decimal, otherExpenses: Decimal, shippingPaidByBuyer: Decimal, pricePaidByBuyer: Decimal, orderNumberToSeller: String?, orderNumberToBuyer: String?) {
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
        self.orderNumberToSeller = orderNumberToSeller
        self.orderNumberToBuyer = orderNumberToBuyer
        self.taxPaidBySeller = taxPaidBySeller
    }
    
    convenience init(itemTypeUPC: Int64) {
        self.init(itemTypeUPC: itemTypeUPC, qrCode: nil, itemStatus: .ordered, pricePaidBySeller: 0, taxPaidBySeller: 0, shippingCostToSeller: 0, shippingCostToBuyer: 0, fees: 0, otherExpenses: 0, shippingPaidByBuyer: 0, pricePaidByBuyer: 0, orderNumberToSeller: nil, orderNumberToBuyer: nil)
    }
    
    convenience init(item: Item) {
        self.init(itemTypeUPC: item.itemTypeUPC, qrCode: item.qrCode, itemStatus: item.itemStatus, pricePaidBySeller: item.pricePaidBySeller, taxPaidBySeller: item.taxPaidBySeller, shippingCostToSeller: item.shippingCostToSeller, shippingCostToBuyer: item.shippingCostToBuyer, fees: item.fees, otherExpenses: item.otherExpenses, shippingPaidByBuyer: item.shippingPaidByBuyer, pricePaidByBuyer: item.pricePaidByBuyer, orderNumberToSeller: nil, orderNumberToBuyer: nil)
    }
    
    var itemTypeUPC: Int64
    var qrCode: String?
    var orderNumberToSeller: String?
    var orderNumberToBuyer: String?
    var itemStatus: ItemStatus
    
    var pricePaidBySeller: Decimal
    var taxPaidBySeller: Decimal
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
