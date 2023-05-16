
import Foundation

public enum CacheExpiry {
    case never
    case seconds(TimeInterval)
    case minutes(UInt)
    case hours(UInt)
    case date(Date)
    
    var expiryDate: Date {
        switch self {
        case .never:
            return Date.distantFuture
        case .seconds(let seconds):
            return Date().addingTimeInterval(seconds)
        case .minutes(let minutes):
            return Date().addingTimeInterval(Double(minutes) * 60)
        case .hours(let hours):
            return Date().addingTimeInterval(Double(hours) * 60 * 60)
        case .date(let date):
            return date
        }
    }
    
    var isExpired: Bool { expiryDate.timeIntervalSinceNow < 0 }
}

public struct CachedItem<T> {
    public let object: T
    public let expiry: CacheExpiry
    public let filePath: String?
    
    init(
        object: T,
        expiry: CacheExpiry,
        filePath: String? = nil
    ) {
        self.object = object
        self.expiry = expiry
        self.filePath = filePath
    }
}
