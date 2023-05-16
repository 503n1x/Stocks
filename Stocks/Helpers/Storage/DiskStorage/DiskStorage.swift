import Foundation

public enum CacheDestination {
    case temporary
    case atFolder(String)
}

public final class DiskStorage<Key: Hashable,
                               Value> {
    private let directoryPath: String
    private let fileManager: FileManager
    private let serializer: ObjectSerializer<Value>
    private let barrierQueue = DispatchQueue(label: "vitgur.diskStorage.barrierQueue",
                                             attributes: .concurrent)
    
    public required init?(
        destination: CacheDestination,
        fileManager: FileManager = .default,
        serializer: ObjectSerializer<Value>
    ) {
        
        self.serializer = serializer
        self.fileManager = fileManager
        
        let directoryPath: String
        
        switch destination {
        case .temporary:
            directoryPath = NSTemporaryDirectory()
        case .atFolder(let folder):
            let documentFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            directoryPath = (documentFolder as NSString).appendingPathComponent(folder)
            var isDirectory: ObjCBool = false
            if fileManager.fileExists(atPath: directoryPath, isDirectory: &isDirectory) && isDirectory.boolValue {
                self.directoryPath = directoryPath
                return
            }
        }
        
        do {
            try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
            self.directoryPath = directoryPath
            return
        } catch {}
        
        
        return nil
    }
    
    public func set(value: Value, key: Key, expiry: CacheExpiry) throws {
        try barrierQueue.sync(flags: .barrier, execute: {
            try self.add(value: value, key: key, expiry: expiry)
        })
    }
    
    public func cachedItem(forKey key: Key) throws -> CachedItem<Value>? {
        var item: CachedItem<Value>?
        try barrierQueue.sync(flags: .barrier, execute: {
            item = try self.readItem(for: key)
        })
        
        guard let item = item else { return nil }
        
        if item.expiry.isExpired {
            try removeItem(forKey: key)
            return nil
        }
        
        return item
    }
    
    public func removeItem(forKey key: Key) throws {
        try barrierQueue.sync(flags: .barrier, execute: {
            try self.removeEntry(for: key)
        })
    }
    
    public func removeAll() throws {
        try self.barrierQueue.sync(flags: .barrier, execute: {
            try fileManager.removeItem(atPath: directoryPath)
            try createDirectory()
        })
    }
}

private extension DiskStorage {
    //MARK: Not thread safe methods
    func add(value: Value, key: Key, expiry: CacheExpiry) throws {
        let data = try serializer.toData(value)
        let filePath = filePathForKey(key)
        
        _ = fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
        try fileManager.setAttributes([.modificationDate: expiry.expiryDate], ofItemAtPath: filePath)
    }
    
    func readItem(for key: Key) throws -> CachedItem<Value>? {
        let filePath = filePathForKey(key)
        let data = try Data(contentsOf: URL(fileURLWithPath: filePath, isDirectory: false))
        let attributes = try fileManager.attributesOfItem(atPath: filePath)
        let object = try serializer.fromData(data)
        
        guard let date = attributes[.modificationDate] as? Date else {
            return nil
        }
        
        return CachedItem(
            object: object,
            expiry: CacheExpiry.date(date),
            filePath: filePath
        )
    }
    
    func removeEntry(for key: Key) throws {
        let filePath = filePathForKey(key)
        try fileManager.removeItem(atPath: filePath)
    }
    
    //MARK: Helpers
    func filePathForKey(_ key: AnyHashable) -> String {
        (self.directoryPath as NSString).appendingPathComponent(String(key.description))
    }
    
    func createDirectory() throws {
        guard !fileManager.fileExists(atPath: directoryPath) else {
            return
        }
        
        try fileManager.createDirectory(atPath: directoryPath,
                                        withIntermediateDirectories: true,
                                        attributes: nil)
    }
}
