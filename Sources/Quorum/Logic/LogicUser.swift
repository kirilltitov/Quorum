import Foundation
import Generated
import LGNCore
import LGNC
import Entita2
import FDB
import NIO

public extension Logic {
    class User {
        public enum E: Error {
            case UserNotFound
        }

        private static let usersLRU: CacheLRU<E2.UUID, Models.User> = CacheLRU(
            capacity: 1000,
            eventLoopGroup: eventLoopGroup,
            eventLoopCount: eventLoopCount
        )

        private static let errorNotAuthenticated = LGNC.ContractError.GeneralError("Not authenticated", 403)

        public static func authenticate(
            token: String,
            requestInfo: LGNCore.RequestInfo
        ) -> Future<Models.User> {
            let eventLoop = requestInfo.eventLoop

            let exploded = token.split(separator: ".", maxSplits: 2).map { String($0) }
            guard exploded.count == 3 else {
                return eventLoop.makeFailedFuture(self.errorNotAuthenticated)
            }

            return Services.Author.Contracts.Authenticate
                .execute(
                    at: .node(
                        service: "author",
                        name: exploded[1],
                        realm: PORTAL_ID,
                        port: AUTHOR_PORT
                    ),
                    with: .init(portal: exploded[0], token: exploded[2]),
                    using: client,
                    requestInfo: requestInfo
                )
                .flatMapErrorThrowing { error in
                    if case LGNC.ContractError.RemoteContractExecutionFailed = error {
                        return .init(IDUser: nil)
                    }
                    throw error
                }
                .flatMapThrowing { response in
                    guard let rawIDUser = response.IDUser else {
                        throw self.errorNotAuthenticated
                    }
                    guard let IDUser = Models.User.Identifier(rawIDUser) else {
                        throw LGNC.ContractError.GeneralError("Invalid ID User \(rawIDUser)", 403)
                    }
                    return self.get(by: IDUser, requestInfo: requestInfo)
                }
                .mapThrowing { (maybeUser: Models.User?) in
                    guard let user = maybeUser else {
                        throw LGNC.ContractError.GeneralError("User not found for some reason", 403)
                    }
                    return user
                }
        }

        public static func maybeAuthenticate(token: String?, requestInfo: LGNCore.RequestInfo) -> Future<Models.User?> {
            guard let token = token else {
                return requestInfo.eventLoop.makeSucceededFuture(nil)
            }

            return self
                .authenticate(token: token, requestInfo: requestInfo)
                .map { Optional($0) }
        }

        public static func get(by ID: Models.User.Identifier) -> Future<Models.User?> {
            return self.get(
                by: ID,
                requestInfo: RequestInfo(
                    remoteAddr: config[.PRIVATE_IP],
                    clientAddr: config[.PRIVATE_IP],
                    userAgent: "Quorum",
                    locale: .enUS,
                    uuid: UUID(),
                    isSecure: true,
                    transport: .LGNS,
                    eventLoop: eventLoopGroup.eventLoop
                )
            )
        }

        public static func get(
            by ID: Models.User.Identifier,
            requestInfo: LGNCore.RequestInfo
        ) -> Future<Models.User?> {
            let eventLoop = requestInfo.eventLoop

            return self.usersLRU.getOrSet(by: ID, on: eventLoop) {
                Services.Author.Contracts.UserInfoInternal
                    .execute(
                        at: .node(
                            service: "author",
                            name: "viktor",
                            realm: PORTAL_ID,
                            port: AUTHOR_PORT
                        ),
                        with: .init(ID: ID.string),
                        using: client,
                        requestInfo: requestInfo
                    )
                    .flatMap { (user: Services.Author.Contracts.UserInfoInternal.Response) in
                        Models.User
                            .load(by: ID, on: eventLoop)
                            .flatMap { maybeInnerUser in
                                if let innerUser = maybeInnerUser {
                                    return eventLoop.makeSucceededFuture(innerUser)
                                }
                                let innerUser = Models.User(
                                    ID: ID,
                                    username: user.username,
                                    accessLevel: Models.User.AccessLevel(rawValue: user.accessLevel) ?? .User
                                )
                                return innerUser
                                    .save(on: eventLoop)
                                    .map { innerUser }
                            }
                    }
                    .flatMapErrorThrowing { error in
                        if case LGNC.E.MultipleError(let dict) = error, dict.getGeneralErrorCode() == 404 {
                            return nil
                        }
                        throw error
                    }
            }
        }
    }
}
