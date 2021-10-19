import Foundation
import Generated
import LGNCore
import LGNC
import Entita2
import FDB

public extension LGNCore.Context {
    var errorNotAuthenticated: LGNC.ContractError {
        LGNC.ContractError.GeneralError("Not authenticated".tr(), 401)
    }
}

// let addr = LGNCore.Address.ip(host: "10.133.54.35", port: 1811)

public extension Logic {
    class User {
        public enum E: Error {
            case UserNotFound
        }

        private static let usersLRU: CacheLRU<E2.UUID, Models.User> = CacheLRU(capacity: 1000)

        public static func authenticate(request: AnyEntityWithSession) async throws -> Models.User {
            try await self.authenticate(
                session: request.session.value,
                portal: request.portal.value,
                author: request.author.value
            )
        }

        public static func authenticate(session: String, portal: String, author: String) async throws -> Models.User {
            let rawIDUser: String?
            do {
                rawIDUser = try await Services.Author.Contracts.Authenticate
                    .execute(
                        at: .node(
                            service: "author",
                            name: author,
                            realm: App.current.PORTAL_ID,
                            port: App.current.AUTHOR_PORT
                        ),
                        with: .init(
                            portal: LGNC.Entity.Cookie(name: "portal", value: portal),
                            session: LGNC.Entity.Cookie(name: "session", value: session)
                        ),
                        using: App.current.client
                    )
                    .IDUser
            } catch LGNC.ContractError.RemoteContractExecutionFailed {
                rawIDUser = nil
            }

            guard let rawIDUser = rawIDUser else {
                throw LGNCore.Context.current.errorNotAuthenticated
            }
            guard let IDUser = Models.User.Identifier(rawIDUser) else {
                throw LGNC.ContractError.GeneralError("Invalid ID User \(rawIDUser)", 403)
            }

            guard let user = try await self.get(by: IDUser) else {
                throw LGNC.ContractError.GeneralError("User not found for some reason", 403)
            }

            LGNCore.Context.current.logger.info("Authenticated user '\(user.username)' (\(user.ID.string))")

            return user
        }

        public static func maybeAuthenticate(request: AnyEntityWithMaybeSession) async throws -> Models.User? {
            guard let session = request.session?.value else {
                return nil
            }
            guard let portal = request.portal?.value else {
                return nil
            }
            guard let author = request.author?.value else {
                return nil
            }

            return try await self.authenticate(
                session: session,
                portal: portal,
                author: author
            )
        }

        public static func get(by IDString: String) async throws -> Models.User? {
            guard let ID = Models.User.Identifier(IDString) else {
                throw LGNC.ContractError.GeneralError("Invalid ID", 400)
            }

            return try await self.get(by: ID)
        }

        public static func get(by ID: Models.User.Identifier) async throws -> Models.User? {
            try await self.usersLRU.getOrSet(by: ID) {
                let logger = LGNCore.Context.current.logger
                do {
                    if let innerUser = try await Models.User.load(by: ID) {
                        logger.info("Loaded inner user \(ID.string): \(innerUser.accessLevel.rawValue) '\(innerUser.username)'")
                        return innerUser
                    }

                    let address: LGNCore.Address = .node(
                        service: "author",
                        name: "viktor",
                        realm: App.current.PORTAL_ID,
                        port: App.current.AUTHOR_PORT
                    )
                    let client = App.current.client
                    logger.info("No inner user, about to load origin user \(ID.string) info via UserInfoInternal contract @ \(address) with client \(type(of: client))")
                    let originUserInfo = try await Services.Author.Contracts.UserInfoInternal.execute(
                        at: address,
                        with: .init(ID: ID.string),
                        using: client,
                        context: LGNCore.Context.current
                    )
                    logger.info("Loaded origin user \(ID.string) info from \(address): \(String(describing: try? originUserInfo.getDictionary()))")

                    let innerUser = Models.User(
                        ID: ID,
                        username: originUserInfo.username,
                        accessLevel: Models.User.AccessLevel(rawValue: originUserInfo.accessLevel) ?? .User
                    )
                    try await innerUser.save()

                    return innerUser
                } catch {
                    if case LGNC.E.MultipleError(let dict) = error, dict.getGeneralErrorCode() == 404 {
                        logger.info("Remote user \(ID.string) not found")
                        return nil
                    }
                    throw error
                }
            }
        }
    }
}
