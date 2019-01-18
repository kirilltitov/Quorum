import Foundation
import Generated
import LGNCore
import LGNC
import LGNP
import LGNS
import Entita
import Entita2FDB
import NIO
import MessagePack
import Signals

public protocol SyncStorage {
    associatedtype Key: Hashable
    associatedtype Value

    var queue: DispatchQueue { get }

    func getOrSet(
        by key: Key,
        on eventLoop: EventLoop,
        _ getter: @escaping () -> Future<Value?>
    ) -> Future<Value?>

    func has(key: Key, on eventLoop: EventLoop) -> Future<Bool>
    func get(by key: Key, on eventLoop: EventLoop) -> Future<Value?>
    func set(by key: Key, value: Value, on eventLoop: EventLoop) -> Future<Void>
    @discardableResult func remove(by key: Key, on eventLoop: EventLoop) -> Future<Value?>

    func has0(key: Key) -> Bool
    func get0(by key: Key) -> Value?
    func set0(by key: Key, value: Value)
    func remove0(by key: Key) -> Value?
}

extension SyncStorage {
    public static func getQueue() -> DispatchQueue {
        return DispatchQueue(
            label: "games.1711.SyncStorage.\(Self.self)",
            qos: .userInitiated,
            attributes: .concurrent
        )
    }

    public func has0(key: Key) -> Bool {
        return self.get0(by: key) != nil
    }

    public func has(key: Key, on eventLoop: EventLoop) -> Future<Bool> {
        let promise: Promise<Bool> = eventLoop.newPromise()

        self.queue.async {
            promise.succeed(result: self.has0(key: key))
        }

        return promise.futureResult
    }
    
    public func get(by key: Key, on eventLoop: EventLoop) -> Future<Value?> {
        let promise: Promise<Value?> = eventLoop.newPromise()

        self.queue.async {
            promise.succeed(result: self.get0(by: key))
        }

        return promise.futureResult
    }
    
    public func set(by key: Key, value: Value, on eventLoop: EventLoop) -> Future<Void> {
        let promise: Promise<Void> = eventLoop.newPromise()

        self.queue.async {
            self.set0(by: key, value: value)
            promise.succeed(result: ())
        }

        return promise.futureResult
    }
    
    public func getOrSet(
        by key: Key,
        on eventLoop: EventLoop,
        _ getter: @escaping () -> EventLoopFuture<Value?>
    ) -> EventLoopFuture<Value?> {
        let promise: Promise<Value?> = eventLoop.newPromise()

        self.queue.async(flags: .barrier) {
            if let value = self.get0(by: key) {
                promise.succeed(result: value)
                return
            }

            do {
                let result = try getter().wait()
                if let result = result {
                    self.set0(by: key, value: result)
                }
                promise.succeed(result: result)
            } catch {
                promise.fail(error: error)
            }
        }

        return promise.futureResult
    }
    
    @discardableResult public func remove(by key: Key, on eventLoop: EventLoop) -> Future<Value?> {
        let promise: Promise<Value?> = eventLoop.newPromise()

        self.queue.async(flags: .barrier) {
            promise.succeed(result: self.remove0(by: key))
        }

        return promise.futureResult
    }
}

public final class SyncDict<Key: Hashable, Value>: SyncStorage {
    public let queue: DispatchQueue
    private var storage: [Key: Value] = [:]

    public init(queue: DispatchQueue = SyncDict.getQueue()) {
        self.queue = queue
    }

    public func get0(by key: Key) -> Value? {
        return self.storage[key]
    }

    public func set0(by key: Key, value: Value) {
        self.storage[key] = value
    }

    public func remove0(by key: Key) -> Value? {
        return self.storage.removeValue(forKey: key)
    }
}

public struct Models {}
public struct Logic {}

LGNP.verbose = false
Entita.KEY_DICTIONARIES_ENABLED = false
LGNC.ALLOW_ALL_TRANSPORTS = true

// portal id 0 = dev.kirilltitov.com
// portal id 1 = kirilltitov.com

let env = LGNCore.Env.validateAndUnpack(
    params: [
        "PORTAL_ID",
    ],
    defaultParams: [
        "PORTAL_ID": "Inner-Mongolia",
    ]
)

let SERVICE_ID = "Quorum"
let POST_KEY = "Post"
let COMMENT_KEY = "Comment"
let PORTAL_ID = env["PORTAL_ID"]

public extension LGNS.Address {
    public static func node(service: String, name: String, realm: String, port: Int) -> LGNS.Address {
        return .ip(host: "\(name).\(service).\(realm).playelegion.com", port: port)
    }
}

let COMMENT_EDITABLE_TIME: TimeInterval = 3600
let COMMENT_LIKEABLE_TIME: TimeInterval = 86400 * 365
let COMMENT_EDIT_COOLDOWN: TimeInterval = 10

let defaultUser = E2.UUID("00000000-1637-0034-1711-000000000000")!

typealias SQuorum = Services.Quorum

let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
let cryptor = try LGNP.Cryptor(salt: "da kak tak", key: "3858f62230ac3c91")

let fdb = FDB()
try fdb.connect()

let subspaceMain = Subspace(SERVICE_ID, PORTAL_ID)

let requiredBitmask: LGNP.Message.ControlBitmask = [.signatureSHA1, .encrypted, .contentTypeMsgPack]
let client = LGNS.Client(cryptor: cryptor, controlBitmask: requiredBitmask, eventLoopGroup: eventLoopGroup)

