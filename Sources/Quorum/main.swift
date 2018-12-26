import Foundation
import LGNCore
import LGNC
import LGNP
import LGNS
import Entita2FDB
import NIO
import MessagePack

let packed = try! MessagePackEncoder().encode(Date.distantPast)
print(packed)
let unpacked = try! MessagePackDecoder().decode(Date.self, from: packed)
print(unpacked)

exit(0)

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

let defaultUser = E2.UUID("35F1ABE0-C965-4309-98DC-6DEE4B40DEF8")!

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

final public class Post: ModelInt {
    public enum CodingKeys: String, CodingKey {
        case ID = "a"
        case IDUser = "b"
        case isCommentable = "c"
    }

    public let ID: Int
    public let IDUser: E2.UUID
    public var isCommentable: Bool
    
    public init(ID: Int, IDUser: E2.UUID, isCommentable: Bool) {
        self.ID = ID
        self.IDUser = IDUser
        self.isCommentable = isCommentable
    }
}

final public class Comment: Model {
//    public enum CodingKeys: String, CodingKey {
//        case ID = "a"
//        case IDUser = "b"
//        case IDPost = "c"
//        case IDReplyComment = "d"
//        case isDeleted = "e"
//        case body = "f"
//        case dateCreated = "g"
//        case dateUpdated = "h"
//    }

    public let ID: E2.UUID
    public let IDUser: E2.UUID
    public let IDPost: Post.Identifier
    public let IDReplyComment: E2.UUID?
    public let isDeleted: Bool
    public let body: String
    public let dateCreated: Date
    public let dateUpdated: Date
    
    public init(
        ID: E2.UUID = E2.UUID(),
        IDUser: E2.UUID,
        IDPost: Post.Identifier,
        IDReplyComment: E2.UUID?,
        isDeleted: Bool,
        body: String,
        dateCreated: Date,
        dateUpdated: Date
    ) {
        self.ID = ID
        self.IDUser = IDUser
        self.IDPost = IDPost
        self.IDReplyComment = IDReplyComment
        self.isDeleted = isDeleted
        self.body = body
        self.dateCreated = dateCreated
        self.dateUpdated = dateUpdated
    }
}

public class LogicUser {
    public static func authorize(token: String, on eventLoop: EventLoop) -> Future<Bool> {
        print("authorizing token: \(token)")
        return eventLoop.newSucceededFuture(result: true)
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
    
    public static func doCommentExist(ID: String, on eventLoop: EventLoop) -> Future<Bool> {
        guard let uuid = E2.UUID(ID) else {
            return eventLoop.newSucceededFuture(result: false)
        }
        return Comment
            .load(by: uuid, on: eventLoop)
            .map { $0 == nil }
    }
    
    public static func getProcessedBody(from string: String) -> String {
        return string
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

CCreate.Request.validateToken { token, eventLoop in
    return LogicUser
        .authorize(token: token, on: eventLoop)
        .map { _ in nil }
}

CCreate.Request.validateIdreplycomment { ID, eventLoop in
    return LogicPost
        .doCommentExist(ID: ID, on: eventLoop)
        .map {
            guard $0 == true else {
                return .ReplyingCommentNotFound
            }
            return nil
        }
}

CCreate.guarantee { (request: CCreate.Request, info: RequestInfo) -> Future<CCreate.Response> in
    let comment = Comment(
        IDUser: defaultUser,
        IDPost: request.IDPost,
        IDReplyComment: request.IDReplyComment == nil ? nil : E2.UUID(request.IDReplyComment!),
        isDeleted: false,
        body: LogicPost.getProcessedBody(from: request.body),
        dateCreated: Date(),
        dateUpdated: Date.distantPast
    )
    return comment
        .save(on: info.eventLoop)
        .map {
            CCreate.Response(
                ID: comment.ID.string,
                IDUser: defaultUser.string,
                IDPost: comment.IDPost,
                IDReplyComment: comment.IDReplyComment?.string,
                isDeleted: comment.isDeleted,
                body: comment.body,
                dateCreated: comment.dateCreated.formatted,
                dateUpdated: comment.dateUpdated.formatted
            )
        }
}

let address: LGNS.Address = .port(1711)
let requiredBitmask: LGNP.Message.ControlBitmask = [.signatureSHA256, .encrypted, .contentTypeJSON]

let promise: Promise<Void> = eventLoopGroup.eventLoop.newPromise()
promise.futureResult.whenComplete {
    print("Quorum service on portal ID \(PORTAL_ID) started at \(address)")
}

let key = subspaceMain["mycounter"]

public typealias Migrations = [() throws -> Void]

let migrations: Migrations = [
    {
        LGNCore.log("Migration: Creating initial records")
        let IDUser = defaultUser
        for
            item
        in
            [
                1: true,
                2: true,
                3: true,
                4: true,
                5: true,
                6: true,
                7: true,
                8: true,
                15: true,
                16: true,
                17: true,
                18: true,
                19: true,
                23: true,
                24: true,
                25: true,
                26: true,
                27: true,
                28: true,
                29: true,
                30: true,
                31: true,
                32: true,
                33: true,
                34: true,
                35: false,
            ]
        {
            try Post(ID: item.key, IDUser: IDUser, isCommentable: item.value)
                .save(on: eventLoopGroup.eventLoop)
                .wait()
        }
    },
    {
        LGNCore.log("Migration: Running second dummy migration...")
    },
    {
        LGNCore.log("Migration: Running third dummy migration...")
    }
]


func runMigrations(_ migrations: Migrations) {
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

runMigrations(migrations)

//let profiler = LGNCore.Profiler.begin()
//for _ in 0..<1000 {
//    let eventLoop = eventLoopGroup.eventLoop
//    let _: UInt64 = try fdb.begin(
//        eventLoop: eventLoop
//    ).then { tr in
//        tr.atomic(.Add, key: key, value: Int(1))
//    }.then { tr in
//        tr.commit()
//    }.then {
//        fdb.begin(eventLoop: eventLoop)
//    }.then { tr in
//        tr.get(key: key)
//    }.map { (bytes, _) in
//        bytes!.cast()
//    }.wait()
//}
//
////dump(result)
//dump(profiler.end())
//
//let comment = Comment(
//    ID: E2.UUID(),
//    IDUser: defaultUser,
//    IDPost: 123,
//    IDReplyComment: E2.UUID(),
//    isDeleted: false,
//    body: "lul kek cheburek",
//    dateCreated: Date(),
//    dateUpdated: Date.distantPast
//)
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

dump(try Comment.load(by: E2.UUID("94B541C4-BB7D-4881-AECE-C9463171EDEC")!, on: eventLoopGroup.eventLoop).wait())

//try Post(ID: 1, isCommentable: true).save(on: eventLoopGroup.eventLoop).wait()
//try Post(ID: 2, isCommentable: false).save(on: eventLoopGroup.eventLoop).wait()

//try Services.Quorum.serveLGNS(
//    at: address,
//    cryptor: cryptor,
//    eventLoopGroup: eventLoopGroup,
//    requiredBitmask: [.signatureSHA256, .encrypted],
//    readTimeout: .seconds(60),
//    writeTimeout: .seconds(60),
//    promise: promise
//)

print("Bye")
