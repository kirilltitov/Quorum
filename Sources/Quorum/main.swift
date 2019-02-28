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
let adminUserID = defaultUser

typealias SQuorum = Services.Quorum

let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
let cryptor = try LGNP.Cryptor(salt: "da kak tak", key: "3858f62230ac3c91")

let fdb = FDB(clusterFile: "/opt/foundationdb/fdb.cluster")
try fdb.connect()

let subspaceMain = FDB.Subspace(PORTAL_ID, SERVICE_ID)

//let comm = Models.Comment(
//    ID: 1,
//    IDUser: defaultUser,
//    IDPost: 1,
//    IDReplyComment: nil,
//    body: "lul",
//    dateCreated: .distantFuture,
//    dateUpdated: .distantPast
//)
//
//print("indexIndexSubspace")
//dump(comm.indexIndexSubspace._string)
//print("")
//
//print("indexIndexSubspace UNIQUE")
//dump(comm.getIndexIndexKeyForIndex(Models.Comment.indices["ID"]!, name: "ID", value: "1")._string)
//print("")
//
//print("indexIndexSubspace NON-UNIQUE")
//dump(comm.getIndexIndexKeyForIndex(Models.Comment.indices["user"]!, name: "user", value: defaultUser)._string)
//print("")
//
//print("indexSubspace")
//dump(Models.Comment.indexSubspace._string)
//print("")
//
//print("getIndexKeyForUniqueIndex")
//dump(Models.Comment.getIndexKeyForUniqueIndex(name: "email", value: "kirill@kirilltitov.com")._string)
//print("")
//
//print("getIndexKeyForIndex")
//dump(comm.getIndexKeyForIndex(Models.Comment.indices["user"]!, name: "user", value: defaultUser)._string)
//print("")
//
//exit(0)

let requiredBitmask: LGNP.Message.ControlBitmask = [.signatureSHA1, /*.encrypted,*/ .contentTypeMsgPack]
let client = LGNS.Client(cryptor: cryptor, controlBitmask: requiredBitmask, eventLoopGroup: eventLoopGroup)

runMigrations(migrations, on: fdb)

CreateController.setup()
CommentsController.setup()
EditController.setup()
DeleteController.setup()
LikeController.setup()
ApproveCommentController.setup()
UnapprovedCommentsController.setup()
UndeleteController.setup()
RefreshUserController.setup()
RejectCommentController.setup()
CreatePostController.setup()

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

let dispatchGroup = DispatchGroup()

let host = "127.0.0.1"

DispatchQueue(label: "games.1711.server.http", qos: .userInitiated, attributes: .concurrent).async(group: dispatchGroup) {
    let address: LGNC.HTTP.Server.BindTo = .ip(host: "127.0.0.1", port: 8080)
    let promise: Promise<Void> = eventLoopGroup.eventLoop.newPromise()
    promise.futureResult.whenComplete {
        LGNCore.log("Quorum HTTP service on portal ID \(PORTAL_ID) started at \(address)")
    }
    try! SQuorum.serveHTTP(
        at: address,
        eventLoopGroup: eventLoopGroup,
        promise: promise
    )
}

DispatchQueue(label: "games.1711.server.lgns", qos: .userInitiated, attributes: .concurrent).async(group: dispatchGroup) {
    let address: LGNS.Address = .ip(host: host, port: 1711)
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

let trap: @convention(c) (Int32) -> Void = { s in
    LGNCore.log("Received signal \(s)")
    _  = try! SignalObserver.fire(signal: s).wait()
    LGNCore.log("Shutdown routines done")
}

signal(SIGINT, trap)
signal(SIGTERM, trap)

dispatchGroup.wait()

print("Bye")
