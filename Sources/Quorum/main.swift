import Foundation
import Generated
import LGNCore
import LGNC
import LGNP
import LGNS
import Entita
import Entita2FDB
import AsyncHTTPClient
import Lifecycle
import LifecycleNIOCompat

public typealias SQuorum = Services.Quorum
public typealias SAuthor = Services.Author
public typealias Context = LGNCore.Context

public struct Models {}
public struct Logic {}

LoggingSystem.bootstrap(LGNCore.Logger.init)
LGNCore.Logger.logLevel = .trace

Entita.KEY_DICTIONARIES_ENABLED = false

let APP_ENV = AppEnv.detect()

public enum E: Error {
    case Consul(String)
}

let config = try Config<ConfigKeys>(
    rawConfig: ProcessInfo.processInfo.environment,
    isLocal: APP_ENV == .local,
    localConfig: [
        .SALT: "da kak tak",
        .KEY: "3858f62230ac3c91",
        .REALM: "Inner-Mongolia",
        .WEBSITE_DOMAIN: "https://kirilltitov.com",
        .AUTHOR_LGNS_PORT: "1711",
        .LOG_LEVEL: "trace",
        .LGNS_PORT: "1712",
        .HTTP_PORT: "8081",
        .PRIVATE_IP: "127.0.0.1",
        .REGISTER_TO_CONSUL: "false",
        .HASHIDS_SALT: "TXRcA(q7)1fZDp5z0v{_52",
        .HASHIDS_MIN_LENGTH: "5",
    ]
)

let defaultLogger = Logger(label: "Quorum.Default")

guard let logLevel = Logger.Level(rawValue: config[.LOG_LEVEL]) else {
    defaultLogger.critical("Invalid LOG_LEVEL value: \(config[.LOG_LEVEL])")
    fatalError()
}

LGNCore.Logger.logLevel = logLevel
defaultLogger.notice("Log level set to '\(logLevel)'")

LGNCore.i18n.translator = LGNCore.i18n.FactoryTranslator(
    phrases: phrases,
    allowedLocales: [.enUS, .ruRU]
)

let SERVICE_ID = "Quorum"
let POST_KEY = "Post"
let COMMENT_KEY = "Comment"
let PORTAL_ID = config[.REALM]
let AUTHOR_PORT = Int(config[.AUTHOR_LGNS_PORT])!

public extension LGNCore.Address {
    static func node(service: String, name: String, realm: String, port: Int) -> LGNCore.Address {
        return .ip(host: "\(name).\(service)-\(realm).service.elegion", port: port)
    }
}

let COMMENT_EDITABLE_TIME_SECONDS: TimeInterval = 3600
let COMMENT_LIKEABLE_TIME_SECONDS: TimeInterval = 86400 * 365
let COMMENT_POST_COOLDOWN_SECONDS: TimeInterval = 5
let COMMENT_EDIT_COOLDOWN_SECONDS: TimeInterval = 5

let defaultUser = E2.UUID("00000000-1637-0034-1711-000000000000")!
let adminUserID = defaultUser
let empty = LGNC.Entity.Empty()

let lifecycle = ServiceLifecycle()

// this const is also used in Logic.User.usersLRU initialization
let eventLoopCount = System.coreCount.clamped(min: 4)
let eventLoopGroup: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: eventLoopCount)
lifecycle.registerShutdown(label: "eventLoopGroup", .sync(eventLoopGroup.syncShutdownGracefully))

let cryptor = try LGNP.Cryptor(key: config[.KEY])

let fdb = FDB(clusterFile: "/opt/foundationdb/fdb.cluster")
try fdb.connect()
lifecycle.registerShutdown(
    label: "FDB",
    .sync(fdb.disconnect)
)

let subspaceMain = FDB.Subspace(PORTAL_ID, SERVICE_ID)
let subspaceCounter = subspaceMain["cnt"]

let requiredBitmask: LGNP.Message.ControlBitmask = [.signatureSHA512, /*.encrypted,*/ .contentTypeMsgPack]

let client: LGNCClient
if APP_ENV == .local {
    client = LGNC.Client.Loopback(eventLoopGroup: eventLoopGroup)
    guaranteeLocalAuthorContracts()
} else {
    client = LGNC.Client.Dynamic(
        eventLoopGroup: eventLoopGroup,
        clientLGNS: LGNS.Client(
            cryptor: cryptor,
            controlBitmask: requiredBitmask,
            eventLoopGroup: eventLoopGroup
        ),
        clientHTTP: HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
    )
}

runMigrations(migrations, on: fdb)

CreateController.setup()
CommentsController.setup()
CommentsCountersController.setup()
EditController.setup()
DeleteController.setup()
UndeleteController.setup()
HideController.setup()
UnhideController.setup()
LikeController.setup()
ApproveCommentController.setup()
PendingCommentsController.setup()
PendingCommentsCountController.setup()
RejectCommentController.setup()
UpdateUserAccessLevelController.setup()
UserInfoController.setup()

let HOST = "0.0.0.0"
let LGNS_PORT = Int(config[.LGNS_PORT])!
let HTTP_PORT = Int(config[.HTTP_PORT])!

let serverHTTP = try SQuorum.getServerHTTP(
    at: .ip(host: HOST, port: HTTP_PORT),
    eventLoopGroup: eventLoopGroup
)
lifecycle.register(
    label: "HTTP Server",
    start: .eventLoopFuture(serverHTTP.bind),
    shutdown: .eventLoopFuture(serverHTTP.shutdown)
)

let serverLGNS = try SQuorum.getServerLGNS(
    at: .ip(host: HOST, port: LGNS_PORT),
    cryptor: cryptor,
    eventLoopGroup: eventLoopGroup,
    requiredBitmask: requiredBitmask
)
lifecycle.register(
    label: "LGNS Server",
    start: .eventLoopFuture(serverLGNS.bind),
    shutdown: .eventLoopFuture(serverLGNS.shutdown)
)

if config[.REGISTER_TO_CONSUL].bool == true {
    try registerToConsul()
}

lifecycle.start { maybeError in
    if let error = maybeError {
        defaultLogger.critical("Could not start Quorum: \(error)")
    } else {
        defaultLogger.info("Quorum successfully started!")
    }
}
lifecycle.wait()

defaultLogger.info("Bye")
