import Foundation
import Generated
import LGNC
import Entita2
import FDB
import NIO

public extension Logic {
    public class Comment {
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
        
        public static func insert(
            comment: Models.Comment,
            as user: Models.User,
            on eventLoop: EventLoop
        ) -> Future<Models.Comment> {
            if user.isAtLeastModerator {
                comment.status = .published
            }

            return comment
                .insert(on: eventLoop)
                .then { _ -> Future<Void> in
                    if user.isAtLeastModerator {
                        return eventLoop.newSucceededFuture(result: ())
                    }
                    return Models.PendingComment.savePending(comment: comment, on: eventLoop)
                }
                .map { _ in comment }
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
            return eventLoop.newSucceededFuture(result: ())
                .then { () -> EventLoopFuture<Models.Comment?> in
                    guard let IDReplyComment = comment.IDReplyComment else {
                        return eventLoop.newSucceededFuture(result: nil)
                    }
                    return self.get(by: IDReplyComment, on: eventLoop)
                }
                .flatMapThrowing { (maybeParentComment: Models.Comment?) in
                    if let parentComment = maybeParentComment, parentComment.status == .published {
                        throw LGNC.ContractError.GeneralError(
                            "Cannot hide comment, it has parent published comment",
                            401
                        )
                    }

                    comment.status = .hidden

                    return comment.save(on: eventLoop)
                }
        }

        public static func undelete(
            comment: Models.Comment,
            on eventLoop: EventLoop
        ) -> Future<Void> {
            comment.status = .published

            return comment.save(on: eventLoop)
        }
        
        public static func likeOrUnlike(
            comment: Models.Comment,
            by user: Models.User,
            on eventLoop: EventLoop
        ) -> Future<Int> {
            guard comment.status == .published else {
                return eventLoop.newSucceededFuture(result: 0)
            }
            return Models.Like.likeOrUnlike(comment: comment, by: user, on: eventLoop)
        }
        
        public static func edit(
            comment: Models.Comment,
            body: String,
            with transaction: FDB.Transaction,
            on eventLoop: EventLoop
        ) -> Future<Models.Comment> {
            comment.body = Logic.Comment.getProcessedBody(from: body)

            return comment
                .save(with: transaction, on: eventLoop)
                .then { transaction in transaction.commit() }
                .map { _ in comment }
        }

        public static func approve(comment: Models.Comment, on eventLoop: EventLoop) -> Future<Models.Comment> {
            guard comment.status == .pending else {
                return eventLoop.newSucceededFuture(result: comment)
            }

            comment.status = .published

            return comment
                .save(on: eventLoop)
                .then { Models.PendingComment.clearRoutine(comment: comment, on: eventLoop) }
                .map { _ in comment }
        }

        public static func reject(comment: Models.Comment, on eventLoop: EventLoop) -> Future<Void> {
            guard comment.status == .pending else {
                return eventLoop.newSucceededFuture(result: ())
            }

            return comment
                .delete(on: eventLoop)
                .then { Models.PendingComment.clearRoutine(comment: comment, on: eventLoop) }
        }
    }
}
