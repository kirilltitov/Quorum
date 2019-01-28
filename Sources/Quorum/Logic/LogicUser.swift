import Foundation
import Generated
import LGNC
import Entita2
import FDB
import NIO

public extension Logic {
    public class User {
        public enum E: Error {
            case UserNotFound
        }
        
        private static let usersLRU: CacheLRU<E2.UUID, Models.User> = CacheLRU(capacity: 1000)
        //private static let usersLRU = CacheLRU<E2.UUID, Models.User>()
        
        public static func authorize(token: String, on eventLoop: EventLoop) -> Future<Models.User> {
            let generalError = LGNC.ContractError.GeneralError("Not authorized", 403)

            let exploded = token.split(separator: ".", maxSplits: 2).map { String($0) }
            guard exploded.count == 3 else {
                return eventLoop.newFailedFuture(error: generalError)
            }
            
            typealias Contract = Services.Author.Contracts.Authenticate
            return Contract
                .execute(
                    at: .node(
                        service: "Author",
                        name: exploded[1],
                        realm: PORTAL_ID,
                        port: 1700
                    ),
                    with: .init(portal: exploded[0], token: exploded[2]),
                    using: client
                )
                .thenIfErrorThrowing { error in
                    if case LGNC.ContractError.RemoteContractExecutionFailed = error {
                        return .init(IDUser: nil)
                    }
                    throw error
                }
                .flatMapThrowing { response in
                    guard let rawIDUser = response.IDUser else {
                        throw generalError
                    }
                    guard let IDUser = Models.User.Identifier(rawIDUser) else {
                        throw LGNC.ContractError.GeneralError("Invalid ID User \(rawIDUser)", 403)
                    }
                    return self.get(by: IDUser, on: eventLoop)
                }
                .thenThrowing { (maybeUser: Models.User?) in
                    guard let user = maybeUser else {
                        throw LGNC.ContractError.GeneralError("User not found for some reason", 403)
                    }
                    return user
                }
        }

        public static func maybeAuthorize(token: String?, on eventLoop: EventLoop) -> Future<Models.User?> {
            guard let _token = token else {
                return eventLoop.newSucceededFuture(result: nil)
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
            typealias Contract = Services.Author.Contracts.UserInfo

            return self.usersLRU.getOrSet(by: ID, on: eventLoop) {
                Contract
                    .execute(at: .port(1700), with: .init(ID: ID.string), using: client)
                    .map {
                        Models.User(
                            ID: ID,
                            username: $0.username,
                            accessLevel: Models.User.AccessLevel(rawValue: $0.accessLevel) ?? .User
                        )
                    }
                    .thenIfErrorThrowing { error in
                        if case LGNC.E.MultipleError(let dict) = error, dict.getGeneralErrorCode() == 404 {
                            return nil
                        }
                        throw error
                    }
            }
        }
    }
}
