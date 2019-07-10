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

        public static func get(by ID: Models.Comment.Identifier, on eventLoop: EventLoop) -> Future<Models.Comment?> {
            return Models.Comment.getUsingRefID(by: ID, on: eventLoop)
        }

        public static func getThrowing(
            by ID: Models.Comment.Identifier,
            on eventLoop: EventLoop
        ) -> Future<Models.Comment> {
            return Models.Comment
                .getUsingRefID(by: ID, on: eventLoop)
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
        ) -> Future<(Models.Comment, FDB.Transaction)> {
            return Models.Comment
                .getUsingRefIDWithTransaction(by: ID, on: eventLoop)
                .mapThrowing { maybeComment, transaction in
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

        public static func insert(
            comment: Models.Comment,
            as user: Models.User,
            on eventLoop: EventLoop
        ) -> Future<Models.Comment> {
            return comment
                .insert(on: eventLoop)
                .flatMap { Models.PendingComment.savePending(comment: comment, on: eventLoop) }
                .flatMap {
                    if user.isAtLeastModerator {
                        return Logic.Comment
                            .approve(comment: comment, on: eventLoop)
                            .map { _ in Void() }
                    }
                    return eventLoop.makeSucceededFuture()
                }
                .map { comment }
        }

        public static func save(comment: Models.Comment, on eventLoop: EventLoop) -> Future<Models.Comment> {
            return comment
                .save(on: eventLoop)
                .map { _ in comment }
        }

        public static func getProcessedBody(from string: String) -> String {
            return string
        }

        public static func delete(comment: Models.Comment, on eventLoop: EventLoop) -> Future<Void> {
            comment.status = .deleted

            return comment.save(on: eventLoop)
        }

        public static func hide(comment: Models.Comment, on eventLoop: EventLoop) -> Future<Void> {
            return eventLoop
                .makeSucceededFuture()
                .flatMap { () -> Future<[(ID: Models.Comment.Identifier, value: Models.Comment)]> in
                    Logic.Post.getRawCommentsFor(ID: comment.IDPost, on: eventLoop)
                }
                .mapThrowing { comments in
                    for (_, _comment) in comments {
                        if _comment.IDReplyComment == comment.ID && _comment.status == .published {
                            throw LGNC.ContractError.GeneralError(
                                "Cannot hide comment, it has parent published comment",
                                401
                            )
                        }
                    }
                }
                .flatMap {
                    comment.status = .hidden

                    return comment.save(on: eventLoop)
                }
                .flatMap { Logic.Post.decrementCommentCounterForPost(ID: comment.IDPost, on: eventLoop) }
        }

        public static func unhide(comment: Models.Comment, on eventLoop: EventLoop) -> Future<Void> {
            return eventLoop
                .makeSucceededFuture()
                .flatMapThrowing {
                    guard comment.status == .hidden else {
                        throw LGNC.ContractError.GeneralError(
                            "Cannot unhide comment, it should be in 'hidden' state",
                            401
                        )
                    }
                    
                    comment.status = .published
                    
                    return comment.save(on: eventLoop)
                }
                .flatMap { Logic.Post.incrementCommentCounterForPost(ID: comment.IDPost, on: eventLoop) }
        }

        public static func undelete(
            comment: Models.Comment,
            on eventLoop: EventLoop
        ) -> Future<Models.Comment> {
            comment.status = .published

            return comment
                .save(on: eventLoop)
                .map { _ in comment }
        }

        public static func likeOrUnlike(
            comment: Models.Comment,
            by user: Models.User,
            on eventLoop: EventLoop
        ) -> Future<Int> {
            guard comment.status == .published else {
                return eventLoop.makeSucceededFuture(0)
            }
            guard comment.IDUser != user.ID else {
                return Models.Like.getLikesFor(comment: comment, on: eventLoop)
            }

            return Models.Like.likeOrUnlike(comment: comment, by: user, on: eventLoop)
        }

        public static func edit(
            comment: Models.Comment,
            body: String,
            within transaction: FDB.Transaction,
            on eventLoop: EventLoop
        ) -> Future<Models.Comment> {
            comment.body = Logic.Comment.getProcessedBody(from: body)

            return comment
                .save(within: transaction, on: eventLoop)
                .map { comment }
        }

        public static func approve(comment: Models.Comment, on eventLoop: EventLoop) -> Future<Models.Comment> {
            guard comment.status == .pending else {
                return eventLoop.makeSucceededFuture(comment)
            }

            comment.status = .published

            return comment
                .save(on: eventLoop)
                .flatMap { Models.PendingComment.clearRoutine(comment: comment, on: eventLoop) }
                .flatMap { Logic.Post.incrementCommentCounterForPost(ID: comment.IDPost, on: eventLoop) }
                .map { comment }
        }

        public static func reject(comment: Models.Comment, on eventLoop: EventLoop) -> Future<Void> {
            guard comment.status == .pending else {
                return eventLoop.makeFuture()
            }

            return comment
                .delete(on: eventLoop)
                .flatMap { Models.PendingComment.clearRoutine(comment: comment, on: eventLoop) }
        }
    }
}
