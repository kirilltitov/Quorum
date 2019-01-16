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

    public class Comment {
        public static func get(by ID: Models.Comment.Identifier, on eventLoop: EventLoop) -> Future<Models.Comment?> {
            return Models.Comment.get(by: ID, on: eventLoop)
        }
        
        public static func getThrowingWithTransaction(
            by ID: Models.Comment.Identifier,
            on eventLoop: EventLoop
        ) -> Future<(Models.Comment, Transaction)> {
            return Models.Comment
                .loadWithTransaction(by: ID, on: eventLoop)
                .thenThrowing { maybeComment, transaction in
                    guard let comment = maybeComment else {
                        throw LGNC.ContractError.GeneralError("Comment not found (it should)", 404)
                    }
                    return (comment, transaction)
            }
        }

        public static func doExists(ID: Int, on eventLoop: EventLoop) -> Future<Bool> {
            return self
                .get(by: ID, on: eventLoop)
                .map { $0 != nil }
        }

        public static func insert(comment: Models.Comment, on eventLoop: EventLoop) -> Future<Models.Comment> {
            return comment.insert(on: eventLoop).map { _ in comment }
        }

        public static func save(comment: Models.Comment, on eventLoop: EventLoop) -> Future<Models.Comment> {
            return comment.save(on: eventLoop).map { _ in comment }
        }

        public static func getProcessedBody(from string: String) -> String {
            return string
        }

        public static func delete(
            commentID: Models.Comment.Identifier,
            on eventLoop: EventLoop
        ) -> Future<Void> {
            return self
                .get(by: commentID, on: eventLoop)
                .then {
                    guard let comment = $0 else {
                        return eventLoop.newSucceededFuture(result: ())
                    }
                    return fdb
                        .begin(eventLoop: eventLoop)
                        .then { $0.clear(key: comment.getIDAsKey()) }
                        .then { $0.clear(key: Models.Comment.refID.getIndexKey(from: comment.ID)) }
                        .then { $0.commit() }
                }
        }

        public static func like(
            comment: Models.Comment,
            by user: Models.User,
            on eventLoop: EventLoop
        ) -> Future<Int> {
            return Models.Like.like(comment: comment, by: user, on: eventLoop)
        }
        
        public static func edit(
            comment: Models.Comment,
            body: String,
            with transaction: Transaction,
            on eventLoop: EventLoop
        ) -> Future<Models.Comment> {
            comment.body = Logic.Comment.getProcessedBody(from: body)
            comment.dateUpdated = Date()

            return comment
                .save(with: transaction, on: eventLoop)
                .then { transaction in transaction.commit() }
                .map { _ in comment }
        }
    }

    public class Post {
        public struct CommentWithLikes {
            public let comment: Models.Comment
            private(set) var likes: Int

            mutating func incrementLikes() {
                self.likes += 1
            }
        }

        public enum E: Error {
            case PostNotFound
        }

        private static let postsLRU: CacheLRU<Int, Models.Post> = CacheLRU(capacity: 1000)

        public static func get(by ID: Int, on eventLoop: EventLoop) -> Future<Models.Post?> {
            return self.postsLRU.getOrSet(for: ID) {
                Models.Post.load(
                    by: ID,
                    on: eventLoop
                )
            }
        }

        public static func isExistingAndCommentable(_ ID: Int, on eventLoop: EventLoop) -> Future<Bool> {
            return self
                .get(by: ID, on: eventLoop)
                .map { $0?.isCommentable ?? false }
        }

        public static func getCommentsFor(
            ID: Int,
            on eventLoop: EventLoop
        ) -> Future<[Models.Comment.Identifier: CommentWithLikes]> {
            return self.get(
                by: ID,
                on: eventLoop
            ).thenThrowing {
                guard let post = $0 else {
                    throw E.PostNotFound
                }
                return post
            }.then { (post: Models.Post) -> Future<(Models.Post, Transaction)> in
                fdb.begin(eventLoop: eventLoop).map { (post, $0) }
            }.then { (post, transaction) in
                transaction
                    .get(range: Models.Comment._getPostPrefix(post.ID).range)
                    .map { $0.0 }
            }.thenThrowing {
                var result: [Models.Comment.Identifier: CommentWithLikes] = [:]
                for record in $0.records {
                    let tuple = Tuple(from: record.key)
                    if Models.Comment.doesRelateToThis(tuple: tuple) {
                        let comment = try Models.Comment(from: record.value)
                        result[comment.ID] = CommentWithLikes(comment: comment, likes: 0)
                    } else if Models.Like.doesRelateToThis(tuple: tuple) {
                        if let commentID = Models.Like.getCommentID(from: tuple) {
                            result[commentID]?.incrementLikes()
                        }
                    }
                }
                return result
            }
        }
    }
}
