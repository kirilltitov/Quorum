import Foundation
import Generated
import LGNCore
import LGNC
import LGNP
import LGNS
import Entita
import Entita2FDB
import AsyncHTTPClient
import Backtrace

Backtrace.install()

public typealias SQuorum = Services.Quorum
public typealias SAuthor = Services.Author
public typealias context = LGNCore.Context

public struct Models {}
public struct Logic {}

LoggingSystem.bootstrap(LGNCore.Logger.init)
LGNCore.Logger.logLevel = .trace

Entita.KEY_DICTIONARIES_ENABLED = false

let APP_ENV = AppEnv.detect()

public enum E: Error {
    case Consul(String)
}

public enum ConfigKeys: String, AnyConfigKey {
    /// Salt used for all encryptions
    case SALT

    /// AES encryption key
    case KEY

    /// Portal ID (used for separation FDB paths within one cluster)
    case REALM

    /// Website address (it's pretty much always https://kirilltitov.com)
    case WEBSITE_DOMAIN

    case AUTHOR_LGNS_PORT
    case LOG_LEVEL
    case LGNS_PORT
    case HTTP_PORT
    case PRIVATE_IP
    case REGISTER_TO_CONSUL
    case HASHIDS_SALT
    case HASHIDS_MIN_LENGTH
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

let eventLoopCount = System.coreCount.clamped(min: 4)
let eventLoopGroup: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: eventLoopCount)

let cryptor = try LGNP.Cryptor(key: config[.KEY])

let fdb = FDB(clusterFile: "/opt/foundationdb/fdb.cluster")
try fdb.connect()

let subspaceMain = FDB.Subspace(PORTAL_ID, SERVICE_ID)
let subspaceCounter = subspaceMain["cnt"]

let requiredBitmask: LGNP.Message.ControlBitmask = [.signatureSHA512, /*.encrypted,*/ .contentTypeMsgPack]

let client: LGNCClient
if APP_ENV == .local {
    client = LGNC.Client.Loopback(eventLoopGroup: eventLoopGroup)

    SAuthor.Contracts.UserInfoInternal.guarantee { (request, context) throws -> Services.Shared.User in
        Services.Shared.User(
            ID: defaultUser.string,
            username: "teonoman",
            email: "teo.noman@gmail.com",
            password: "sdfdfg",
            sex: "Male",
            isBanned: false,
            ip: "195.248.161.225",
            country: "RU",
            dateUnsuccessfulLogin: Date.distantPast.formatted,
            dateSignup: Date().formatted,
            dateLogin: Date().formatted,
            authorName: "viktor",
            accessLevel: "Admin"
        )
    }

    SAuthor.Contracts.Authenticate.guarantee { (request, info) -> SAuthor.Contracts.Authenticate.Response in
        .init(IDUser: defaultUser.string)
    }
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

let dispatchGroup = DispatchGroup()

let HOST = "0.0.0.0"
let LGNS_PORT = Int(config[.LGNS_PORT])!
let HTTP_PORT = Int(config[.HTTP_PORT])!

DispatchQueue(label: "games.1711.server.http", qos: .userInteractive, attributes: .concurrent).async(group: dispatchGroup) {
    let address: LGNCore.Address = .ip(host: HOST, port: HTTP_PORT)
    let server: AnyServer = try! SQuorum.startServerHTTP(at: address, eventLoopGroup: eventLoopGroup).wait()
    defaultLogger.info("Quorum HTTP service on portal ID \(PORTAL_ID) started at \(address)")
    try! server.waitForStop()
}

DispatchQueue(label: "games.1711.server.lgns", qos: .userInteractive, attributes: .concurrent).async(group: dispatchGroup) {
    let address: LGNCore.Address = .ip(host: HOST, port: LGNS_PORT)
    let server: AnyServer = try! SQuorum.startServerLGNS(
        at: address,
        cryptor: cryptor,
        eventLoopGroup: eventLoopGroup,
        requiredBitmask: requiredBitmask
    ).wait()
    defaultLogger.info("Quorum LGNS service on portal ID \(PORTAL_ID) started at \(address)")
    try! server.waitForStop()
}

if config[.REGISTER_TO_CONSUL].bool == true {
    try registerToConsul()
}

let trap: @convention(c) (Int32) -> Void = { s in
    print("Received signal \(s)")
    _  = try! SignalObserver.fire(signal: s).wait()
    print("Shutdown routines done")
}

signal(SIGINT, trap)
signal(SIGTERM, trap)

dispatchGroup.wait()

defaultLogger.info("Bye")
