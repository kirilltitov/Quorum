import Foundation
import LGNCore
import Entita2FDB
import FDB
import NIO

//MARK:- FDB
public extension FDB.Tuple {
    public var _string: String {
        return self.tuple
            .map { String(describing: $0) }
            .joined(separator: " / ")
    }
}

public extension FDB.Subspace {
    public var _string: String {
        return (try? FDB.Tuple(from: self.prefix)._string) ?? "\(self)"
    }
}

public extension AnyFDBKey {
    public var _string: String {
        return (try? FDB.Tuple(from: self.asFDBKey())._string) ?? "\(self)"
    }
}

//MARK:- EventLoopFuture
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

//MARK:- General
public extension EventLoopGroup {
    public var eventLoop: EventLoop {
        return self.next()
    }
}

//MARK:- Entita2FDB
extension E2.ID: FDBTuplePackable where Value == UUID {
    public func pack() -> Bytes {
        return self._bytes.pack()
    }
}

public extension E2FDBEntity {
    public static var storage: FDB {
        return fdb
    }

    public static var subspace: FDB.Subspace {
        return subspaceMain
    }
}

public protocol Model: E2FDBEntity where Identifier == E2.UUID {}
public protocol ModelInt: E2FDBEntity where Identifier == Int {}

public extension ModelInt {
    public static func getNextID(on eventLoop: EventLoop) -> Future<Self.Identifier> {
        let key = subspaceMain["idx"][Self.entityName]
        return fdb
            .begin(eventLoop: eventLoop)
            .then { tr in tr.atomic(.add, key: key, value: Int(1)) }
            .then { tr in tr.get(key: key) }
            .map { (bytes, _) in bytes!.cast() }
    }
}

//MARK- Migrations

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

