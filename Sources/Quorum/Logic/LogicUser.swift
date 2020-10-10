import Foundation
import Generated
import LGNCore
import LGNC
import Entita2
import FDB
import NIO

public extension LGNCore.Context {
    var errorNotAuthenticated: LGNC.ContractError {
        return LGNC.ContractError.GeneralError("Not authenticated".tr(self.locale), 401)
    }
}

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

        public static func authenticate(
            request: AnyEntityWithSession,
            context: LGNCore.Context
        ) -> EventLoopFuture<Models.User> {
            self.authenticate(
                session: request.session.value,
                portal: request.portal.value,
                author: request.author.value,
                context: context
            )
        }

        private static func authenticate(
            session: String,
            portal: String,
            author: String,
            context: LGNCore.Context
        ) -> EventLoopFuture<Models.User> {
            Services.Author.Contracts.Authenticate
                .execute(
                    at: .node(
                        service: "author",
                        name: author,
                        realm: PORTAL_ID,
                        port: AUTHOR_PORT
                    ),
                    with: .init(
                        portal: LGNC.Entity.Cookie(name: "portal", value: portal),
                        session: LGNC.Entity.Cookie(name: "session", value: session)
                    ),
                    using: client,
                    context: context
                )
                .flatMapErrorThrowing { error in
                    if case LGNC.ContractError.RemoteContractExecutionFailed = error {
                        return .init(IDUser: nil)
                    }
                    throw error
                }
                .flatMapThrowing { response in
                    guard let rawIDUser = response.IDUser else {
                        throw context.errorNotAuthenticated
                    }
                    guard let IDUser = Models.User.Identifier(rawIDUser) else {
                        throw LGNC.ContractError.GeneralError("Invalid ID User \(rawIDUser)", 403)
                    }
                    return self.get(by: IDUser, context: context)
                }
                .mapThrowing { (maybeUser: Models.User?) in
                    guard let user = maybeUser else {
                        throw LGNC.ContractError.GeneralError("User not found for some reason", 403)
                    }
                    return user
                }
        }

        public static func maybeAuthenticate(
            request: AnyEntityWithMaybeSession,
            context: LGNCore.Context
        ) -> EventLoopFuture<Models.User?> {
            guard let session = request.session?.value else {
                return context.eventLoop.makeSucceededFuture(nil)
            }
            guard let portal = request.portal?.value else {
                return context.eventLoop.makeSucceededFuture(nil)
            }
            guard let author = request.author?.value else {
                return context.eventLoop.makeSucceededFuture(nil)
            }

            return self
                .authenticate(
                    session: session,
                    portal: portal,
                    author: author,
                    context: context
                )
                .map { Optional($0) }
        }

        public static func get(by IDString: String, context: LGNCore.Context) -> EventLoopFuture<Models.User?> {
            guard let ID = Models.User.Identifier(IDString) else {
                return context.eventLoop.makeFailedFuture(
                    LGNC.ContractError.GeneralError("Invalid ID", 400)
                )
            }

            return self.get(by: ID, context: context)
        }

        public static func get(by ID: Models.User.Identifier) -> EventLoopFuture<Models.User?> {
            return self.get(
                by: ID,
                context: Context(
                    remoteAddr: config[.PRIVATE_IP],
                    clientAddr: config[.PRIVATE_IP],
                    userAgent: "Quorum",
                    locale: .enUS,
                    uuid: UUID(),
                    isSecure: true,
                    transport: .LGNS,
                    meta: [:],
                    eventLoop: eventLoopGroup.eventLoop
                )
            )
        }

        public static func get(
            by ID: Models.User.Identifier,
            context: LGNCore.Context
        ) -> EventLoopFuture<Models.User?> {
            let eventLoop = context.eventLoop

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
                        context: context
                    )
                    .flatMap { (user: Services.Author.Contracts.UserInfoInternal.Response) in
                        Models.User
                            .load(by: ID, storage: fdb, on: eventLoop)
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
                                    .save(storage: fdb, on: eventLoop)
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
