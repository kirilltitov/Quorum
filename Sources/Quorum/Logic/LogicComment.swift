import Foundation
import Generated
import LGNCore
import LGNLog
import LGNC
import FDB
import FDBEntity

public extension Logic {
    enum Comment {
        fileprivate static let defaultFormatter: DateFormatter = Self.makeFormatter(locale: .enUS)

        fileprivate static let formatters: [LGNCore.i18n.Locale: DateFormatter] = .init(
            uniqueKeysWithValues: Array<LGNCore.i18n.Locale>([.enUS, .ruRU]).map { ($0, Self.makeFormatter(locale: $0)) }
        )

        private static func makeFormatter(locale: LGNCore.i18n.Locale) -> DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy, HH:mm"
            formatter.locale = locale.foundationLocale
            return formatter
        }

        public static func format(date: Date, locale: LGNCore.i18n.Locale) -> String {
            (self.formatters[locale] ?? defaultFormatter).string(from: date)
        }

        public static func get(by ID: Models.Comment.Identifier) async throws -> Models.Comment? {
            try await Models.Comment.get(by: ID)
        }

        public static func getThrowing(
            by ID: Models.Comment.Identifier,
            within transaction: borrowing FDB.Transaction
        ) async throws -> Models.Comment {
            guard let comment = try await Models.Comment.get(by: ID, within: transaction) else {
                throw LGNC.ContractError.GeneralError("Comment not found", 404)
            }
            return comment
        }

        public static func getThrowing(by ID: Models.Comment.Identifier) async throws -> Models.Comment {
            try await App.current.fdb.withTransaction { transaction in
                try await self.getThrowing(by: ID, within: transaction)
            }
        }

        public static func doExists(ID: Int) async throws -> Bool {
            try await self.get(by: ID) != nil
        }

        public static func getProcessedBody(from string: String) -> String {
            string
        }

        /// Creates a comment: a pending one, or published right away for users skipping premoderation
        public static func create(
            IDPost: Models.Post.Identifier,
            IDReplyComment: Int?,
            body: String,
            as user: Models.User
        ) async throws -> Models.Comment {
            let comment: Models.Comment = try await App.current.fdb.withTransaction { transaction in
                // The user is reloaded within the transaction, so concurrent comments respect the cooldown
                guard var user = try await Models.User.load(by: user.ID, within: transaction) else {
                    throw LGNC.ContractError.GeneralError("User not found", 403)
                }
                let sinceLastComment = Date().timeIntervalSince(user.dateLastComment)
                guard user.isAtLeastModerator || sinceLastComment > App.COMMENT_POST_COOLDOWN_SECONDS else {
                    throw LGNC.ContractError.GeneralError("You're commenting too often".tr(), 429)
                }

                var comment = Models.Comment(
                    ID: try await Models.Comment.getNextID(within: transaction),
                    IDUser: user.ID,
                    IDPost: IDPost,
                    IDReplyComment: IDReplyComment,
                    body: self.getProcessedBody(from: body)
                )
                if user.shouldSkipPremoderation {
                    comment.status = .published
                    comment.dateUpdated = Date()
                    try await comment.insert(within: transaction)
                    Logic.Post.updateCommentCounterForPost(ID: IDPost, by: 1, within: transaction)
                } else {
                    try await comment.insert(within: transaction)
                    Models.PendingComment.savePending(comment: comment, within: transaction)
                }

                user.dateLastComment = Date()
                try await user.save(within: transaction)

                return comment
            }
            await Logic.User.invalidate(ID: user.ID)
            return comment
        }

        /// Loads the comment, checks it and changes it in a single transaction, returns the changed comment
        private static func modify(
            ID: Models.Comment.Identifier,
            _ body: (inout Models.Comment, borrowing FDB.Transaction) async throws -> Void
        ) async throws -> Models.Comment {
            try await App.current.fdb.withTransaction { transaction in
                var comment = try await self.getThrowing(by: ID, within: transaction)
                try await body(&comment, transaction)
                return comment
            }
        }

        public static func delete(ID: Models.Comment.Identifier, by user: Models.User) async throws {
            _ = try await self.modify(ID: ID) { comment, transaction in
                guard comment.IDUser == user.ID || user.isAtLeastModerator else {
                    throw LGNC.ContractError.GeneralError("You have no authority to delete this comment", 403)
                }
                guard comment.status == .published else {
                    throw LGNC.ContractError.GeneralError("Comment is not in deleteable status", 400)
                }
                comment.status = .deleted
                try await comment.touchAndSave(within: transaction)
            }
        }

