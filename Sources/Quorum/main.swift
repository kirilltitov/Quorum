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

LoggingSystem.bootstrap(LGNCore.Logger.init)
LGNCore.Logger.logLevel = .trace

LGNP.verbose = false
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
}

let config = try LGNCore.Config<ConfigKeys>(
    env: APP_ENV,
    rawConfig: ProcessInfo.processInfo.environment,
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
    ]
)

let defaultLogger = Logger(label: "Quorum.Default")

guard let logLevel = Logger.Level(string: config[.LOG_LEVEL]) else {
    defaultLogger.critical("Invalid LOG_LEVEL value: \(config[.LOG_LEVEL])")
    fatalError()
}

LGNCore.Logger.logLevel = logLevel
defaultLogger.notice("Log level set to '\(logLevel)'")

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

let COMMENT_EDITABLE_TIME: TimeInterval = 3600
let COMMENT_LIKEABLE_TIME: TimeInterval = 86400 * 365
let COMMENT_EDIT_COOLDOWN: TimeInterval = 10

let defaultUser = E2.UUID("00000000-1637-0034-1711-000000000000")!
let adminUserID = defaultUser

typealias SQuorum = Services.Quorum

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

func mark(_ name: String, file: String = #file, line: UInt = #line) {
    defaultLogger.info("[Mark] \(name): \(Date().timeIntervalSince1970)", file: file, line: line)
}

let eventLoopCount = System.coreCount.clamped(min: 4)
let eventLoopGroup: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: eventLoopCount)

let cryptor = try LGNP.Cryptor(salt: config[.SALT], key: config[.KEY])

let fdb = FDB(clusterFile: "/opt/foundationdb/fdb.cluster")
try fdb.connect()

let subspaceMain = FDB.Subspace(PORTAL_ID, SERVICE_ID)

let requiredBitmask: LGNP.Message.ControlBitmask = [.signatureSHA1, /*.encrypted,*/ .contentTypeMsgPack]

let client: LGNCClient
if APP_ENV == .local {
    client = LGNC.Client.Loopback(eventLoopGroup: eventLoopGroup)

    Services.Author.Contracts.UserInfoInternal.guarantee { (request, requestInfo) throws -> Services.Shared.User in
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
} else {
    client = LGNC.Client.Dynamic(
        eventLoopGroup: eventLoopGroup,
        clientLGNS: LGNS.Client(
            cryptor: cryptor,
            controlBitmask: requiredBitmask,
            eventLoopGroup: eventLoopGroup
        )
    )
}

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
PendingCommentsController.setup()
PendingCommentsCountController.setup()
RejectCommentController.setup()

let dispatchGroup = DispatchGroup()

let HOST = "0.0.0.0"
let LGNS_PORT = Int(config[.LGNS_PORT])!
let HTTP_PORT = Int(config[.HTTP_PORT])!

DispatchQueue(label: "games.1711.server.http", qos: .userInteractive, attributes: .concurrent).async(group: dispatchGroup) {
    let address: LGNCore.Address = .ip(host: HOST, port: HTTP_PORT)
    let promise: Promise<Void> = eventLoopGroup.eventLoop.makePromise()
    promise.futureResult.whenComplete { _ in
        defaultLogger.info("Quorum HTTP service on portal ID \(PORTAL_ID) started at \(address)")
    }
    try! SQuorum.serveHTTP(
        at: address,
        eventLoopGroup: eventLoopGroup,
        promise: promise
    )
}

DispatchQueue(label: "games.1711.server.lgns", qos: .userInteractive, attributes: .concurrent).async(group: dispatchGroup) {
    let address: LGNCore.Address = .ip(host: HOST, port: LGNS_PORT)
    let promise: Promise<Void> = eventLoopGroup.eventLoop.makePromise()
    promise.futureResult.whenComplete { _ in
        defaultLogger.info("Quorum LGNS service on portal ID \(PORTAL_ID) started at \(address)")
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
