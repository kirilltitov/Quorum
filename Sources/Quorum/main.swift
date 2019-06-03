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

public extension LGNS.Address {
    static func node(service: String, name: String, realm: String, port: Int) -> LGNS.Address {
        return .ip(host: "\(name).\(service).\(realm).i.playelegion.com", port: port)
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

let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount.clamped(min: 4))
let cryptor = try LGNP.Cryptor(salt: config[.SALT], key: config[.KEY])

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
RejectCommentController.setup()

let dispatchGroup = DispatchGroup()

let host = "0.0.0.0"

DispatchQueue(label: "games.1711.server.http", qos: .userInitiated, attributes: .concurrent).async(group: dispatchGroup) {
    let address: LGNC.HTTP.Server.BindTo = .ip(host: host, port: 8081)
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

DispatchQueue(label: "games.1711.server.lgns", qos: .userInitiated, attributes: .concurrent).async(group: dispatchGroup) {
    let address: LGNS.Address = .ip(host: host, port: 1712)
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

let trap: @convention(c) (Int32) -> Void = { s in
    print("Received signal \(s)")
    _  = try! SignalObserver.fire(signal: s).wait()
    print("Shutdown routines done")
}

signal(SIGINT, trap)
signal(SIGTERM, trap)

dispatchGroup.wait()

defaultLogger.info("Bye")
