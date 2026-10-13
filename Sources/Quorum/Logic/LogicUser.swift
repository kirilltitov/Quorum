import Foundation
import Generated
import LGNCore
import LGNLog
import LGNC
import FDB
import FDBEntity

public extension LGNCore.Context {
    var errorNotAuthenticated: LGNC.ContractError {
        LGNC.ContractError.GeneralError("Not authenticated".tr(), 401)
    }
}

/// A small cache of users with limited lifetime of entries, so changes made elsewhere (e.g. in Author) show up
actor UserCache {
    private struct Entry {
        let user: Models.User
        let expires: Date
    }

    private let capacity: Int
    private let ttl: TimeInterval
    private var storage: [Models.User.Identifier: Entry] = [:]

    init(capacity: Int, ttl: TimeInterval) {
        self.capacity = capacity
        self.ttl = ttl
    }

    func get(_ ID: Models.User.Identifier) -> Models.User? {
        guard let entry = self.storage[ID] else {
            return nil
        }
        guard entry.expires > Date() else {
            self.storage[ID] = nil
            return nil
        }
        return entry.user
    }

    func set(_ user: Models.User) {
        if self.storage.count >= self.capacity {
            let now = Date()
            self.storage = self.storage.filter { $0.value.expires > now }
            if self.storage.count >= self.capacity {
                self.storage.removeAll(keepingCapacity: true)
            }
        }
        self.storage[user.ID] = Entry(user: user, expires: Date().addingTimeInterval(self.ttl))
    }

    func remove(_ ID: Models.User.Identifier) {
        self.storage[ID] = nil
    }
}

public extension Logic {
    enum User {
        public enum E: Error {
            case UserNotFound
        }

        private static let cache = UserCache(capacity: 1000, ttl: 60)

        /// Author node names are host name labels (`<name>.author-<realm>.service.elegion`)
        static func isValidAuthorName(_ name: String) -> Bool {
            !name.isEmpty
                && name.count <= 63
                && name.unicodeScalars.allSatisfy { ("a"..."z").contains($0) || ("0"..."9").contains($0) || $0 == "-" }
        }

        public static func authenticate(request: AnyEntityWithSession) async throws -> Models.User {
            try await self.authenticate(
                session: request.session.value,
                portal: request.portal.value,
                author: request.author.value
            )
        }

        public static func authenticate(session: String, portal: String, author: String) async throws -> Models.User {
            guard self.isValidAuthorName(author) else {
                throw LGNCore.Context.current.errorNotAuthenticated
            }

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

            Logger.current.info("Authenticated user '\(user.username)' (\(user.ID.string))")

            return user
        }

        public static func maybeAuthenticate(request: AnyEntityWithMaybeSession) async throws -> Models.User? {
            guard
                let session = request.session?.value,
                let portal = request.portal?.value,
                let author = request.author?.value
            else {
                return nil
            }

            return try await self.authenticate(session: session, portal: portal, author: author)
        }

        public static func get(by IDString: String) async throws -> Models.User? {
            guard let ID = Models.User.Identifier(IDString) else {
                throw LGNC.ContractError.GeneralError("Invalid ID", 400)
            }

            return try await self.get(by: ID)
        }

        public static func invalidate(ID: Models.User.Identifier) async {
            await self.cache.remove(ID)
        }

        public static func get(by ID: Models.User.Identifier) async throws -> Models.User? {
            if let user = await self.cache.get(ID) {
                return user
            }
            guard let user = try await self.load(by: ID) else {
                return nil
            }
            await self.cache.set(user)
            return user
        }

        /// Loads the user from the storage, or from Author (and stores it) if it's not known yet
        private static func load(by ID: Models.User.Identifier) async throws -> Models.User? {
            let logger = Logger.current

            if let innerUser = try await Models.User.load(by: ID) {
                return innerUser
            }

            let address: LGNCore.Address = .node(
                service: "author",
                name: "viktor",
                realm: App.current.PORTAL_ID,
                port: App.current.AUTHOR_PORT
            )
            logger.info("No inner user, about to load origin user \(ID.string) info via UserInfoInternal contract @ \(address)")

            let originUserInfo: Services.Shared.User
            do {
                originUserInfo = try await Services.Author.Contracts.UserInfoInternal.execute(
                    at: address,
                    with: .init(ID: ID.string),
                    using: App.current.client,
                    context: LGNCore.Context.current
                )
            } catch {
                if case LGNC.E.MultipleError(let dict) = error, dict.getGeneralErrorCode() == 404 {
                    logger.info("Remote user \(ID.string) not found")
                    return nil
                }
                throw error
            }

            let user = Models.User(
                ID: ID,
                username: originUserInfo.username,
                accessLevel: Models.User.AccessLevel(rawValue: originUserInfo.accessLevel) ?? .User
            )
            do {
                try await user.insert()
            } catch FDB.EntityError.alreadyExists {
                // Loaded concurrently by another request
                return try await Models.User.load(by: ID)
            }
            logger.info("Loaded origin user \(ID.string) from \(address): \(user.accessLevel.rawValue) '\(user.username)'")

            return user
        }

        public static func set(accessLevel: Models.User.AccessLevel, for ID: Models.User.Identifier) async throws {
            try await App.current.fdb.withTransaction { transaction in
                guard var user = try await Models.User.load(by: ID, within: transaction) else {
                    throw LGNC.ContractError.GeneralError("User '\(ID.string)' not found", 404)
                }
                user.accessLevel = accessLevel
                try await user.save(within: transaction)
            }
            await self.invalidate(ID: ID)
        }
    }
}
