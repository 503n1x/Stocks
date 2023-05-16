
import Foundation

public protocol StorageType {
    associatedtype Key: Hashable
    associatedtype Value

    func set(value: Value, key: Key, expiry: CacheExpiry) throws
    
    func cachedItem(forKey key: Key) throws -> CachedItem<Value>?
    func object(forKey key: Key) throws -> Value?
    
    func removeItem(forKey key: Key) throws
    func removeAll() throws
}

public extension StorageType {
    func object(forKey key: Key) throws -> Value? {
        try cachedItem(forKey: key)?.object
    }
}
