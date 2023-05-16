//
//  Models.swift
//  Stocks
//
//  Created by Vit Gur on 16.05.2023.
//

import Foundation

public struct ResponseModel: Codable {
    let stockInfo: [StockInfoDTO]
    private enum CodingKeys: String, CodingKey {
        case stockInfo = "real_time_quotes"
    }
}

public struct StockInfoDTO: Codable {
    let saId: UInt64
    let symbol: String
    let last: Double
    let info: String
    let marketCapitalization: UInt64
    
    private enum CodingKeys: String, CodingKey {
        case saId = "sa_id"
        case symbol, last, info
        case marketCapitalization = "market_cap"
    }
}

extension StockInfoDTO {
    static func mocked() -> StockInfoDTO { .init(saId: 0, symbol: "", last: 0.0, info: "", marketCapitalization: 0) }
}
