import Foundation
import LGNCore
import LGNC
import Entita2FDB
import Generated

extension Date {
    func contractFormatted() -> String {
        Logic.Comment.format(date: self, locale: LGNCore.Context.current.locale)
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
        public static var storage = App.current.fdb

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
            self.dateCreated.timeIntervalSince < App.COMMENT_EDITABLE_TIME_SECONDS
        }

        public var IDPostEncoded: String {
            Logic.Post.encodeHash(ID: self.IDPost)
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

        public func getUser() async throws -> User {
            guard let user = try await Logic.User.get(by: self.IDUser) else {
                return User.unknown
            }
            return user
        }

        public func getContractComment(loadLikes: Bool = true) async throws -> Services.Shared.Comment {
            let user = try await self.getUser()

            return Services.Shared.Comment(
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
                likes: loadLikes ? try await Like.getLikesFor(comment: self) : 0,
                dateCreated: self.dateCreated.contractFormatted(),
                dateUpdated: self.dateUpdated.contractFormatted()
            )
        }

        public static func getUsingRefID(
            by ID: Comment.Identifier,
            within maybeTransaction: AnyFDBTransaction? = nil
        ) async throws -> Models.Comment? {
            try await self.loadByIndex(key: .ID, value: ID, within: maybeTransaction)
        }

//        public func getIndexIndexSubspace() -> Subspace {
//            return Comment.subspace[Comment.entityName][self.ID]["idx"]
//        }

        // this is extracted because logic would like to use it as range
        public static func _getPrefix() -> FDB.Subspace {
            self.subspace[Post.entityName]
        }

        public static func _getPostPrefix(_ ID: Post.Identifier) -> FDB.Subspace {
            self._getPrefix()[ID][Comment.entityName]
        }

        public func _getFullPrefix() -> FDB.Subspace {
            Comment._getPostPrefix(self.IDPost)[self.ID]
        }

        public func getIDAsKey() -> Bytes {
            self._getFullPrefix().asFDBKey()
        }

        public func beforeSave(within transaction: AnyTransaction?) async throws {
            self.dateUpdated = .now
        }

        final class History: ModelInt {
            public static let IDKey: KeyPath<History, Int> = \.ID
            public static var fullEntityName = false
            public static var storage = App.current.fdb

            public let ID: History.Identifier
            public let IDComment: Models.Comment.Identifier
            public let IDUser: Models.User.Identifier
            public let oldBody: String
            public let newBody: String
            public let date: Date

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
                self.date = .now
            }

            public static func log(
                comment: Models.Comment,
                newBody: String,
                oldBody: String,
                by user: Models.User,
                within transaction: AnyFDBTransaction
            ) async throws {
                try await History(
                    ID: try await History.getNextID(commit: false, within: transaction),
                    IDComment: comment.ID,
                    IDUser: user.ID,
                    oldBody: oldBody,
                    newBody: newBody
                ).save(within: transaction, commit: false)
            }

            public func getIDAsKey() -> Bytes {
                History.subspacePrefix[self.IDComment, self.ID].asFDBKey()
            }
        }
    }
}
