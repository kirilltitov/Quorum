import Foundation
import LGNCore
import LGNLog
import FDB
import FDBEntity

//MARK:- General
extension Int {
    func clamped(min: Int? = nil, max: Int? = nil) -> Int {
        if let min = min, self < min {
            return min
        }
        if let max = max, self > max {
            return max
        }
        return self
    }
}

public extension Data {
    var _bytes: Bytes {
        Bytes(self)
    }

    var _string: String {
        String(decoding: self, as: UTF8.self)
    }
}

infix operator =>
public func =><T: RawRepresentable & Equatable>(lhs: T, rhs: [T]) -> Bool {
    return rhs.contains(lhs)
}

//MARK:- FDB

public extension Bytes {
    /// Value of a counter maintained with atomic `add` (little-endian 64-bit integer), `0` for malformed values
    var counterValue: Int {
        guard self.count == 8 else {
            Logger.current.error("Malformed counter value \(self)")
            return 0
        }
        return Int(Int64(littleEndian: self.withUnsafeBytes { $0.loadUnaligned(as: Int64.self) }))
    }
}

public extension Optional where Wrapped == Bytes {
    var counterValue: Int {
        self?.counterValue ?? 0
    }
}

public protocol QuorumEntity: FDB.Entity {}

public extension QuorumEntity {
    static var format: FDB.EntityFormat { .JSON }
    static var fullEntityName: Bool { false }
    static var subspace: FDB.Subspace { App.current.subspaceMain }
    static var storage: any FDB.Transactor { App.current.fdb }
}

public protocol Model: QuorumEntity where Identifier == FDB.UUID {}

public protocol ModelInt: QuorumEntity where Identifier == Int {}

public extension ModelInt {
    /// Key of the ID sequence of this entity (shared with Entita2 layout)
    static var sequenceKey: FDB.Subspace {
        Self.subspace["idx"][Self.entityName]
    }

    /// Next ID of the sequence, within given transaction
    static func getNextID(within transaction: borrowing FDB.Transaction) async throws -> Int {
        transaction.atomic(.add, key: Self.sequenceKey, value: Int64(1))
        return try await transaction.get(key: Self.sequenceKey).value.counterValue
    }
}

//MARK:- Sequence

public extension Sequence {
    func asyncMap<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
        var result: [T] = []
        result.reserveCapacity(self.underestimatedCount)
        for element in self {
            result.append(try await transform(element))
        }
        return result
    }
}
