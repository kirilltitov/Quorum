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

@available(*, deprecated, renamed: "FDB.Transaction")
public typealias Transaction = FDB.Transaction
@available(*, deprecated, renamed: "FDB.Tuple")
public typealias Tuple = FDB.Tuple
@available(*, deprecated, renamed: "FDB.Subspace")
public typealias Subspace = FDB.Subspace
@available(*, deprecated, renamed: "FDBTuplePackable")
public typealias TuplePackable = FDBTuplePackable
@available(*, deprecated, renamed: "AnyFDBKey")
public typealias FDBKey = AnyFDBKey
public extension FDB {
    @available(*, deprecated, renamed: "begin(on:)")
    public func begin(eventLoop: EventLoop) -> EventLoopFuture<FDB.Transaction> {
        return self.begin(on: eventLoop)
    }
}

public struct Models {}
public struct Logic {}

LGNP.verbose = false
Entita.KEY_DICTIONARIES_ENABLED = false
LGNC.ALLOW_ALL_TRANSPORTS = true

let APP_ENV = AppEnv.detect()

public enum ConfigKeys: String, AnyConfigKey {
    case salt
    case aes_key
    case portal_id
}

let config = try LGNCore.Config<ConfigKeys>(
    env: APP_ENV,
    rawConfig: ProcessInfo.processInfo.environment,
    defaultConfig: [
        .salt: "da kak tak",
        .aes_key: "3858f62230ac3c91",
        .portal_id: "Inner-Mongolia",
    ]
)

let SERVICE_ID = "Quorum"
let POST_KEY = "Post"
let COMMENT_KEY = "Comment"
let PORTAL_ID = config[.portal_id]

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
let cryptor = try LGNP.Cryptor(salt: config[.salt], key: config[.aes_key])

let fdb = FDB(clusterFile: "/opt/foundationdb/fdb.cluster")
try fdb.connect()

let subspaceMain = FDB.Subspace(PORTAL_ID, SERVICE_ID)

let requiredBitmask: LGNP.Message.ControlBitmask = [.signatureSHA1, /*.encrypted,*/ .contentTypeMsgPack]
let client = LGNS.Client(cryptor: cryptor, controlBitmask: requiredBitmask, eventLoopGroup: eventLoopGroup)

runMigrations(migrations, on: fdb)

CreateController.setup()
CommentsController.setup()
EditController.setup()
DeleteController.setup()
UndeleteController.setup()
HideController.setup()
UnhideController.setup()
LikeController.setup()
ApproveCommentController.setup()
UnapprovedCommentsController.setup()
RefreshUserController.setup()
RejectCommentController.setup()
CreatePostController.setup()

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
