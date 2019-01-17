import Foundation
import LGNCore
import Entita2FDB
import FDB
import NIO

//MARK EventLoopFuture
public extension Future {
    public func flatMapThrowing<U>(
        file: StaticString = #file,
        line: UInt = #line,
        _ callback: @escaping (T) throws -> Future<U>
    ) -> Future<U> {
        return self.then(file: file, line: line) {
            do {
                return try callback($0)
            } catch {
                return self.eventLoop.newFailedFuture(error: error)
            }
        }
    }
    
    public func mapThrowing<U>(
        file: StaticString = #file,
        line: UInt = #line,
        _ callback: @escaping (T) throws -> U
    ) -> Future<U> {
        return self.thenThrowing(file: file, line: line, callback)
    }

    public func flatMap<U>(
        file: StaticString = #file,
        line: UInt = #line,
        _ callback: @escaping (T) -> Future<U>
    ) -> Future<U> {
        return self.then(file: file, line: line, callback)
    }

    public func flatMapIfErrorThrowing(
        file: StaticString = #file,
        line: UInt = #line,
        _ callback: @escaping (Error) throws -> Future<T>
    ) -> Future<T> {
        return self.thenIfError(file: file, line: line) {
            do {
                return try callback($0)
            } catch {
                return self.eventLoop.newFailedFuture(error: error)
            }
        }
    }
}

//MARK General
public extension EventLoopGroup {
    public var eventLoop: EventLoop {
        return self.next()
    }
}

//MARK Entita2FDB
extension E2.ID: TuplePackable where Value == UUID {
    public func pack() -> Bytes {
        return self._bytes.pack()
    }
}

public final class Reference<Target: E2Entity, Key: TuplePackable> where Target.Identifier: TuplePackable {
    public static var subspace: Subspace {
        return subspaceMain
    }

    private let indexName: String

    public init(_ indexName: String) {
        self.indexName = indexName
    }

    public func getIndexKey(from key: Key) -> Subspace {
        return Reference.subspace["ref"][Target.entityName][self.indexName][key]
    }
    
    public func loadTarget(
        by value: Key,
        on eventLoop: EventLoop
    ) -> Future<Target?> {
        return fdb
            .begin(eventLoop: eventLoop)
            .then { self.loadTarget(by: value, with: $0, on: eventLoop) }
    }

    public func loadTarget(
        by value: Key,
        with transaction: Transaction,
        on eventLoop: EventLoop
    ) -> Future<Target?> {
        return self
            .load(by: value, with: transaction)
            .then { (bytes: Bytes?) -> Future<Bytes?> in
                guard let bytes = bytes else {
                    return eventLoop.newSucceededFuture(result: nil)
                }
                return fdb.load(by: bytes, on: eventLoop)
            }
            .thenThrowing {
                guard let bytes = $0 else {
                    return nil
                }
                return try Target(from: bytes)
        }
    }

    public func doExists(by value: Key, on eventLoop: EventLoop) -> Future<Bool> {
        return self
            .load(by: value, on: eventLoop)
            .map { $0 != nil }
    }
    
    public func load(
        by value: Key,
        on eventLoop: EventLoop
    ) -> Future<Bytes?> {
        return fdb
            .begin(eventLoop: eventLoop)
            .then { self.load(by: value, with: $0) }
    }

    public func load(
        by value: Key,
        with transaction: Transaction
    ) -> Future<Bytes?> {
        return transaction
            .get(key: self.getIndexKey(from: value))
            .map { $0.0 }
    }

    public func save(
        by value: Key,
        targetKey: Bytes,
        on eventLoop: EventLoop
    ) -> Future<Void> {
        return fdb
            .begin(eventLoop: eventLoop)
            .then { $0.set(key: self.getIndexKey(from: value), value: targetKey) }
            .then { $0.commit() }
    }
}

public extension E2FDBModel {
    public static var storage: FDB {
        return fdb
    }

    public static var subspace: Subspace {
        return subspaceMain
    }
}

public protocol Model: E2FDBModel where Identifier == E2.UUID {}
public protocol ModelInt: E2FDBModel where Identifier == Int {}

public extension ModelInt {
    public static func getNextID(on eventLoop: EventLoop) -> Future<Self.Identifier> {
        let key = subspaceMain["idx"][Self.entityName]
        return fdb
            .begin(eventLoop: eventLoop)
            .then { tr in tr.atomic(.Add, key: key, value: Int(1)) }
            .then { tr in tr.commit() }
            .then { fdb.begin(eventLoop: eventLoop) }
            .then { tr in tr.get(key: key) }
            .map { (bytes, _) in bytes!.cast() }
    }
}

//MARK Migrations

public typealias Migrations = [() throws -> Void]

func runMigrations(_ migrations: Migrations, on fdb: FDB) {
    let key = subspaceMain["migration"]
    var lastState: Int
    do {
        let lastMigration = try fdb.get(key: key)
        if lastMigration == nil {
            let initial: Int = 0
            try fdb.set(key: key, value: LGNCore.getBytes(initial))
            lastState = initial
        } else {
            lastState = lastMigration!.cast()
        }
    } catch {
        fatalError("Could not read migration state from fdb: \(error)")
    }
    guard migrations.count > lastState else {
        LGNCore.log("DB state is up to date, no need to perform migrations")
        return
    }
    LGNCore.log("Performing migrations")
    for idx in lastState..<migrations.count {
        let migration = migrations[idx]
        do {
            LGNCore.log("Trying to apply migration #\(idx)")
            try migration()
            try fdb.set(key: key, value: LGNCore.getBytes(idx + 1))
            LGNCore.log("Successfully applied migration #\(idx)")
        } catch {
            fatalError("Could not run migration #\(idx): \(error)")
        }
    }
}

