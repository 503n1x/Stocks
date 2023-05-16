//
//  StockLoader.swift
//  Stocks
//
//  Created by Vit Gur on 16.05.2023.
//

import Combine
import Foundation

public protocol StockLoaderType {
    func loadStockInfoForStockWithId(_ id: String) -> AnyPublisher<StockInfoDTO, Error>
}

//TODO: Improve with Network manager + StockLoaderType for both network and cache

class StockLoader: StockLoaderType {
    private enum StockLoaderError: LocalizedError {
        case statusCode
        case invalidURL
        case incorrectResponse
    }
    
    private var cancellable: AnyCancellable?
    private var storage: Storage<String, StockInfoDTO> =
        .init(
            destination: .temporary,
            serializer: .forCodable(ofType: StockInfoDTO.self)
        )
    
    func loadStockInfoForStockWithId(
        _ id: String
    ) -> AnyPublisher<StockInfoDTO, Error> {
        if let cachedStockInfo = try? storage.cachedItem(forKey: id)?.object {
            return Just(cachedStockInfo)
                .setFailureType(to: Error.self)
                .merge(with: loadStockInfoForStockWithIdRequest(id))
                .share()
                .eraseToAnyPublisher()
        } else {
            return loadStockInfoForStockWithIdRequest(id)
                .share()
                .eraseToAnyPublisher()
        }
    }
    
    func loadStockInfoForStockWithIdRequest(
        _ id: String
    ) -> AnyPublisher<StockInfoDTO, Error> {
        
        guard let url =
                URL(string: "https://finance-api.seekingalpha.com/real_time_quotes?sa_ids=\(id)")
        else {
            return Fail(error: StockLoaderError.invalidURL).eraseToAnyPublisher()
        }
                
        let stockInfoSubject: PassthroughSubject<StockInfoDTO, Error> = .init()
        
        self.cancellable = URLSession.shared.dataTaskPublisher(for: url)
        .tryMap { output in
            guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                throw StockLoaderError.statusCode
            }
            return output.data
        }
        .decode(type: ResponseModel.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
        .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                stockInfoSubject.send(completion: .failure(error))
            }
        }, receiveValue: { [weak self] response in
            if let stockInfo = response.stockInfo.first {
                try? self?.storage.set(value: stockInfo, key: id, expiry: .never)
                stockInfoSubject.send(stockInfo)
            } else {
                stockInfoSubject.send(completion: .failure(StockLoaderError.incorrectResponse))
            }
        })
        
        return stockInfoSubject.eraseToAnyPublisher()
    }
}
