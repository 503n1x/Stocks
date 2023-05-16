//
//  StockViewController.swift
//  Stocks
//
//  Created by Vit Gur on 16.05.2023.
//

import Foundation
import Combine
import UIKit

public class StockViewController: BaseViewController<StockViewModel> {
    private var customView: StockViewType? { view as? StockViewType }
    private let onViewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let onRetrySubject = PassthroughSubject<Void, Never>()
    private var bindings = Set<AnyCancellable>()
    
    // MARK: View lifecycle
    public override func loadView() {
        let view = StockView(frame: .zero)
        self.view = view
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        onViewDidLoadSubject.send(())
    }
    
    // MARK: Binding
    public override func bind() {
        let viewModelInput = StockViewModel.Input(
            onViewDidLoad: onViewDidLoadSubject.eraseToAnyPublisher(),
            onRetry: onRetrySubject.eraseToAnyPublisher()
        )
        
        let viewModelOutput = viewModel.transform(viewModelInput)
        
        viewModelOutput.updateContextPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] context in
                self?.customView?.render(with: context)
            }
            .store(in: &bindings)
        
        viewModelOutput.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.customView?.updateIsLoading(isLoading)
            }
            .store(in: &bindings)
        
        viewModelOutput.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.show(error: error)
            }
            .store(in: &bindings)
    }
}

private extension StockViewController {
    func show(error: Error) {
        let errorMessage: String = {
            if error.localizedDescription.isEmpty {
                return "Unknown error"
            } else {
                return error.localizedDescription
            }
        }()
        
        let alertController = UIAlertController(
            title: "Error has occured",
            message: errorMessage,
            preferredStyle: .alert
        )
        
        alertController.addAction(
            .init(
                title: "Retry",
                style: .default,
                handler: { [weak self] _ in
                    self?.onRetrySubject.send(())
                }
            )
        )
        alertController.addAction(.init(title: "Close", style: .cancel))
        navigationController?.present(alertController, animated: true)
    }
}
