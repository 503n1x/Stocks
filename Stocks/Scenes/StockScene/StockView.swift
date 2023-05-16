//
//  StockView.swift
//  Stocks
//
//  Created by Vit Gur on 16.05.2023.
//

import Foundation
import UIKit

public struct StockViewContext: Equatable {
    let symbol: String
    let marketStatus: String
    let capitalization: String
    let price: String
}

public protocol StockViewType {
    var appearance: StockViewAppearanceType { get set }
    func render(with context: StockViewContext)
    func updateIsLoading(_ isLoading: Bool)
}

public final class StockView: UIView, StockViewType {
    //MARK: - Private
    private lazy var containerView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .leading
        return stackView
    }()
    
    private lazy var titleHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.spacing = 10.0
        [titleLabel, activityIndicator].forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = .init()
    private lazy var symbolLabel: UILabel = .init()
    private lazy var priceLabel: UILabel = .init()
    private lazy var marketStatusLabel: UILabel = .init()
    private lazy var capitalizationLabel: UILabel = .init()
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator: UIActivityIndicatorView = .init(style: .medium)
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    private var currentContext: StockViewContext?
    
    //MARK: - Public
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        
        addSubviews()
        applyAppearance()
        makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var appearance: StockViewAppearanceType = StockViewDefaultAppearance() {
        didSet {
            applyAppearance()
        }
    }
    
    public func render(with context: StockViewContext) {
        guard currentContext != context else { return }
        currentContext = context
        
        symbolLabel.text = context.symbol
        priceLabel.text = context.price
        marketStatusLabel.text = context.marketStatus
        capitalizationLabel.text = context.capitalization
    }
    
    public func updateIsLoading(_ isLoading: Bool) {
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
}

private extension StockView {
    func addSubviews() {
        addSubview(containerView)
        [
            titleHorizontalStackView,
            symbolLabel,
            priceLabel,
            marketStatusLabel,
            capitalizationLabel,
        ].forEach(containerView.addArrangedSubview(_:))
    }

     func makeConstraints() {
         containerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
         containerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

     func applyAppearance() {
         containerView.setCustomSpacing(20, after: titleHorizontalStackView)
         backgroundColor = appearance.backgroundColor
         
         titleLabel.text = Strings.StockView.title.uppercased()

         [
            symbolLabel,
            priceLabel,
            marketStatusLabel,
            capitalizationLabel,
         ].forEach {
             $0.textAlignment = .left
         }
         
         activityIndicator.color = appearance.titleTextColor
         
         titleLabel.font = appearance.titleTextFont
         titleLabel.textColor =  appearance.titleTextColor
         symbolLabel.font = appearance.symbolTextFont
         symbolLabel.textColor = appearance.symbolTextColor
         priceLabel.font = appearance.priceTextFont
         priceLabel.textColor = appearance.priceTextColor
         marketStatusLabel.font = appearance.marketStatusTextFont
         marketStatusLabel.textColor = appearance.marketStatusTextColor
         capitalizationLabel.font = appearance.capitalizationTextFont
         capitalizationLabel.textColor = appearance.capitalizationTextColor
         
         containerView.spacing = appearance.verticalSpacing
    }
}
