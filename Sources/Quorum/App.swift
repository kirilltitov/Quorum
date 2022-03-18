import Foundation
import Generated
import LGNCore
import LGNLog
import LGNConfig
import LGNC
import LGNP
import LGNS
import Entita
import Entita2FDB
import AsyncHTTPClient
import Lifecycle

public typealias SQuorum = Services.Quorum
public typealias SAuthor = Services.Author
public typealias Context = LGNCore.Context

public enum E: Error {
    case Consul(String)
}

public struct Models {}
public struct Logic {}

public struct App {
    public static var current: Self!

    public static let SERVICE_ID = "Quorum"
    public static let POST_KEY = "Post"
    public static let COMMENT_KEY = "Comment"

    public static let COMMENT_EDITABLE_TIME_SECONDS: TimeInterval = 3600
    public static let COMMENT_LIKEABLE_TIME_SECONDS: TimeInterval = 86400 * 365
    public static let COMMENT_POST_COOLDOWN_SECONDS: TimeInterval = 5
    public static let COMMENT_EDIT_COOLDOWN_SECONDS: TimeInterval = 5

    public static let defaultUser = E2.UUID("00000000-1637-0034-1711-000000000000")!
    public static var adminUserID: E2.UUID { self.defaultUser }
    public static let empty = LGNC.Entity.Empty()

    public let env: AppEnv
    public let eventLoop: EventLoopGroup
    public let client: LGNCClient
    public let config: Config<ConfigKeys>

    public let fdb: FDB
    public let subspaceMain: FDB.Subspace
    public let subspaceCounter: FDB.Subspace

    public let PORTAL_ID: String
    public let AUTHOR_PORT: Int

    public let HOST = "0.0.0.0"
    public let LGNS_PORT: Int
    public let HTTP_PORT: Int

    public init(
        env: AppEnv,
        eventLoop: EventLoopGroup,
        client: LGNCClient,
        config: Config<ConfigKeys>,
        fdb: FDB
    ) {
        self.env = env
        self.eventLoop = eventLoop
        self.client = client
        self.config = config
        self.fdb = fdb

        self.PORTAL_ID = config[.REALM]
        self.AUTHOR_PORT = Int(config[.AUTHOR_LGNS_PORT])!
        self.LGNS_PORT = Int(config[.LGNS_PORT])!
        self.HTTP_PORT = Int(config[.HTTP_PORT])!

        self.subspaceMain = FDB.Subspace(config[.REALM], Self.SERVICE_ID)
        self.subspaceCounter = subspaceMain["cnt"]
    }
}

public extension LGNCore.Address {
    static func node(service: String, name: String, realm: String, port: Int) -> LGNCore.Address {
        .ip(host: "\(name).\(service)-\(realm).service.elegion", port: port)
    }
}

@main
struct Main {
    static public func main() async throws {
        let VERSION = "1.3.2-async-await"
        let env = AppEnv.detect()

        let config = try Config<ConfigKeys>(
            rawConfig: ProcessInfo.processInfo.environment,
            isLocal: env == .local,
            localConfig: [
                .SALT: "da kak tak",
                .KEY: "viybynojeuhamyycecsynloh", // "3858f62230ac3c91",
                .REALM: "suncity", // "Inner-Mongolia",
                .WEBSITE_DOMAIN: "https://kirilltitov.com",
                .AUTHOR_LGNS_PORT: "1711",
                .LOG_LEVEL: "info",
                .LGNS_PORT: "1712",
                .HTTP_PORT: "8081",
                .PRIVATE_IP: "127.0.0.1",
                .REGISTER_TO_CONSUL: "false",
                .HASHIDS_SALT: "TXRcA(q7)1fZDp5z0v{_52",
                .HASHIDS_MIN_LENGTH: "5",
            ]
        )

        LoggingSystem.bootstrap(LGNLogger.init)
        LGNLogger.logLevel = .trace
        LGNLogger.hideLabel = true
        LGNLogger.hideTimezone = true

        let defaultLogger = Logger(label: "Quorum.Default")
        defaultLogger.info("Hello! Quorum v\(VERSION) on duty!")

        guard let logLevel = Logger.Level(rawValue: config[.LOG_LEVEL]) else {
            defaultLogger.critical("Invalid LOG_LEVEL value: \(config[.LOG_LEVEL])")
            fatalError()
        }

        LGNLogger.logLevel = logLevel
        defaultLogger.notice("Log level set to '\(logLevel)'")

        Entita.KEY_DICTIONARIES_ENABLED = false

        LGNCore.i18n.translator = LGNCore.i18n.FactoryTranslator(
            phrases: getPhrases(),
            allowedLocales: [.enUS, .ruRU]
        )

        let lifecycle = ServiceLifecycle()
        defaultLogger.info("Lifecycle installed")

        let eventLoopCount = System.coreCount.clamped(min: 4)
        let eventLoopGroup: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: eventLoopCount)
        defaultLogger.info("EventLoopGroup of \(eventLoopCount) event loops started")

        lifecycle.registerShutdown(label: "eventLoopGroup", .sync(eventLoopGroup.syncShutdownGracefully))

        let cryptor = try LGNP.Cryptor(key: config[.KEY])

        let clusterFile: String
        #if os(macOS)
        clusterFile = "/usr/local/etc/foundationdb/fdb.cluster"
        //clusterFile = "/Users/kirilltitov/Downloads/fdb.cluster"
        #else
        clusterFile = "/opt/foundationdb/fdb.cluster"
        #endif

        LGNLogger.logLevel = .debug
        let fdb = FDB(clusterFile: clusterFile)
        defaultLogger.info("FDB created")
        LGNLogger.logLevel = logLevel

        try fdb.connect()
        defaultLogger.info("FDB connected")

        lifecycle.registerShutdown(
            label: "FDB",
            .sync(fdb.disconnect)
        )
        defaultLogger.info("FDB shutdown registered")

        let requiredBitmask: LGNP.Message.ControlBitmask = [.signatureSHA512, /*.encrypted,*/ .contentTypeMsgPack]
        let client: LGNCClient
        if env == .local {
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
        defaultLogger.info("Client created")

        App.current = App(
            env: env,
            eventLoop: eventLoopGroup,
            client: client,
            config: config,
            fdb: fdb
        )

        await runMigrations(getMigrations(), on: fdb)
        defaultLogger.info("Migrations run")

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

        TestWebSocketController.setup()

        let serverHTTP = try SQuorum.getServerHTTP(
            at: .ip(host: App.current.HOST, port: App.current.HTTP_PORT),
            eventLoopGroup: eventLoopGroup,
            webSocketRouter: AuthWebSockeetRouter.self
        )
        lifecycle.register(
            label: "HTTP Server",
            start: .async(serverHTTP.bind),
            shutdown: .async(serverHTTP.shutdown)
        )

        let serverLGNS = try SQuorum.getServerLGNS(
            at: .ip(host: App.current.HOST, port: App.current.LGNS_PORT),
            cryptor: cryptor,
            eventLoopGroup: eventLoopGroup,
            requiredBitmask: requiredBitmask
        )
        lifecycle.register(
            label: "LGNS Server",
            start: .async(serverLGNS.bind),
            shutdown: .async(serverLGNS.shutdown)
        )

        if config[.REGISTER_TO_CONSUL].bool == true {
            try await registerToConsul()
        }

        lifecycle.start { maybeError in
            if let error = maybeError {
                defaultLogger.critical("Could not start Quorum: \(error)")
            } else {
                defaultLogger.info("Quorum is up!")
            }
        }
        lifecycle.wait()

        defaultLogger.info("Bye")
    }
}