        public static func undelete(ID: Models.Comment.Identifier) async throws -> Models.Comment {
            try await self.modify(ID: ID) { comment, transaction in
                guard comment.status == .deleted else {
                    throw LGNC.ContractError.GeneralError("Cannot undelete comment from non-deleted status", 401)
                }
                comment.status = .published
                try await comment.touchAndSave(within: transaction)
            }
        }

        public static func hide(ID: Models.Comment.Identifier) async throws {
            _ = try await self.modify(ID: ID) { comment, transaction in
                guard comment.status == .published else {
                    throw LGNC.ContractError.GeneralError("Comment is not in hideable status", 400)
                }
                let comments = try await Logic.Post.getRawCommentsFor(ID: comment.IDPost, within: transaction)
                for reply in comments where reply.IDReplyComment == comment.ID && reply.status == .published {
                    throw LGNC.ContractError.GeneralError(
                        "Cannot hide comment, it has parent published comment (#\(reply.ID))".tr(),
                        401
                    )
                }
                comment.status = .hidden
                try await comment.touchAndSave(within: transaction)
                Logic.Post.updateCommentCounterForPost(ID: comment.IDPost, by: -1, within: transaction)
            }
        }

        public static func unhide(ID: Models.Comment.Identifier) async throws {
            _ = try await self.modify(ID: ID) { comment, transaction in
                guard comment.status == .hidden else {
                    throw LGNC.ContractError.GeneralError("Cannot unhide comment, it should be in 'hidden' state".tr(), 401)
                }
                comment.status = .published
                try await comment.touchAndSave(within: transaction)
                Logic.Post.updateCommentCounterForPost(ID: comment.IDPost, by: 1, within: transaction)
            }
        }

        public static func approve(ID: Models.Comment.Identifier) async throws -> Models.Comment {
            try await self.modify(ID: ID) { comment, transaction in
                guard comment.status == .pending else {
                    return
                }
                comment.status = .published
                try await comment.touchAndSave(within: transaction)
                try await Models.PendingComment.clear(comment: comment, within: transaction)
                Logic.Post.updateCommentCounterForPost(ID: comment.IDPost, by: 1, within: transaction)
            }
        }

        public static func reject(ID: Models.Comment.Identifier) async throws {
            _ = try await self.modify(ID: ID) { comment, transaction in
                guard comment.status == .pending else {
                    return
                }
                try await comment.delete(within: transaction)
                try await Models.PendingComment.clear(comment: comment, within: transaction)
            }
        }

        public static func likeOrUnlike(comment: Models.Comment, by currentUser: Models.User) async throws -> Int {
            let logger = Logger.current

            guard comment.status == .published else {
                logger.info("Comment is not published, cannot like or unlike")
                return 0
            }

            guard comment.IDUser != currentUser.ID else {
                logger.info("Cannot like own comment")
                return try await Models.Like.getLikesFor(comment: comment)
            }

            return try await Models.Like.likeOrUnlike(comment: comment, by: currentUser)
        }

        public static func edit(ID: Models.Comment.Identifier, body: String, by user: Models.User) async throws -> Models.Comment {
            if !user.isAtLeastModerator {
                // Checked before the transaction, as it's a remote call
                let IDPost = try await self.getThrowing(by: ID).IDPost
                guard await Logic.Post.getPostStatus(IDPost) != .NotCommentable else {
                    throw LGNC.ContractError.GeneralError("Comment is not editable anymore".tr(), 403)
                }
            }

            return try await self.modify(ID: ID) { comment, transaction in
                if !user.isAtLeastModerator {
                    guard user.ID == comment.IDUser else {
                        throw LGNC.ContractError.GeneralError("It's not your comment".tr(), 403)
                    }
                    guard comment.isEditable else {
                        throw LGNC.ContractError.GeneralError("This comment is not editable anymore".tr(), 408)
                    }
                    guard Date().timeIntervalSince(comment.dateUpdated) > App.COMMENT_EDIT_COOLDOWN_SECONDS else {
                        throw LGNC.ContractError.GeneralError("You're editing too often".tr(), 429)
                    }
                }

                let newBody = self.getProcessedBody(from: body)
                let oldBody = comment.body
                guard newBody != oldBody else {
                    return
                }

                comment.body = newBody
                try await comment.touchAndSave(within: transaction)
                try await Models.Comment.History.log(
                    comment: comment,
                    newBody: newBody,
                    oldBody: oldBody,
                    by: user,
                    within: transaction
                )
            }
        }
    }
}
