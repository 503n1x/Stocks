
import Foundation

public class MemoryStorage<Key: Hashable, Value>: StorageType {
    
    private let cache = NSCache<WrappedKey, CachedObject<Value>>()
    public init() {}
    
    public func set(value: Value, key: Key, expiry: CacheExpiry) {
        let cachedObject = CachedObject(value, expiry: expiry)
        cache.setObject(cachedObject, forKey: WrappedKey(key))
    }
    
    public func cachedItem(forKey key: Key) -> CachedItem<Value>? {
        guard let cachedObject = cache.object(forKey: WrappedKey(key)) else { return nil }
        if cachedObject.isExpired == true {
            removeItem(forKey: key)
            return nil
        }
        return CachedItem(object: cachedObject.value,
                     expiry: cachedObject.expiry)
    }
    
    public func removeItem(forKey key: Key) {
        cache.removeObject(forKey: WrappedKey(key))
    }
    
    public func removeAll() {
        cache.removeAllObjects()
    }
}

private extension MemoryStorage {
    final class CachedObject<T>: NSObject  {
        let value: T
        let expiry: CacheExpiry
        let expiryDate: Date
        
        init(_ value: T,
             expiry: CacheExpiry) {
            self.value = value
            self.expiry = expiry
            self.expiryDate = expiry.expiryDate
        }
        
        var isExpired: Bool { expiryDate.timeIntervalSinceNow < 0 }
    }
    
    final class WrappedKey: NSObject {
        let key: Key
        
        init(_ key: Key) { self.key = key }
        
        override var hash: Int { return key.hashValue }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }
            return value.key == key
        }
    }
}
