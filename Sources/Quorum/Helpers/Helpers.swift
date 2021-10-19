import Foundation
import LGNCore
import Entita2FDB
import FDB

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
        self._bytes._string
    }
}

public extension Date {
    static var now: Self {
        Self()
    }
}

//MARK:- FDB
public extension FDB.Tuple {
    var _string: String {
        return self.tuple
            .map { String(describing: $0) }
            .joined(separator: " / ")
    }
}

public extension FDB.Subspace {
    var _string: String {
        return (try? FDB.Tuple(from: self.prefix)._string) ?? "\(self)"
    }
}

public extension AnyFDBKey {
    var _string: String {
        return (try? FDB.Tuple(from: self.asFDBKey())._string) ?? "\(self)"
    }
}

//MARK:- General
infix operator =>
public func =><T: RawRepresentable & Equatable>(lhs: T, rhs: [T]) -> Bool {
    return rhs.contains(lhs)
}

//MARK:- Entita2FDB
public extension E2FDBEntity {
    static var format: E2.Format { .JSON }
    static var subspace: FDB.Subspace { App.current.subspaceMain }
    static var storage: some E2FDBStorage { App.current.fdb }
}

public protocol Model: E2FDBEntity {
    override associatedtype Identifier = E2.UUID
}

public protocol ModelInt: E2FDBEntity {
    override associatedtype Identifier = Int
}

public extension Model {
    func insert(within transaction: AnyFDBTransaction?, commit: Bool = true) async throws {
        try await self.insert(within: transaction as? AnyTransaction, commit: commit)
    }

    func save(by ID: Identifier? = nil, within transaction: AnyFDBTransaction?, commit: Bool = true) async throws {
        try await self.save(by: ID, within: transaction as? AnyTransaction, commit: commit)
    }

    func delete(within transaction: AnyFDBTransaction?, commit: Bool = true) async throws {
        try await self.delete(within: transaction as? AnyTransaction, commit: commit)
    }
}

public extension ModelInt {
    static func getNextID() async throws -> Int {
        try await Self.storage.withTransaction { transaction in
            try await Self.getNextID(commit: true, within: transaction)
        }
    }

    static func getNextID(commit: Bool = true, within transaction: AnyFDBTransaction) async throws -> Int {
        let key = Self.subspace["idx"][Self.entityName]

        transaction.atomic(.add, key: key, value: Int(1))

        let maybeBytes = try await transaction.get(key: key)

        if commit {
            try await transaction.commit()
        }

        return try maybeBytes!.cast()
    }
}

//MARK:- Migrations

public typealias Migrations = [() async throws -> Void]

func runMigrations(_ migrations: Migrations, on fdb: FDB) async {
    let logger = Logger(label: "Quorum.Migrations")
    let key = App.current.subspaceMain["migration"]
    var lastState: Int
    do {
        logger.info("Loading last migration state at key \(key)")
        let lastMigration = try await fdb.get(key: key)
        logger.info("Last migration state loaded: \(String(describing: lastMigration))")
        if lastMigration == nil {
            let initial: Int = 0
            try await fdb.set(key: key, value: LGNCore.getBytes(initial))
            lastState = initial
        } else {
            lastState = try lastMigration!.cast()
        }
    } catch {
        fatalError("Could not read migration state from fdb: \(error)")
    }
    guard migrations.count > lastState else {
        logger.info("DB state is up to date, no need to perform migrations")
        return
    }
    logger.info("Performing migrations")
    for idx in lastState..<migrations.count {
        let migration = migrations[idx]
        do {
            logger.info("Trying to apply migration #\(idx)")
            try await migration()
            try await fdb.set(key: key, value: LGNCore.getBytes(idx + 1))
            logger.info("Successfully applied migration #\(idx)")
        } catch {
            logger.critical("Could not run migration #\(idx): \(error)")
            exit(1)
        }
    }
}

//MARK:- Sequence

public extension Sequence {
    @inlinable
    func map<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
        let initialCapacity = self.underestimatedCount
        var result = ContiguousArray<T>()
        result.reserveCapacity(initialCapacity)

        var iterator = self.makeIterator()

        // Add elements up to the initial capacity without checking for regrowth.
        for _ in 0..<initialCapacity {
            result.append(try await transform(iterator.next()!))
        }
        // Add remaining elements, if any.
        while let element = iterator.next() {
            result.append(try await transform(element))
        }
        return Array(result)
    }

    @inlinable
    func compactMap<T>(_ transform: (Element) async throws -> T?) async rethrows -> [T] {
        try await self
            .map(transform)
            .compactMap { $0 }
    }
}
