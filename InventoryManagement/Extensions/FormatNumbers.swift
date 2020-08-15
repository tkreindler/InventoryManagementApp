//
//  FormatUPC.swift
//  InventoryManagement
//
//  Created by Tristan Kreindler on 7/22/20.
//  Copyright © 2020 Tristan Kreindler. All rights reserved.
//

import Foundation

let upcFormatter: NumberFormatter = {
    let c = NumberFormatter()
    c.usesGroupingSeparator = false
    c.numberStyle = .none
    c.minimumIntegerDigits = 12
    c.allowsFloats = false
    c.paddingCharacter = "0"
    return c
}()

extension Int64 {
    var formattedAsUPC: String {
        return upcFormatter.string(from: NSNumber(value: self)) ?? ""
    }
    var formattedNoSeparator: String {
        return unseparatedFormatter.string(from: NSNumber(value: self)) ?? ""
    }
}

let currencyFormatter: NumberFormatter = {
    let c = NumberFormatter()
    c.usesGroupingSeparator = true
    c.numberStyle = .currency
    c.locale = Locale.current
    return c
}()

let separatedFormatter: NumberFormatter = {
    let c = NumberFormatter()
    c.usesGroupingSeparator = true
    return c
}()

let unseparatedFormatter: NumberFormatter = {
    let c = NumberFormatter()
    c.usesGroupingSeparator = false
    return c
}()

// helper function to try many different parsers
func parseMoney(string: String) -> Decimal? {
    if string.isEmpty {
        return 0
    }
    if let x = currencyFormatter.number(from: string)?.decimalValue {
        return x
    }
    if let x = unseparatedFormatter.number(from: string)?.decimalValue {
        return x
    }
    return separatedFormatter.number(from: string)?.decimalValue
}

extension Decimal {
    var formattedAsMoney: String {
        return currencyFormatter.string(from: NSDecimalNumber(decimal: self)) ?? ""
    }
    var formattedNoSeparator: String {
        return unseparatedFormatter.string(from: NSDecimalNumber(decimal: self)) ?? ""
    }
}
