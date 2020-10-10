import Foundation
import LGNCore
import Entita2FDB
import FDB
import NIO

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
    static var now: Date {
        return Date()
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

//MARK:- EventLoopFuture
public extension EventLoopFuture {
    func flatMapThrowing<NewValue>(
        file: StaticString = #file,
        line: UInt = #line,
        _ callback: @escaping (Value) throws -> EventLoopFuture<NewValue>
    ) -> EventLoopFuture<NewValue> {
        return self.flatMap(file: file, line: line) {
            do {
                return try callback($0)
            } catch {
                return self.eventLoop.makeFailedFuture(error)
            }
        }
    }

    func mapThrowing<NewValue>(
        file: StaticString = #file,
        line: UInt = #line,
        _ callback: @escaping (Value) throws -> NewValue
    ) -> EventLoopFuture<NewValue> {
        return self.flatMapThrowing(file: file, line: line, callback)
    }

    func flatMapIfErrorThrowing(
        file: StaticString = #file,
        line: UInt = #line,
        _ callback: @escaping (Error) throws -> EventLoopFuture<Value>
    ) -> EventLoopFuture<Value> {
        return self.flatMapError(file: file, line: line) {
            do {
                return try callback($0)
            } catch {
                return self.eventLoop.makeFailedFuture(error)
            }
        }
    }
}

public extension EventLoop {
    /// Creates and returns a new void `EventLoopFuture` that is already marked as success.
    /// Notifications will be done using this `EventLoop` as execution `NIOThread`.
    ///
    /// - parameters:
    ///     - result: the value that is used by the `EventLoopFuture`.
    /// - returns: a succeeded `EventLoopFuture`.
    func makeSucceededFuture(file: StaticString = #file, line: UInt = #line) -> EventLoopFuture<Void> {
        self.makeSucceededFuture((), file: file, line: line)
    }

    /// Creates and returns a new void `EventLoopFuture` that is already marked as success.
    /// Notifications will be done using this `EventLoop` as execution `NIOThread`.
    ///
    /// - parameters:
    ///     - result: the value that is used by the `EventLoopFuture`.
    /// - returns: a succeeded `EventLoopFuture`.
    func makeFuture(file: StaticString = #file, line: UInt = #line) -> EventLoopFuture<Void> {
        self.makeSucceededFuture(file: file, line: line)
    }
}

//MARK:- General
public extension EventLoopGroup {
    var eventLoop: EventLoop {
        self.next()
    }
}

infix operator =>
public func =><T: RawRepresentable & Equatable>(lhs: T, rhs: [T]) -> Bool {
    return rhs.contains(lhs)
}

//MARK:- Entita2FDB
public extension E2FDBEntity {
    static var format: E2.Format { .JSON }
    static var subspace: FDB.Subspace { subspaceMain }
}

public protocol Model: E2FDBEntity {
    associatedtype Storage = FDB
    associatedtype Identifier = E2.UUID
}

public protocol ModelInt: E2FDBEntity {
    associatedtype Storage = FDB
    associatedtype Identifier = Int
}

public extension Model {
    func insert(
        commit: Bool = true,
        within transaction: AnyFDBTransaction?,
        storage: Storage,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void> {
        self.insert(commit: commit, within: transaction as? AnyTransaction, storage: storage, on: eventLoop)
    }

    func save(
        by ID: Identifier? = nil,
        commit: Bool = true,
        within transaction: AnyFDBTransaction?,
        storage: Storage,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void> {
        self.save(by: ID, commit: commit, within: transaction as? AnyTransaction, storage: storage, on: eventLoop)
    }

    func delete(
        commit: Bool = true,
        within transaction: AnyFDBTransaction?,
        storage: Storage,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<Void> {
        self.delete(commit: commit, within: transaction as? AnyTransaction, storage: storage, on: eventLoop)
    }
}

public extension ModelInt {
    static func getNextID(storage: Storage, on eventLoop: EventLoop) -> EventLoopFuture<Int> {
        storage.withTransaction(on: eventLoop) { transaction in
            Self.getNextID(commit: true, within: transaction)
        }
    }

    static func getNextID(
        commit: Bool = true,
        within transaction: AnyFDBTransaction
    ) -> EventLoopFuture<Int> {
        let key = Self.subspace["idx"][Self.entityName]
        return transaction
            .atomic(.add, key: key, value: Int(1))
            .flatMap { $0.get(key: key, commit: commit) }
            .flatMapThrowing { (maybeBytes: Bytes?, _) -> Int in
                let result: Int = try maybeBytes!.cast()
                return result
            }
    }
}

//MARK- Migrations

public typealias Migrations = [() throws -> Void]

func runMigrations(_ migrations: Migrations, on fdb: FDB) {
    let logger = Logger(label: "Quorum.Migrations")
    let key = subspaceMain["migration"]
    var lastState: Int
    do {
        let lastMigration = try fdb.get(key: key)
        if lastMigration == nil {
            let initial: Int = 0
            try fdb.set(key: key, value: LGNCore.getBytes(initial))
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
            try migration()
            try fdb.set(key: key, value: LGNCore.getBytes(idx + 1))
            logger.info("Successfully applied migration #\(idx)")
        } catch {
            logger.critical("Could not run migration #\(idx): \(error)")
            exit(1)
        }
    }
}
