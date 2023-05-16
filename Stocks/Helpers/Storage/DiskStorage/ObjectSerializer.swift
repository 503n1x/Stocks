
import Foundation

public class ObjectSerializer<T> {
    let toData: (T) throws -> Data
    let fromData: (Data) throws -> T
    
    public init(
        toData: @escaping (T) throws -> Data,
        fromData: @escaping (Data) throws -> T
    ) {
        self.toData = toData
        self.fromData = fromData
    }
}

public extension ObjectSerializer {
    struct TypeWrapper<T: Codable>: Codable {
        enum CodingKeys: String, CodingKey {
            case object
        }
        public let object: T
        
        public init(object: T) {
            self.object = object
        }
    }
    
    static func forCodable<U: Codable>(ofType: U.Type) -> ObjectSerializer<U> {
        let toData: (U) throws -> Data = { object in
            let wrapper = TypeWrapper<U>(object: object)
            let encoder = JSONEncoder()
            return try encoder.encode(wrapper)
        }
        
        let fromData: (Data) throws -> U = { data in
            let decoder = JSONDecoder()
            return try decoder.decode(TypeWrapper<U>.self, from: data).object
        }
        
        return ObjectSerializer<U>(toData: toData, fromData: fromData)
    }
}
