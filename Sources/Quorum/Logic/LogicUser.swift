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
        
        public static func authorize(token: String, on eventLoop: EventLoop) -> Future<Models.User> {
            let exploded = token.split(separator: ".", maxSplits: 2).map { String($0) }
            guard exploded.count == 3 else {
                return eventLoop.newFailedFuture(error: LGNC.ContractError.GeneralError("Invalid token", 400))
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
                        throw LGNC.ContractError.GeneralError("Not authorized", 403)
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
        
        public static func get(by ID: Models.User.Identifier, on eventLoop: EventLoop) -> Future<Models.User?> {
            typealias Contract = Services.Author.Contracts.UserInfo
            
            return self.usersLRU.getOrSet(for: ID) {
                Contract
                    .execute(at: .port(1700), with: .init(ID: ID.string), using: client)
                    .map { Models.User(ID: ID, username: $0.username, isAdmin: $0.accessLevel == "Admin") }
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
