import Foundation
import LGNCore
import LGNC
import Entita2FDB
import NIO
import Generated

extension Date {
    func contractFormatted(locale: LGNCore.i18n.Locale) -> String {
        return Logic.Comment.format(date: self, locale: locale)
    }
}

public extension Models {
    final class Comment: ModelInt, Entita2FDBIndexedEntity {
        public enum IndexKey: String, AnyIndexKey {
            case ID, user
        }

        public enum Status: String, Codable {
            /// Freshly posted comment, awaits moderation
            case pending

            /// Published but deleted comment, displayed as "Comment has been deleted"
            case deleted

            /// Published but deleted comment, isn't displayed at all for everyone except author
            /// All subcomments must be in `.hidden` status as well.
            case hidden

            /// Published but deleted comment because of user ban, should be moved to published after unban
            case banHidden

            /// Published comment
            case published
        }

        public static let IDKey: KeyPath<Comment, Int> = \.ID
        public static var fullEntityName = false

        public static var indices: [IndexKey: Entita2.Index<Models.Comment>] = [
            .ID: E2.Index(\.ID, unique: true),
            .user: E2.Index(\.IDUser, unique: false),
        ]

        public let ID: Int
        public let IDUser: User.Identifier
        public let IDPost: Post.Identifier
        public let IDReplyComment: Int?
        public var status: Status
        public var body: String
        public let dateCreated: Date
        public var dateUpdated: Date

        public var isEditable: Bool {
            return self.dateCreated.timeIntervalSince < COMMENT_EDITABLE_TIME_SECONDS
        }

        public var IDPostEncoded: String {
            return Logic.Post.encodeHash(ID: self.IDPost)
        }

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
            self.dateCreated = .now
            self.dateUpdated = .distantPast
        }

        public func getUser(context: LGNCore.Context) -> Future<User> {
            return Logic.User
                .get(by: self.IDUser, context: context)
                .map {
                    guard let user = $0 else {
                        return User.unknown
                    }
                    return user
                }
        }

        public func getContractComment(
            loadLikes: Bool = true,
            context: Context
        ) -> Future<Services.Shared.Comment> {
            let eventLoop = context.eventLoop
            let user = self.getUser(context: context)

            // TODO proper await
            return user.flatMap { user in
                Services.Shared.Comment.await(
                    ID: self.ID,
                    user: Services.Shared.CommentUserInfo(
                        ID: user.ID.string,
                        username: user.username,
                        accessLevel: user.accessLevel.rawValue
                    ),
                    IDPost: self.IDPostEncoded,
                    IDReplyComment: self.IDReplyComment,
                    isEditable: self.isEditable,
                    status: self.status.rawValue,
                    body: self.status == .deleted ? "" : self.body,
                    likes: loadLikes ? Like.getLikesFor(comment: self, on: eventLoop) : eventLoop.makeSucceededFuture(0),
                    dateCreated: self.dateCreated.contractFormatted(locale: context.locale),
                    dateUpdated: self.dateUpdated.contractFormatted(locale: context.locale)
                )
            }
        }

        public static func getUsingRefID(
            by ID: Comment.Identifier,
            on eventLoop: EventLoop
        ) -> Future<Models.Comment?> {
            return self.loadByIndex(key: .ID, value: ID, on: eventLoop)
        }

        public static func getUsingRefIDWithTransaction(
            by ID: Comment.Identifier,
            on eventLoop: EventLoop
        ) -> Future<(Models.Comment?, AnyFDBTransaction)> {
            return fdb.withTransaction(on: eventLoop) { transaction in
                self
                    .loadByIndex(key: .ID, value: ID, within: transaction, on: eventLoop)
                    .map { maybeComment in (maybeComment, transaction) }
            }
        }

//        public func getIndexIndexSubspace() -> Subspace {
//            return Comment.subspace[Comment.entityName][self.ID]["idx"]
//        }

        // this is extracted because logic would like to use it as range
        public static func _getPrefix() -> FDB.Subspace {
            return self.subspace[Post.entityName]
        }

        public static func _getPostPrefix(_ ID: Post.Identifier) -> FDB.Subspace {
            return self._getPrefix()[ID][Comment.entityName]
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
            IDPost: String,
            IDReplyComment: Int?,
            body: String
        ) -> Future<Comment> {
            guard let IDPost = Logic.Post.decodeHash(ID: IDPost) else {
                return eventLoop.makeFailedFuture(LGNC.ContractError.GeneralError("Invalid post ID", 400))
            }

            return eventLoop.makeSucceededFuture()
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

        public func beforeSave(within transaction: AnyTransaction?, on eventLoop: EventLoop) -> EventLoopFuture<Void> {
            self.dateUpdated = .now

            return eventLoop.makeSucceededFuture(())
        }

        final class History: ModelInt {
            public static let IDKey: KeyPath<History, Int> = \.ID
            public static var fullEntityName = false

            public let ID: History.Identifier
            public let IDComment: Models.Comment.Identifier
            public let IDUser: Models.User.Identifier
            public let oldBody: String
            public let newBody: String
            public let date: Date = .now

            public init(
                ID: History.Identifier,
                IDComment: Models.Comment.Identifier,
                IDUser: Models.User.Identifier,
                oldBody: String,
                newBody: String
            ) {
                self.ID = ID
                self.IDComment = IDComment
                self.IDUser = IDUser
                self.oldBody = oldBody
                self.newBody = newBody
            }

            public static func log(
                comment: Models.Comment,
                newBody: String,
                oldBody: String,
                by user: Models.User,
                within transaction: AnyFDBTransaction,
                on eventLoop: EventLoop
            ) -> Future<Void> {
                return History
                    .getNextID(commit: false, within: transaction)
                    .map { (ID: Int) -> History in
                        History(ID: ID, IDComment: comment.ID, IDUser: user.ID, oldBody: oldBody, newBody: newBody)
                    }
                    .flatMap { model in model.save(commit: false, within: transaction, on: eventLoop) }
            }

            public func getIDAsKey() -> Bytes {
                return History.subspacePrefix[self.IDComment, self.ID].asFDBKey()
            }
        }
    }
}
