import NIO
import Entita2FDB

// not to be created at all
public extension Models {
    final public class PendingComment: ModelInt {
        public static var IDKey: KeyPath<PendingComment, Int> = \.ID

        public static var fullEntityName = false

        private static let counterSubspace = subspaceMain["cnt"]["unapproved"]

        public let ID: Int

        fileprivate init(ID: Int) {
            self.ID = ID
        }

        public static func savePending(comment: Models.Comment, on eventLoop: EventLoop) -> Future<Void> {
            return self.storage.withTransaction(on: eventLoop) { transaction in
                transaction
                    .set(key: self.IDAsKey(ID: comment.ID), value: comment.getIDAsKey())
                    .then { self.incrementUnapproved(with: $0) }
                    .then { $0.commit() }
            }
        }

        public static func clearRoutine(comment: Models.Comment, on eventLoop: EventLoop) -> Future<Void> {
            return self.storage.withTransaction(on: eventLoop) { transaction in
                transaction
                    .clear(key: self.IDAsKey(ID: comment.ID))
                    .then { self.decrementUnapproved(with: $0) }
                    .then { $0.commit() }
            }
        }

        private static func incrementUnapproved(with transaction: FDB.Transaction) -> Future<FDB.Transaction> {
            return transaction.atomic(.add, key: self.counterSubspace, value: Int(1))
        }

        private static func decrementUnapproved(with transaction: FDB.Transaction) -> Future<FDB.Transaction> {
            return transaction.atomic(.add, key: self.counterSubspace, value: Int(-1))
        }

        public static func getUnapprovedComments(on eventLoop: EventLoop) -> Future<[Models.Comment]> {
            return self.storage.withTransaction(on: eventLoop) { transaction in
                transaction
                    .get(range: self.subspacePrefix.range)
                    .then { (results, _) -> Future<[Models.Comment?]> in
                        Future.reduce(
                            into: [],
                            results.records.map { kv in Models.Comment.loadByRaw(IDBytes: kv.value, on: eventLoop) },
                            eventLoop: eventLoop
                        ) { $0.append($1) }
                    }
                    .map { comments in comments.compactMap { $0 } }
            }
        }

        public static func getCommentID(from tuple: FDB.Tuple) -> Models.Comment.Identifier? {
            guard tuple.tuple.count >= 3 else {
                return nil
            }
            guard let value = tuple.tuple[tuple.tuple.count - 3] as? Models.Comment.Identifier else {
                return nil
            }
            return value
        }


    }
}
