//
//  Localizable.swift
//  Stocks
//
//  Created by Vit Gur on 16.05.2023.
//

import Foundation

public enum Strings {
    public enum StockView {
        static let title = "Stock information".localized
        static let ticker = "Stock ticker".localized + ": "
        static let marketStatus = "Market status".localized + ": "
        static let capitalization = "Market capitalization".localized + ": "
        static let price = "Current price".localized + ": "
    }
}

public extension String {
    var localized: String { NSLocalizedString(self, comment: "")}
}
