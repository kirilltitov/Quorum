import Foundation
import Generated
import LGNCore
import LGNC
import Entita2
import FDB
import NIO

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

        public static func get(by ID: Models.Comment.Identifier, on eventLoop: EventLoop) -> EventLoopFuture<Models.Comment?> {
            return Models.Comment.getUsingRefID(by: ID, storage: fdb, on: eventLoop)
        }

        public static func getThrowing(
            by ID: Models.Comment.Identifier,
            on eventLoop: EventLoop
        ) -> EventLoopFuture<Models.Comment> {
            return Models.Comment
                .getUsingRefID(by: ID, storage: fdb, on: eventLoop)
                .mapThrowing { maybeComment in
                    guard let comment = maybeComment else {
                        throw LGNC.ContractError.GeneralError("Comment not found (it should)", 404)
                    }
                    return comment
                }
        }

        public static func getThrowingWithTransaction(
            by ID: Models.Comment.Identifier,
            on eventLoop: EventLoop
        ) -> EventLoopFuture<(Models.Comment, AnyFDBTransaction)> {
            return Models.Comment
                .getUsingRefIDWithTransaction(by: ID, storage: fdb, on: eventLoop)
                .mapThrowing { maybeComment, transaction in
                    guard let comment = maybeComment else {
                        throw LGNC.ContractError.GeneralError("Comment not found (it should)", 404)
                    }
                    return (comment, transaction)
                }
        }

        public static func doExists(ID: Int, on eventLoop: EventLoop) -> EventLoopFuture<Bool> {
            return self
                .get(by: ID, on: eventLoop)
                .map { $0 != nil }
        }

        public static func insert(
            comment: Models.Comment,
            as user: Models.User,
            context: LGNCore.Context
        ) -> EventLoopFuture<Models.Comment> {
            let eventLoop = context.eventLoop
            return eventLoop
                .makeSucceededFuture()
                .flatMapThrowing {
                    if user.isAtLeastModerator {
                        return
                    }
                    let dateLastCommentDiff = Date().timeIntervalSince1970 - user.dateLastComment.timeIntervalSince1970
                    guard dateLastCommentDiff > COMMENT_POST_COOLDOWN_SECONDS else {
                        throw LGNC.ContractError.GeneralError("You're commenting too often".tr(context.locale), 429)
                    }
                }
                .flatMap { _ in comment.insert(storage: fdb, on: eventLoop) }
                .flatMap { Models.PendingComment.savePending(comment: comment, storage: fdb, on: eventLoop) }
                .flatMap {
                    if user.shouldSkipPremoderation {
                        return Logic.Comment
                            .approve(comment: comment, on: eventLoop)
                            .map { _ in Void() }
                    }
                    return eventLoop.makeSucceededFuture()
                }
                .flatMap {
                    user.dateLastComment = .now

                    return user.save(storage: fdb, on: eventLoop)
                }
                .map { comment }
        }

        public static func save(comment: Models.Comment, on eventLoop: EventLoop) -> EventLoopFuture<Models.Comment> {
            return comment
                .save(storage: fdb, on: eventLoop)
                .map { _ in comment }
        }

        public static func getProcessedBody(from string: String) -> String {
            return string
        }

        public static func delete(comment: Models.Comment, on eventLoop: EventLoop) -> EventLoopFuture<Void> {
            comment.status = .deleted

            return comment.save(storage: fdb, on: eventLoop)
        }

        public static func hide(comment: Models.Comment, context: LGNCore.Context) -> EventLoopFuture<Void> {
            let eventLoop = context.eventLoop
            return eventLoop
                .makeSucceededFuture()
                .flatMap { () -> EventLoopFuture<[(ID: Models.Comment.Identifier, value: Models.Comment)]> in
                    Logic.Post.getRawCommentsFor(ID: comment.IDPost, on: eventLoop)
                }
                .mapThrowing { comments in
                    for (_, _comment) in comments {
                        if _comment.IDReplyComment == comment.ID && _comment.status == .published {
                            throw LGNC.ContractError.GeneralError(
                                "Cannot hide comment, it has parent published comment".tr(context.locale),
                                401
                            )
                        }
                    }
                }
                .flatMap {
                    comment.status = .hidden

                    return comment.save(storage: fdb, on: eventLoop)
                }
                .flatMap { Logic.Post.decrementCommentCounterForPost(ID: comment.IDPost, on: eventLoop) }
        }

        public static func unhide(comment: Models.Comment, context: LGNCore.Context) -> EventLoopFuture<Void> {
            let eventLoop = context.eventLoop
            return eventLoop
                .makeSucceededFuture()
                .flatMapThrowing {
                    guard comment.status == .hidden else {
                        throw LGNC.ContractError.GeneralError(
                            "Cannot unhide comment, it should be in 'hidden' state".tr(context.locale),
                            401
                        )
                    }
                    
                    comment.status = .published
                    
                    return comment.save(storage: fdb, on: eventLoop)
                }
                .flatMap { Logic.Post.incrementCommentCounterForPost(ID: comment.IDPost, on: eventLoop) }
        }

        public static func undelete(
            comment: Models.Comment,
            on eventLoop: EventLoop
        ) -> EventLoopFuture<Models.Comment> {
            comment.status = .published

            return comment
                .save(storage: fdb, on: eventLoop)
                .map { _ in comment }
        }

        public static func likeOrUnlike(
            comment: Models.Comment,
            by currentUser: Models.User,
            context: LGNCore.Context
        ) -> EventLoopFuture<Int> {
            guard comment.status == .published else {
                context.logger.info("Comment is not published, cannot like or unlike")
                return context.eventLoop.makeSucceededFuture(0)
            }

            guard comment.IDUser != currentUser.ID else {
                context.logger.info("Cannot like own comment")
                return Models.Like.getLikesFor(comment: comment, on: context.eventLoop)
            }

            return Models.Like.likeOrUnlike(comment: comment, by: currentUser, on: context.eventLoop)
        }

        public static func edit(
            comment: Models.Comment,
            body: String,
            by user: Models.User,
            within transaction: AnyFDBTransaction,
            on eventLoop: EventLoop
        ) -> EventLoopFuture<Models.Comment> {
            let newBody = Logic.Comment.getProcessedBody(from: body)
            let oldBody = comment.body

            if newBody == oldBody {
                return eventLoop.makeSucceededFuture(comment)
            }

            comment.body = newBody

            let future: EventLoopFuture<Void> = comment
                .save(commit: false, within: transaction, storage: fdb, on: eventLoop)
                .flatMap { _ in
                    Models.Comment.History.log(
                        comment: comment,
                        newBody: newBody,
                        oldBody: oldBody,
                        by: user,
                        within: transaction,
                        on: eventLoop
                    )
                }
                .flatMap { (_: Void) -> EventLoopFuture<Void> in transaction.commit() }

            return future.map { comment }
        }

        public static func approve(comment: Models.Comment, on eventLoop: EventLoop) -> EventLoopFuture<Models.Comment> {
            guard comment.status == .pending else {
                return eventLoop.makeSucceededFuture(comment)
            }

            comment.status = .published

            return comment
                .save(storage: fdb, on: eventLoop)
                .flatMap { Models.PendingComment.clearRoutine(comment: comment, storage: fdb, on: eventLoop) }
                .flatMap { Logic.Post.incrementCommentCounterForPost(ID: comment.IDPost, on: eventLoop) }
                .map { comment }
        }

        public static func reject(comment: Models.Comment, on eventLoop: EventLoop) -> EventLoopFuture<Void> {
            guard comment.status == .pending else {
                return eventLoop.makeFuture()
            }

            return comment
                .delete(storage: fdb, on: eventLoop)
                .flatMap { Models.PendingComment.clearRoutine(comment: comment, storage: fdb, on: eventLoop) }
        }
    }
}
