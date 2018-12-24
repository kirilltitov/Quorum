import Foundation
import LGNCore
import LGNC
import LGNP
import LGNS
import Entita2FDB
import NIO

LGNP.verbose = false

public extension EventLoopGroup {
    public var eventLoop: EventLoop {
        return self.next()
    }
}

enum E: Error {
    case PostNotFound
}

// portal id 0 = dev.kirilltitov.com
// portal id 1 = kirilltitov.com

let env = Env.validateAndUnpack(
    params: [
        "PORTAL_ID",
    ],
    defaultParams: [
        "PORTAL_ID": "0",
    ]
)

let SERVICE_ID = "q"
let POST_KEY = "p"
let COMMENT_KEY = "c"
let PORTAL_ID = env["PORTAL_ID"]

typealias SQuorum = Services.Quorum

let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
let cryptor = try LGNP.Cryptor(salt: "da kak tak", key: "3858f62230ac3c91")

let fdb = FDB()
let subspaceMain = Subspace(SERVICE_ID, PORTAL_ID)

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

final public class Test: Model {
    public let ID: E2.UUID
    public let lul: String
    
    public init(ID: E2.UUID, lul: String) {
        self.ID = ID
        self.lul = lul
    }
}

final public class Post: ModelInt {
    public enum CodingKeys: String, CodingKey {
        case ID = "a"
        case isCommentable = "b"
    }

    public let ID: Int
    public var isCommentable: Bool
    
    public init(ID: Int, isCommentable: Bool) {
        self.ID = ID
        self.isCommentable = isCommentable
    }
}

public class LogicPost {
    private static let lru: CacheLRU<Int, Post> = CacheLRU(capacity: 1000)

    public static func get(by ID: Int, on eventLoop: EventLoop) -> Future<Post?> {
        if let post = self.lru.get(for: ID) {
            return eventLoop.newSucceededFuture(result: post)
        }

        return Post
            .load(by: ID, on: eventLoop)
            .map {
                if let post = $0 {
                    self.lru.set(post, for: ID)
                }
                return $0
            }
    }

    public static func isExistingAndCommentable(_ ID: Int, on eventLoop: EventLoop) -> Future<Bool> {
        return self
            .get(by: ID, on: eventLoop)
            .map { $0?.isCommentable ?? false }
    }
}

typealias CCreate = SQuorum.Contracts.Create

CCreate.Request.validateIdpost { ID, eventLoop in
    return LogicPost
        .get(by: ID, on: eventLoop)
        .map { post in
            guard let post = post else {
                return .PostNotFound
            }
            guard post.isCommentable else {
                return .PostIsReadOnly
            }
            return nil
        }
}

CCreate.guarantee { (request: CCreate.Request, info: RequestInfo) -> CCreate.Response in
    dump(request)
    return LGNC.Entity.Empty()
}

let address: LGNS.Server.Address = .port(1711)

let promise: Promise<Void> = eventLoopGroup.eventLoop.newPromise()
promise.futureResult.whenComplete {
    print("Quorum service on portal ID \(PORTAL_ID) started at \(address)")
}

try Services.Quorum.serveLGNS(
    at: address,
    cryptor: cryptor,
    eventLoopGroup: eventLoopGroup,
    requiredBitmask: [.signatureSHA256, .encrypted],
    readTimeout: .seconds(60),
    writeTimeout: .seconds(60),
    promise: promise
)

print("Bye")
