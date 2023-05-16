//
//  BaseViewController.swift
//  Stocks
//
//  Created by Vit Gur on 16.05.2023.
//

import Foundation
import UIKit

open class BaseViewController<T: GeneralViewModelProtocol>: UIViewController, ViewModelAssociated {
    public typealias ViewModel = T
    public var viewModel: T
    
    public required init(viewModel: T) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bind()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func bind() {
        fatalError("binding has not been implemented")
    }
}

public protocol GeneralViewModelProtocol {
    associatedtype Input
    associatedtype Output
    func transform(_ input: Input) -> Output
}

public protocol ViewModelAssociated: AnyObject {
    associatedtype ViewModel: GeneralViewModelProtocol
    var viewModel: ViewModel { get }
    init(viewModel: ViewModel)
    func bind()
}
