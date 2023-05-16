//
//  StockViewAppearance.swift
//  Stocks
//
//  Created by Vit Gur on 16.05.2023.
//

import Foundation
import UIKit

public protocol StockViewAppearanceType {
    var backgroundColor: UIColor { get }
    var titleTextFont: UIFont { get }
    var titleTextColor: UIColor { get }
    var marketStatusTextFont: UIFont { get }
    var marketStatusTextColor: UIColor { get }
    
    var capitalizationTextColor: UIColor { get }
    var capitalizationTextFont: UIFont { get }
    
    var symbolTextColor: UIColor { get }
    var symbolTextFont: UIFont { get }
    
    var priceTextColor: UIColor { get }
    var priceTextFont: UIFont { get }
    
    var verticalSpacing: CGFloat { get }
}

public struct StockViewDefaultAppearance: StockViewAppearanceType {
    public var backgroundColor: UIColor = .darkIndigo
    public var titleTextFont: UIFont = .boldSystemFont(ofSize: 20)
    public var titleTextColor: UIColor = .white
    public var marketStatusTextFont: UIFont = .boldSystemFont(ofSize: 20)
    public var marketStatusTextColor: UIColor = .white
    public var capitalizationTextColor: UIColor = .white
    public var capitalizationTextFont: UIFont = .boldSystemFont(ofSize: 20)
    public var symbolTextColor: UIColor = .white
    public var symbolTextFont: UIFont = .boldSystemFont(ofSize: 20)
    public var priceTextColor: UIColor = .white
    public var priceTextFont: UIFont = .boldSystemFont(ofSize: 20)
    public var verticalSpacing: CGFloat = 10
}
