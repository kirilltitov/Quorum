import Foundation
import Generated
import LGNCore
import LGNC
import Entita2
import FDB

public extension Logic {
    enum Comment {
        fileprivate static let defaultFormatter: DateFormatter = {
            let formatter = DateFormatter()

//            formatter.dateStyle = .long
//            formatter.timeStyle = .short
            formatter.dateFormat = "dd.MM.yyyy, HH:mm"
            formatter.locale = LGNCore.i18n.Locale.enUS.foundationLocale

            return formatter
        }()

        fileprivate static let formatters: [LGNCore.i18n.Locale: DateFormatter] = .init(
            uniqueKeysWithValues: Array<LGNCore.i18n.Locale>([.enUS, .ruRU]).map { locale in
                let formatter = DateFormatter()
//                formatter.dateStyle = .long
//                formatter.timeStyle = .short
                formatter.dateFormat = "dd.MM.yyyy, HH:mm"
                formatter.locale = locale.foundationLocale

                return (locale, formatter)
            }
        )

        public static func format(date: Date, locale: LGNCore.i18n.Locale) -> String {
            return (self.formatters[locale] ?? defaultFormatter).string(from: date)
        }

        public static func get(by ID: Models.Comment.Identifier) async throws -> Models.Comment? {
            try await Models.Comment.getUsingRefID(by: ID)
        }

        public static func getThrowing(
            by ID: Models.Comment.Identifier,
            within maybeTransaction: AnyFDBTransaction? = nil
        ) async throws -> Models.Comment {
            guard let comment = try await Models.Comment.getUsingRefID(by: ID, within: maybeTransaction) else {
                throw LGNC.ContractError.GeneralError("Comment not found (it should)", 404)
            }
            return comment
        }

        public static func doExists(ID: Int) async throws -> Bool {
            try await self.get(by: ID) != nil
        }

        public static func insert(comment: Models.Comment, as user: Models.User) async throws {
            let dateLastCommentDiff = Date().timeIntervalSince1970 - user.dateLastComment.timeIntervalSince1970
            guard user.isAtLeastModerator || dateLastCommentDiff > App.COMMENT_POST_COOLDOWN_SECONDS else {
                throw LGNC.ContractError.GeneralError("You're commenting too often".tr(), 429)
            }

            try await comment.insert()

            if user.shouldSkipPremoderation {
                try await Logic.Comment.approve(comment: comment)
            }

            user.dateLastComment = .now
            try await user.save()
        }

        public static func getProcessedBody(from string: String) -> String {
            return string
        }

        public static func delete(comment: Models.Comment) async throws {
            comment.status = .deleted

            try await comment.save()
        }

        public static func hide(comment: Models.Comment) async throws {
            let comments = try await Logic.Post.getRawCommentsFor(ID: comment.IDPost)
            for (_, _comment) in comments {
                if let refID = _comment.IDReplyComment, refID == comment.ID && _comment.status == .published {
                    throw LGNC.ContractError.GeneralError(
                        "Cannot hide comment, it has parent published comment (#\(refID))".tr(),
                        401
                    )
                }
            }
            comment.status = .hidden

            try await comment.save()

            try await Logic.Post.decrementCommentCounterForPost(ID: comment.IDPost)
        }

        public static func unhide(comment: Models.Comment) async throws {
            guard comment.status == .hidden else {
                throw LGNC.ContractError.GeneralError(
                    "Cannot unhide comment, it should be in 'hidden' state".tr(),
                    401
                )
            }

            comment.status = .published

            try await comment.save()

            try await Logic.Post.incrementCommentCounterForPost(ID: comment.IDPost)
        }

        public static func undelete(comment: Models.Comment) async throws {
            comment.status = .published

            try await comment.save()
        }

        public static func likeOrUnlike(comment: Models.Comment, by currentUser: Models.User) async throws -> Int {
            let logger = LGNCore.Context.current.logger

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

        public static func edit(
            comment: Models.Comment,
            body: String,
            by user: Models.User,
            within transaction: AnyFDBTransaction
        ) async throws {
            let newBody = Logic.Comment.getProcessedBody(from: body)
            let oldBody = comment.body

            if newBody == oldBody {
                return
            }

            comment.body = newBody

            try await comment.save(within: transaction, commit: false)
            try await Models.Comment.History.log(
                comment: comment,
                newBody: newBody,
                oldBody: oldBody,
                by: user,
                within: transaction
            )
        }

        public static func approve(comment: Models.Comment) async throws {
            guard comment.status == .pending else {
                return
            }

            comment.status = .published

            try await comment.save()
            try await Models.PendingComment.clearRoutine(comment: comment)
            try await Logic.Post.incrementCommentCounterForPost(ID: comment.IDPost)
        }

        public static func reject(comment: Models.Comment) async throws {
            guard comment.status == .pending else {
                return
            }

            try await comment.delete()
            try await Models.PendingComment.clearRoutine(comment: comment)
        }
    }
}
