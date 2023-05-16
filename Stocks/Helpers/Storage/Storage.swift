
import Foundation

final public class Storage<Key: Hashable, Value>: StorageType {
    let memoryStorage: MemoryStorage<Key, Value>
    let diskStorage: DiskStorage<Key, Value>?
    
    public init(destination: CacheDestination,
                serializer: ObjectSerializer<Value>) {
        self.memoryStorage = MemoryStorage<Key, Value>()
        self.diskStorage = DiskStorage<Key, Value>(destination: destination,
                                                   serializer: serializer)
    }
    
    public func set(value: Value, key: Key, expiry: CacheExpiry) throws {
        memoryStorage.set(value: value, key: key, expiry: expiry)
        try diskStorage?.set(value: value, key: key, expiry: expiry)
    }
    
    public func cachedItem(forKey key: Key) throws -> CachedItem<Value>? {
        if let memoryStorageItem = memoryStorage.cachedItem(forKey: key) {
            return memoryStorageItem
        }
        
        if let diskStorageItem = try? diskStorage?.cachedItem(forKey: key) {
            memoryStorage.set(value: diskStorageItem.object, key: key, expiry: diskStorageItem.expiry)
            return diskStorageItem
        }
        return nil
    }
    
    public func removeItem(forKey key: Key) throws {
        memoryStorage.removeItem(forKey: key)
        try diskStorage?.removeItem(forKey: key)
    }
    
    public func removeAll() throws {
        memoryStorage.removeAll()
        try diskStorage?.removeAll()
    }
}