//let comments = try Logic.Post.getCommentsFor(ID: 1, on: eventLoopGroup.eventLoop).wait()
//try comments.forEach {
//    dump($0)
//    dump(try $0.getUser(on: eventLoopGroup.eventLoop).wait())
//}
//try comments.forEach { comment in
//    comment.IDUser = defaultUser
//    try comment.save(on: eventLoopGroup.eventLoop).wait()
//}

//exit(0)

runMigrations(migrations, on: fdb)

CreateController.setup()
CommentsController.setup()
EditController.setup()
DeleteController.setup()

let testPostID: Int = 1

let comment1 = Models.Comment(
    ID: 1,
    IDUser: defaultUser,
    IDPost: 1,
    IDReplyComment: nil,
    isDeleted: false,
    body: "Так!",
    dateCreated: Date(),
    dateUpdated: Date.distantPast
)

//dump(try comment1.getUser(on: eventLoopGroup.eventLoop).wait())

//
//let comment2 = Models.Comment(
//    ID: nextID(),
//    IDUser: defaultUser,
//    IDPost: testPostID,
//    IDReplyComment: comment1.ID,
//    isDeleted: false,
//    body: "Первый",
//    dateCreated: Date(),
//    dateUpdated: Date.distantPast
//)
//
//let comment3 = Models.Comment(
//    ID: nextID(),
//    IDUser: defaultUser,
//    IDPost: testPostID,
//    IDReplyComment: nil,
//    isDeleted: false,
//    body: "Second",
//    dateCreated: Date(),
//    dateUpdated: Date.distantPast
//)

//try [comment1, comment2, comment3].forEach { comment in
//    try comment.save(on: eventLoopGroup.eventLoop).wait()
//}

//let post = Models.Post(ID: 1, IDUser: defaultUser, isCommentable: true)
//dump(Models.Comment._getPostPrefix(post.ID).asFDBKey()._string)
//dump(post.getIDAsKey()._string)

//// concrete post
//assert(Models.Post.IDAsKey(ID: 1) == [2, 113, 0, 2, 48, 0, 2, 80, 111, 115, 116, 0, 21, 1])
//// comments base
//assert(Models.Comment._getPostPrefix(1).asFDBKey() == [2, 113, 0, 2, 48, 0, 2, 80, 111, 115, 116, 0, 21, 1, 2, 67, 111, 109, 109, 101, 110, 116, 0])
//// concrete comment
//assert(
//    Models.Comment(
//        ID: 49, IDUser: defaultUser, IDPost: 1, IDReplyComment: nil,
//        isDeleted: false, body: "", dateCreated: Date(), dateUpdated: Date()
//    ).getIDAsKey() == [2, 113, 0, 2, 48, 0, 2, 80, 111, 115, 116, 0, 21, 1, 2, 67, 111, 109, 109, 101, 110, 116, 0, 21, 49]
//)

//dump(try LogicPost.getCommentsFor(ID: testPostID, on: eventLoopGroup.eventLoop).wait())

//
//let packed = try comment.pack()
//dump(packed._string)
//dump(comment)
//do {
//    let unpacked = try Comment(from: packed)
//    dump(unpacked)
//} catch {
//    print("ERROR")
//    dump(error)
//}

//dump(try Comment.load(by: E2.UUID("94B541C4-BB7D-4881-AECE-C9463171EDEC")!, on: eventLoopGroup.eventLoop).wait())

//try Post(ID: 1, isCommentable: true).save(on: eventLoopGroup.eventLoop).wait()
//try Post(ID: 2, isCommentable: false).save(on: eventLoopGroup.eventLoop).wait()

let dispatchGroup = DispatchGroup()

DispatchQueue(label: "games.1711.server.http", qos: .userInitiated, attributes: .concurrent).async(group: dispatchGroup) {
    let address: LGNC.HTTP.Server.BindTo = .port(8080)
    let promise: Promise<Void> = eventLoopGroup.eventLoop.newPromise()
    promise.futureResult.whenComplete {
        LGNCore.log("Quorum HTTP service on portal ID \(PORTAL_ID) started at \(address)")
    }
    try! SQuorum.serveHTTP(
        at: .port(8080),
        eventLoopGroup: eventLoopGroup,
        promise: promise
    )
}

DispatchQueue(label: "games.1711.server.lgns", qos: .userInitiated, attributes: .concurrent).async(group: dispatchGroup) {
    let address: LGNS.Address = .port(1711)
    let promise: Promise<Void> = eventLoopGroup.eventLoop.newPromise()
    promise.futureResult.whenComplete {
        LGNCore.log("Quorum LGNS service on portal ID \(PORTAL_ID) started at \(address)")
    }

    try! Services.Quorum.serveLGNS(
        at: address,
        cryptor: cryptor,
        eventLoopGroup: eventLoopGroup,
        requiredBitmask: requiredBitmask,
        readTimeout: .seconds(60),
        writeTimeout: .seconds(60),
        promise: promise
    )
}

Signals.trap(signals: [.term, .int]) { signal in
    LGNCore.log("Received signal \(signal), shutting down")
    let future = SignalObserver.fire(signal: signal)
    future.whenSuccess {
        LGNCore.log("All servers are down")
    }
    future.whenFailure { error in
        LGNCore.log("Error occured while trying to shutdown servers: \(error)")
    }
}

dispatchGroup.wait()

print("Bye")
