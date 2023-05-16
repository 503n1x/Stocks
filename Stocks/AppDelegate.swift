//
//  AppDelegate.swift
//  Stocks
//
//  Created by Vit Gur on 15.05.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: - Properties
    private let stockId = "146"
    private let stockLoader = StockLoader()
    
    private lazy var appCoordinator = ApplicationCoordinator(
        initialViewControllerBuilder: StockViewControllerBuilder(stockId: stockId, stockLoader: stockLoader)
    )
    
    var window: UIWindow?
   
    // MARK: -
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = appCoordinator.rootViewController
        window?.makeKeyAndVisible()
        
        appCoordinator.start()
        
        return true
    }
}

