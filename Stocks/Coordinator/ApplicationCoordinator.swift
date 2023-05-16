//
//  ApplicationCoordinator.swift
//  Stocks
//
//  Created by Vit Gur on 16.05.2023.
//

import Foundation
import UIKit

// MARK: - SceneCoordinator
public protocol SceneCoordinator {
    var rootViewController: UIViewController { get }
    func start()
}

// MARK: - ApplicationCoordinator
public class ApplicationCoordinator {
    private let initialViewControllerBuilder: ViewControllerBuilderType
    private let navigationController: UINavigationController
    
    init(
        initialViewControllerBuilder: ViewControllerBuilderType,
        navigationController: UINavigationController = .init()
    ) {
        self.initialViewControllerBuilder = initialViewControllerBuilder
        self.navigationController = navigationController
    }
}

extension ApplicationCoordinator: SceneCoordinator {
    public var rootViewController: UIViewController { navigationController }
    
    public func start() {
        navigationController.setViewControllers(
            [initialViewControllerBuilder.build()],
            animated: false
        )
    }
}

// MARK: - ViewControllerBuilderType
protocol ViewControllerBuilderType {
    func build() -> UIViewController
}

// MARK: - StockViewControllerBuilder
struct StockViewControllerBuilder: ViewControllerBuilderType {
    let stockId: String
    let stockLoader: StockLoaderType
    
    func build() -> UIViewController {
        StockViewController(viewModel: .init(stockId: stockId, stockLoader: stockLoader))
    }
}
