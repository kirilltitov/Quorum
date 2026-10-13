import Foundation
import Generated
import LGNCore
import LGNLog
import LGNConfig
import LGNC
import LGNP
import LGNS
import Entita
import FDB
import FDBEntity
import AsyncHTTPClient
import ServiceLifecycle
import NIOCore
import NIOPosix

public typealias SQuorum = Services.Quorum
public typealias SAuthor = Services.Author
public typealias Context = LGNCore.Context

public enum E: Error {
    case Consul(String)
}

public struct Models {}
public struct Logic {}

public struct App {
    nonisolated(unsafe) public static var current: Self!

    public static let SERVICE_ID = "Quorum"
    public static let POST_KEY = "Post"
    public static let COMMENT_KEY = "Comment"

    public static let COMMENT_EDITABLE_TIME_SECONDS: TimeInterval = 3600
    public static let COMMENT_LIKEABLE_TIME_SECONDS: TimeInterval = 86400 * 365
    public static let COMMENT_POST_COOLDOWN_SECONDS: TimeInterval = 5
    public static let COMMENT_EDIT_COOLDOWN_SECONDS: TimeInterval = 5

    public static let defaultUser = FDB.UUID("00000000-1637-0034-1711-000000000000")!
    public static var adminUserID: FDB.UUID { self.defaultUser }
    public static let empty = LGNC.Entity.Empty()

    public let env: AppEnv
    public let eventLoop: EventLoopGroup
    public let client: LGNCClient
    public let config: Config<ConfigKeys>

    public let fdb: FDB.Database
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
        fdb: FDB.Database
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
    static func main() async throws {
        let VERSION = "1.5.0"
        let env = AppEnv.detect()

        let config = try Config<ConfigKeys>(
            rawConfig: ProcessInfo.processInfo.environment,
            isLocal: env == .local,
            localConfig: [
                .SALT: "da kak tak",
                .KEY: "viybynojeuhamyycecsynloh",
                .REALM: "suncity",
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

        LoggingSystem.bootstrap(LGNLogger.init)
        LGNLogger.logLevel = .trace
        LGNLogger.hideLabel = true
        LGNLogger.hideTimezone = true

        let defaultLogger = Logger(label: "Quorum.Default")
        defaultLogger.info("Hello! Quorum v\(VERSION) on duty!")

        guard let logLevel = Logger.Level(rawValue: config[.LOG_LEVEL]) else {
            defaultLogger.critical("Invalid LOG_LEVEL value: \(config[.LOG_LEVEL])")
            exit(1)
        }

        LGNLogger.logLevel = logLevel
        defaultLogger.notice("Log level set to '\(logLevel)'")

        Entita.KEY_DICTIONARIES_ENABLED = false

        LGNCore.i18n.translator = LGNCore.i18n.FactoryTranslator(
            phrases: getPhrases(),
            allowedLocales: [.enUS, .ruRU]
        )

        let eventLoopCount = System.coreCount.clamped(min: 4)
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: eventLoopCount)
        defaultLogger.info("EventLoopGroup of \(eventLoopCount) event loops started")

        let cryptor = try LGNP.Cryptor(key: config[.KEY])

        // Production cluster runs FoundationDB 6.3: its client library is loaded by the multi-version client
        // (FDB_NETWORK_OPTION_EXTERNAL_CLIENT_DIRECTORY), which works only with the API version of the cluster
        let environment = ProcessInfo.processInfo.environment
        let apiVersion = environment["FDB_API_VERSION"].flatMap(Int32.init) ?? 630
        try FDB.Network.selectAPIVersion(apiVersion)

        let clusterFile: String
        #if os(macOS)
        clusterFile = environment["FDB_CLUSTER_FILE"] ?? "/usr/local/etc/foundationdb/fdb.cluster"
        #else
        clusterFile = environment["FDB_CLUSTER_FILE"] ?? "/opt/foundationdb/fdb.cluster"
        #endif

        let fdb = try FDB.Database(clusterFile: clusterFile, logger: Logger(label: "Quorum.FDB"))
        defaultLogger.info("FDB opened (cluster file \(clusterFile), API version \(apiVersion))")

        let requiredBitmask: LGNP.Message.ControlBitmask = [.signatureSHA512, .contentTypeMsgPack]
        let client: any LGNCClient
        let clientDynamic: LGNC.Client.Dynamic?
        if env == .local {
            client = LGNC.Client.Loopback(eventLoopGroup: eventLoopGroup)
            clientDynamic = nil
            // The loopback client runs Author contracts locally, within the context of the caller
            LGNC.ALLOW_ALL_TRANSPORTS = true
            guaranteeLocalAuthorContracts()
        } else {
            let dynamic = LGNC.Client.Dynamic(
                eventLoopGroup: eventLoopGroup,
                clientLGNS: LGNS.Client(
                    cryptor: cryptor,
                    controlBitmask: requiredBitmask,
                    eventLoopGroup: eventLoopGroup
                ),
                clientHTTP: HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
            )
            client = dynamic
            clientDynamic = dynamic
        }
        defaultLogger.info("Client created")

        App.current = App(
            env: env,
            eventLoop: eventLoopGroup,
            client: client,
            config: config,
            fdb: fdb
        )

        // Fail fast if the cluster is not reachable
        _ = try await fdb.withTransaction { tr in try await tr.getReadVersion().value }
        defaultLogger.info("FDB connected")

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
            webSocketRouter: LGNC.WebSocket.SimpleRouter.self
        )

        let serverLGNS = try SQuorum.getServerLGNS(
            at: .ip(host: App.current.HOST, port: App.current.LGNS_PORT),
            cryptor: cryptor,
            eventLoopGroup: eventLoopGroup,
            requiredBitmask: requiredBitmask
        )

        if config[.REGISTER_TO_CONSUL].bool == true {
            try await registerToConsul()
        }

        let serviceGroup = ServiceGroup(
            services: [serverHTTP, serverLGNS],
            gracefulShutdownSignals: [.sigterm, .sigint],
            logger: defaultLogger
        )
        defaultLogger.info("Quorum is up!")
        do {
            try await serviceGroup.run()
        } catch {
            defaultLogger.critical("Quorum failed: \(error)")
        }

        try? await clientDynamic?.disconnect()
        try? await eventLoopGroup.shutdownGracefully()
        try? FDB.Network.stop()

        defaultLogger.info("Bye")
    }
}
