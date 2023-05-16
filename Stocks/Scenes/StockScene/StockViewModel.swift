//
//  StockViewModel.swift
//  Stocks
//
//  Created by Vit Gur on 16.05.2023.
//

import Combine
import Foundation

public class StockViewModel: GeneralViewModelProtocol {
    private enum Constants {
        static let updateTimeInterval: TimeInterval = 2.0
    }
    
    public struct Input {
        let onViewDidLoad: AnyPublisher<Void, Never>
        let onRetry: AnyPublisher<Void, Never>
    }
    
    public struct Output {
        let updateContextPublisher: AnyPublisher<StockViewContext, Never>
        let isLoadingPublisher: AnyPublisher<Bool, Never>
        let errorPublisher: AnyPublisher<Error, Never>
    }
    
    private var bindings = Set<AnyCancellable>()
    private let stockId: String
    private let errorSubject: PassthroughSubject<Error, Never> = .init()
    private let isLoadingSubject: CurrentValueSubject<Bool, Never> = .init(false)
    private var cancellable: AnyCancellable?
    private let stockLoader: StockLoaderType
    
    init(
        stockId: String,
        stockLoader: StockLoaderType
    ) {
        self.stockId = stockId
        self.stockLoader = stockLoader
    }
    
    public func transform(_ input: Input) -> Output {
        let timerUpdatePublisher =
        Timer.publish(
            every: Constants.updateTimeInterval,
            on: .main,
            in: .common
        )
        .autoconnect()
        .dropFirst()
        .map { _ in }
       
        let startLoadingContextPublisher: AnyPublisher<Void, Never> = Publishers
            .Merge3(timerUpdatePublisher, input.onViewDidLoad, input.onRetry)
            .eraseToAnyPublisher()
        
        cancellable = startLoadingContextPublisher.sink(receiveValue: { [weak self] _ in
            self?.isLoadingSubject.send(true)
        })
         
        let updateContextPublisher: AnyPublisher<StockViewContext, Never> = startLoadingContextPublisher
            .combineLatest(Just(stockId))
            .flatMap { [unowned self] in
                self.stockLoader.loadStockInfoForStockWithId($0.1)
            }
            .catch { [ unowned self] error in
                self.errorSubject.send(error)
                return Just(StockInfoDTO.mocked())
            }
            .eraseToAnyPublisher()
            .map { [weak self] in
                self?.isLoadingSubject.send(false)
                return StockViewContext(stockInfoDTO: $0)
            }
            .eraseToAnyPublisher()

        return Output(
            updateContextPublisher: updateContextPublisher,
            isLoadingPublisher: isLoadingSubject.eraseToAnyPublisher(),
            errorPublisher: errorSubject.eraseToAnyPublisher()
        )
    }
}
