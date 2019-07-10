import NIO
import Entita2FDB

// not to be created at all
public extension Models {
    final class PendingComment: ModelInt {
        public static var IDKey: KeyPath<PendingComment, Int> = \.ID

        public static var fullEntityName = false

        private static let counterSubspace = subspaceCounter["unapproved"]

        public let ID: Int

        fileprivate init(ID: Int) {
            self.ID = ID
        }

        public static func savePending(comment: Models.Comment, on eventLoop: EventLoop) -> Future<Void> {
            return self.storage.withTransaction(on: eventLoop) { transaction in
                transaction
                    .set(key: self.IDAsKey(ID: comment.ID), value: comment.getIDAsKey())
                    .flatMap { self.incrementPendingCounter(within: $0) }
                    .flatMap { $0.commit() }
            }
        }

        public static func clearRoutine(comment: Models.Comment, on eventLoop: EventLoop) -> Future<Void> {
            return self.storage.withTransaction(on: eventLoop) { transaction in
                transaction
                    .clear(key: self.IDAsKey(ID: comment.ID))
                    .flatMap { self.decrementPendingCounter(within: $0) }
                    .flatMap { $0.commit() }
            }
        }

        private static func incrementPendingCounter(within transaction: FDB.Transaction) -> Future<FDB.Transaction> {
            return transaction.atomic(.add, key: self.counterSubspace, value: Int(1))
        }

        private static func decrementPendingCounter(within transaction: FDB.Transaction) -> Future<FDB.Transaction> {
            return transaction.atomic(.add, key: self.counterSubspace, value: Int(-1))
        }

        public static func getPendingCount(on eventLoop: EventLoop) -> Future<Int> {
            return self.storage
                .withTransaction(on: eventLoop) { $0.get(key: self.counterSubspace, snapshot: true, commit: true) }
                .map { (maybeBytes: Bytes?) -> Int in
                    guard let bytes = maybeBytes else {
                        return 0
                    }
                    return bytes.cast()
                }
        }

        public static func getUnapprovedComments(on eventLoop: EventLoop) -> Future<[Models.Comment]> {
            return self.storage.withTransaction(on: eventLoop) { transaction in
                transaction
                    .get(range: self.subspacePrefix.range)
                    .flatMap { (results, _) -> Future<[Models.Comment?]> in
                        Future.reduce(
                            into: [Models.Comment?](),
                            results.records.map { kv in Models.Comment.loadByRaw(IDBytes: kv.value, on: eventLoop) },
                            on: eventLoop
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
