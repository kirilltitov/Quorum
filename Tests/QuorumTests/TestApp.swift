import Foundation
import LGNConfig
import LGNC
import NIOPosix
import FDB
@testable import Quorum

/// Packed tuple elements written by hand, independently of the tuple layer
enum Packed {
    static func s(_ string: String) -> Bytes {
        [0x02] + Bytes(string.utf8) + [0x00]
    }

    static func i(_ int: Int) -> Bytes {
        precondition(int > 0)
        var bytes = withUnsafeBytes(of: UInt64(int).bigEndian, Bytes.init)
        while bytes.first == 0 {
            bytes.removeFirst()
        }
        return [0x14 + UInt8(bytes.count)] + bytes
    }

    static func b(_ bytes: Bytes) -> Bytes {
        [0x01] + bytes.flatMap { $0 == 0x00 ? [0x00, 0xFF] : [$0] } + [0x00]
    }
}

/// Quorum app connected to the test cluster (`FDB_CLUSTER_FILE`, `FDB_API_VERSION`), with its own realm
enum TestApp {
    static let realm = "quorum-tests-\(UUID().uuidString)"

    static let setUp: Void = {
        let environment = ProcessInfo.processInfo.environment
        try! FDB.Network.selectAPIVersion(environment["FDB_API_VERSION"].flatMap(Int32.init) ?? 630)
        let fdb = try! FDB.Database(clusterFile: environment["FDB_CLUSTER_FILE"])
        let config = try! Config<ConfigKeys>(
            rawConfig: [:],
            isLocal: true,
            localConfig: [
                .SALT: "salt",
                .KEY: "viybynojeuhamyycecsynloh",
                .REALM: realm,
                .WEBSITE_DOMAIN: "http://127.0.0.1:1",
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
        App.current = App(
            env: .local,
            eventLoop: MultiThreadedEventLoopGroup.singleton,
            client: LGNC.Client.Loopback(eventLoopGroup: MultiThreadedEventLoopGroup.singleton),
            config: config,
            fdb: fdb
        )
        // The loopback client runs Author contracts locally, within the context of the caller
        LGNC.ALLOW_ALL_TRANSPORTS = true
        guaranteeLocalAuthorContracts()
    }()
}
