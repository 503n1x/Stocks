//
//  Extensions.swift
//  Stocks
//
//  Created by Vit Gur on 16.05.2023.
//

import Foundation
import UIKit

extension UIColor {
    public static let darkIndigo = UIColor(red: 0.04, green: 0.19, blue: 0.27, alpha: 1.00)
}

extension StockViewContext {
    public init(
        stockInfoDTO: StockInfoDTO,
        currencySymbol: String = "USD"
    ) {
        self.symbol = Strings.StockView.ticker + stockInfoDTO.symbol
        self.marketStatus = Strings.StockView.marketStatus + stockInfoDTO.info
        self.capitalization = Strings.StockView.capitalization +
        "\(stockInfoDTO.marketCapitalization.formatted()) \(currencySymbol)"
        self.price = Strings.StockView.price + "\(stockInfoDTO.last.twoDigits) \(currencySymbol)"
    }
}

extension UInt64 {
    public func formatted() -> String {
        let number = Double(self)
        let trillion = number / 1_000_000_000_000
        let billion = number / 1_000_000_000
        let million = number / 1_000_000
        let thousand = number / 1000
        if trillion >= 1.0 {
            return "\(round(trillion * 10) / 10)T"
        } else if billion >= 1.0 {
            return "\(round(billion * 10) / 10)B"
        } else if million >= 1.0 {
            return "\(round(million * 10) / 10)M"
        } else if thousand >= 1.0 {
            return "\(round(thousand * 10) / 10)K"
        } else {
            return "\(Int(number))"
        }
    }
}

extension Double {
    var twoDigits: Double { (self * 100).rounded(.toNearestOrEven) / 100 }
}
