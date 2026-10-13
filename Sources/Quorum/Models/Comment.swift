import Foundation
import LGNCore
import LGNC
import FDB
import FDBEntity
import Generated

extension Date {
    func contractFormatted() -> String {
        Logic.Comment.format(date: self, locale: LGNCore.Context.current.locale)
    }
}

public extension Models {
    struct Comment: ModelInt, FDB.IndexedEntity, Sendable {
        public enum IndexKey: String, FDB.EntityIndexKey {
            case ID, user
        }

        public enum Status: String, Codable, Sendable {
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

        public static var IDKey: KeyPath<Comment, Int> { \.ID }

        public static let indices: [IndexKey: FDB.EntityIndex<Models.Comment>] = [
            .ID: FDB.EntityIndex(\.ID, unique: true),
            .user: FDB.EntityIndex(\.IDUser, unique: false),
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
            Date().timeIntervalSince(self.dateCreated) < App.COMMENT_EDITABLE_TIME_SECONDS
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
            self.dateCreated = Date()
            self.dateUpdated = .distantPast
        }

        public func getUser() async throws -> User {
            try await Logic.User.get(by: self.IDUser) ?? User.unknown
        }

        public func getContractComment(likes: Int? = nil) async throws -> Services.Shared.Comment {
            let user = try await self.getUser()
            let likes = if let likes { likes } else { try await Like.getLikesFor(comment: self) }

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
                likes: likes,
                dateCreated: self.dateCreated.contractFormatted(),
                dateUpdated: self.dateUpdated.contractFormatted()
            )
        }

        public static func get(
            by ID: Comment.Identifier,
            within transaction: borrowing FDB.Transaction
        ) async throws -> Models.Comment? {
            try await self.loadByIndex(key: .ID, value: ID, within: transaction)
        }

        public static func get(by ID: Comment.Identifier) async throws -> Models.Comment? {
            try await self.loadByIndex(key: .ID, value: ID)
        }

        /// Comments are stored under their posts: `Post / <post ID> / Comment / <comment ID>`
        public static func _getPrefix() -> FDB.Subspace {
            self.subspace[Post.entityName]
        }

        public static func _getPostPrefix(_ ID: Post.Identifier) -> FDB.Subspace {
            self._getPrefix()[ID][Comment.entityName]
        }

        public func getIDAsKey() -> Bytes {
            Comment._getPostPrefix(self.IDPost)[self.ID].prefix
        }

        /// Saves the comment, updating its modification date
        public mutating func touchAndSave(within transaction: borrowing FDB.Transaction) async throws {
            self.dateUpdated = Date()
            try await self.save(within: transaction)
        }

        struct History: ModelInt, Sendable {
            public static var IDKey: KeyPath<History, Int> { \.ID }

            public let ID: History.Identifier
            public let IDComment: Models.Comment.Identifier
            public let IDUser: Models.User.Identifier
            public let oldBody: String
            public let newBody: String
            public let date: Date

            public static func log(
                comment: Models.Comment,
                newBody: String,
                oldBody: String,
                by user: Models.User,
                within transaction: borrowing FDB.Transaction
            ) async throws {
                try await History(
                    ID: try await History.getNextID(within: transaction),
                    IDComment: comment.ID,
                    IDUser: user.ID,
                    oldBody: oldBody,
                    newBody: newBody,
                    date: Date()
                ).save(within: transaction)
            }

            public func getIDAsKey() -> Bytes {
                History.subspacePrefix[self.IDComment, self.ID].prefix
            }
        }
    }
}
