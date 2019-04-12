import Foundation
import LGNCore
import Entita2FDB
import NIO

public extension Models {
    final class Comment: ModelInt, Entita2FDBIndexedEntity {
        public enum Status: String, Codable {
            /// Freshly posted comment, awaits moderation
            case pending

            /// Published but deleted comment, displayed as "Comment has been deleted"
            case deleted

            /// Published but deleted comment, isn't displayed at all.
            /// All subcomments must be in `.hidden` status as well.
            case hidden

            /// Published but deleted comment because of user ban, should be moved to published after unban
            case banHidden

            /// Published comment
            case published
        }

        #if DEBUG
        #else
        public enum CodingKeys: String, CodingKey {
            case ID = "a"
            case IDUser = "b"
            case IDPost = "c"
            case IDReplyComment = "d"
            case isDeleted = "e"
            case isApproved = "f"
            case body = "g"
            case dateCreated = "h"
            case dateUpdated = "i"
        }
        #endif

        public static let IDKey: KeyPath<Comment, Int> = \.ID
        public static var fullEntityName = false
        
        public static var indices: [String : Entita2.Index<Models.Comment>] = [
            "ID": E2.Index(\.ID, unique: true),
            "user": E2.Index(\.IDUser, unique: false),
        ]

        public let ID: Int
        public let IDUser: User.Identifier
        public let IDPost: Post.Identifier
        public let IDReplyComment: Int?
        public var status: Status
        public var body: String
        public let dateCreated: Date
        public var dateUpdated: Date

        public init(
            ID: Int,
            IDUser: User.Identifier,
            IDPost: Post.Identifier,
            IDReplyComment: Int?,
            body: String
        ) {
            self.ID = ID
            self.IDUser = IDUser
            self.IDPost = IDPost
            self.IDReplyComment = IDReplyComment
            self.status = .pending
            self.body = body
            self.dateCreated = Date()
            self.dateUpdated = .distantPast
        }

        public func getUser(on eventLoop: EventLoop) -> Future<User> {
            return Logic.User
                .get(by: self.IDUser, on: eventLoop)
                .map {
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
        ) -> Future<(Models.Comment?, FDB.Transaction)> {
            return fdb.withTransaction(on: eventLoop) { transaction in
                self
                    .loadByIndex(name: "ID", value: ID, with: transaction, on: eventLoop)
                    .map { maybeComment in (maybeComment, transaction) }
            }
        }

//        public func getIndexIndexSubspace() -> Subspace {
//            return Comment.subspace[Comment.entityName][self.ID]["idx"]
//        }

        // this is extracted because logic would like to use it as range
        public static func _getPostPrefix(_ ID: Post.Identifier) -> FDB.Subspace {
            return self.subspace[Post.entityName][ID][Comment.entityName]
        }

        public func _getFullPrefix() -> FDB.Subspace {
            return Comment._getPostPrefix(self.IDPost)[self.ID]
        }

        public func getIDAsKey() -> Bytes {
            return self._getFullPrefix().asFDBKey()
        }

        public static func await(
            on eventLoop: EventLoop,
            ID IDFuture: Future<Models.Comment.Identifier>,
            IDUser IDUserFuture: Future<User.Identifier>,
            IDPost: Post.Identifier,
            IDReplyComment: Int?,
            body: String
        ) -> Future<Comment> {
            return eventLoop.makeSucceededFuture(())
                .flatMap { () in
                    IDFuture.map { ID in (ID) }
                }
                .flatMap { (ID) in
                    IDUserFuture.map { IDUser in (ID, IDUser) }
                }
                .map { (ID, IDUser) -> (Models.Comment) in
                    Comment(
                        ID: ID,
                        IDUser: IDUser,
                        IDPost: IDPost,
                        IDReplyComment: IDReplyComment,
                        body: body
                    )
                }
        }

        public func beforeSave(with transaction: AnyTransaction?, on eventLoop: EventLoop) -> EventLoopFuture<Void> {
            self.dateUpdated = Date()

            return eventLoop.makeSucceededFuture(())
        }
    }
}

