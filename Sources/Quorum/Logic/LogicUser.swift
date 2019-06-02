import Foundation
import Generated
import LGNC
import Entita2
import FDB
import NIO

public extension Logic {
    class User {
        public enum E: Error {
            case UserNotFound
        }
        
        private static let usersLRU: CacheLRU<E2.UUID, Models.User> = CacheLRU(capacity: 1000)
        //private static let usersLRU = CacheLRU<E2.UUID, Models.User>()
        private static let errorNotAuthorized = LGNC.ContractError.GeneralError("Not authorized", 403)
        
        public static func authorize(token: String, on eventLoop: EventLoop) -> Future<Models.User> {
            let exploded = token.split(separator: ".", maxSplits: 2).map { String($0) }
            guard exploded.count == 3 else {
                return eventLoop.makeFailedFuture(self.errorNotAuthorized)
            }

            return Services.Author.Contracts.Authenticate
                .execute(
                    at: .node(
                        service: "Author",
                        name: exploded[1],
                        realm: PORTAL_ID,
                        port: AUTHOR_PORT
                    ),
                    with: .init(portal: exploded[0], token: exploded[2]),
                    using: client
                )
                .flatMapErrorThrowing { error in
                    if case LGNC.ContractError.RemoteContractExecutionFailed = error {
//                        return Services.Author.Contracts.Authenticate.Response(IDUser: nil)
                        return .init(IDUser: nil)
                    }
                    throw error
                }
                .flatMapThrowing { response in
                    guard let rawIDUser = response.IDUser else {
                        throw self.errorNotAuthorized
                    }
                    guard let IDUser = Models.User.Identifier(rawIDUser) else {
                        throw LGNC.ContractError.GeneralError("Invalid ID User \(rawIDUser)", 403)
                    }
                    return self.get(by: IDUser, on: eventLoop)
                }
                .mapThrowing { (maybeUser: Models.User?) in
                    guard let user = maybeUser else {
                        throw LGNC.ContractError.GeneralError("User not found for some reason", 403)
                    }
                    return user
                }
        }

        public static func maybeAuthorize(token: String?, on eventLoop: EventLoop) -> Future<Models.User?> {
            guard let _token = token else {
                return eventLoop.makeSucceededFuture(nil)
            }
            return self
                .authorize(token: _token, on: eventLoop)
                .map { Optional($0) }
        }

        public static func refresh(ID: Models.User.Identifier, on eventLoop: EventLoop) -> Future<Void> {
            self.usersLRU.remove(by: ID, on: eventLoop)
            return self
                .get(by: ID, on: eventLoop)
                .map { _ in ()}
        }
        
        public static func get(by ID: Models.User.Identifier, on eventLoop: EventLoop) -> Future<Models.User?> {
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
                        using: client
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
