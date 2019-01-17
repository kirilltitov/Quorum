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
        
        public static func insert(comment: Models.Comment, on eventLoop: EventLoop) -> Future<Models.Comment> {
            return comment.insert(on: eventLoop).map { _ in comment }
        }
        
        public static func save(comment: Models.Comment, on eventLoop: EventLoop) -> Future<Models.Comment> {
            return comment.save(on: eventLoop).map { _ in comment }
        }
        
        public static func getProcessedBody(from string: String) -> String {
            return string
        }
        
        public static func delete(
            commentID: Models.Comment.Identifier,
            on eventLoop: EventLoop
        ) -> Future<Void> {
            return self
                .get(by: commentID, on: eventLoop)
                .then {
                    guard let comment = $0 else {
                        return eventLoop.newSucceededFuture(result: ())
                    }
                    return fdb
                        .begin(eventLoop: eventLoop)
                        .then { $0.clear(key: comment.getIDAsKey()) }
                        .then { $0.clear(key: Models.Comment.refID.getIndexKey(from: comment.ID)) }
                        .then { $0.commit() }
            }
        }
        
        public static func like(
            comment: Models.Comment,
            by user: Models.User,
            on eventLoop: EventLoop
        ) -> Future<Int> {
            return Models.Like.like(comment: comment, by: user, on: eventLoop)
        }
        
        public static func edit(
            comment: Models.Comment,
            body: String,
            with transaction: Transaction,
            on eventLoop: EventLoop
        ) -> Future<Models.Comment> {
            comment.body = Logic.Comment.getProcessedBody(from: body)
            comment.dateUpdated = Date()
            
            return comment
                .save(with: transaction, on: eventLoop)
                .then { transaction in transaction.commit() }
                .map { _ in comment }
        }
    }
}
