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
        ) -> Future<(Models.Comment, Transaction)> {
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
            return comment
                .insert(on: eventLoop)
                .then { _ -> Future<Void> in
                    if user.isAtLeastModerator {
                        return eventLoop.newSucceededFuture(result: ())
                    }
                    return Models.UnapprovedComment.saveUnapproved(comment: comment, on: eventLoop)
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
        
        public static func delete(
            commentID: Models.Comment.Identifier,
            on eventLoop: EventLoop
        ) -> Future<Void> {
            return self
                .getThrowing(by: commentID, on: eventLoop)
                .then { comment in
                    comment.isDeleted = true
                    return comment.save(on: eventLoop)
                }
        }

        public static func undelete(
            commentID: Models.Comment.Identifier,
            on eventLoop: EventLoop
        ) -> Future<Void> {
            return self
                .getThrowing(by: commentID, on: eventLoop)
                .then { comment in
                    comment.isDeleted = false
                    return comment.save(on: eventLoop)
                }
        }
        
        public static func likeOrUnlike(
            comment: Models.Comment,
            by user: Models.User,
            on eventLoop: EventLoop
        ) -> Future<Int> {
            guard comment.isDeleted == false && comment.isApproved == true else {
                return eventLoop.newSucceededFuture(result: 0)
            }
            return Models.Like.likeOrUnlike(comment: comment, by: user, on: eventLoop)
        }
        
        public static func edit(
            comment: Models.Comment,
            body: String,
            with transaction: Transaction,
            on eventLoop: EventLoop
        ) -> Future<Models.Comment> {
            comment.body = Logic.Comment.getProcessedBody(from: body)

            return comment
                .save(with: transaction, on: eventLoop)
                .then { transaction in transaction.commit() }
                .map { _ in comment }
        }

        public static func approve(comment: Models.Comment, on eventLoop: EventLoop) -> Future<Models.Comment> {
            guard !comment.isApproved else {
                return eventLoop.newSucceededFuture(result: comment)
            }

            comment.isApproved = true

            return comment
                .save(on: eventLoop)
                .then { Models.UnapprovedComment.clearRoutine(comment: comment, on: eventLoop) }
                .map { _ in comment }
        }

        public static func reject(comment: Models.Comment, on eventLoop: EventLoop) -> Future<Void> {
            guard !comment.isApproved else {
                return eventLoop.newSucceededFuture(result: ())
            }

            return comment
                .delete(on: eventLoop)
                .then { Models.UnapprovedComment.clearRoutine(comment: comment, on: eventLoop) }
        }
    }
}
