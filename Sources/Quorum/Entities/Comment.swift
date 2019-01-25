import Foundation
import LGNCore
import Entita2FDB
import NIO

public extension Models {
    final public class Comment: ModelInt, Entita2FDBIndexedEntity {
        public static let IDKey: KeyPath<Comment, Int> = \.ID
        public static var fullEntityName = false
        
        public static var indices: [String : Entita2.Index<Models.Comment>] = [
            "ID": E2.Index(\.ID)
        ]

        public enum CodingKeys: String, CodingKey {
            case ID = "a"
            case IDUser = "b"
            case IDPost = "c"
            case IDReplyComment = "d"
            case isDeleted = "e"
            case body = "f"
            case dateCreated = "g"
            case dateUpdated = "h"
        }

        public let ID: Int
        public let IDUser: User.Identifier
        public let IDPost: Post.Identifier
        public let IDReplyComment: Int?
        public var isDeleted: Bool
        public var body: String
        public let dateCreated: Date
        public var dateUpdated: Date

        public static let indices = [
            \Comment.ID,
            \Comment.IDUser,
        ]

        public func getUser(on eventLoop: EventLoop) -> Future<User> {
            return Logic.User.get(
                by: self.IDUser,
                on: eventLoop
            ).map {
                guard let user = $0 else {
                    return User.unknown
                }
                return user
            }
        }

        public static func getUsingRefID(
            by ID: Comment.Identifier,
            on eventLoop: EventLoop
        ) -> Future<Models.Comment?> {
            return self.loadByIndex(name: "ID", value: ID, on: eventLoop)
        }

        public static func getUsingRefIDWithTransaction(
            by ID: Comment.Identifier,
            on eventLoop: EventLoop
        ) -> Future<(Models.Comment?, Transaction)> {
            return fdb
                .begin(eventLoop: eventLoop)
                .then { transaction in
                    self
                        .loadByIndex(name: "ID", value: ID, with: transaction, on: eventLoop)
                        .map { maybeComment in (maybeComment, transaction) }
                }
        }

        public func getIndexIndexSubspace() -> Subspace {
            return Comment.subspace[Comment.entityName][self.ID]["idx"]
        }

        // this is extracted because logic would like to use it as range
        public static func _getPostPrefix(_ ID: Post.Identifier) -> Subspace {
            return self.subspace[Post.entityName][ID][Comment.entityName]
        }

        public func _getFullPrefix() -> Subspace {
            return Comment._getPostPrefix(self.IDPost)[self.ID]
        }

        public func getIDAsKey() -> Bytes {
            return self._getFullPrefix().asFDBKey()
        }

        public init(
            ID: Int,
            IDUser: User.Identifier,
            IDPost: Post.Identifier,
            IDReplyComment: Int?,
            isDeleted: Bool,
            body: String,
            dateCreated: Date,
            dateUpdated: Date
        ) {
            self.ID = ID
            self.IDUser = IDUser
            self.IDPost = IDPost
            self.IDReplyComment = IDReplyComment
            self.isDeleted = isDeleted
            self.body = body
            self.dateCreated = dateCreated
            self.dateUpdated = dateUpdated
        }

        public static func await(
            on eventLoop: EventLoop,
            ID IDFuture: Future<Int>,
            IDUser IDUserFuture: Future<User.Identifier>,
            IDPost: Post.Identifier,
            IDReplyComment: Int?,
            isDeleted: Bool,
            body: String,
            dateCreated: Date,
            dateUpdated: Date
        ) -> Future<Comment> {
            return eventLoop.newSucceededFuture(result: ())
                .then { () in
                    IDFuture.map { ID in (ID) }
                }
                .then { (ID) in
                    IDUserFuture.map { IDUser in (ID, IDUser) }
                }
                .map { (ID, IDUser) in
                    Comment(
                        ID: ID,
                        IDUser: IDUser,
                        IDPost: IDPost,
                        IDReplyComment: IDReplyComment,
                        isDeleted: isDeleted,
                        body: body,
                        dateCreated: dateCreated,
                        dateUpdated: dateUpdated
                    )
                }
        }
    }
}

