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

        public static func savePending(
            comment: Models.Comment,
            storage: Storage,
            on eventLoop: EventLoop
        ) -> EventLoopFuture<Void> {
            storage.withTransaction(on: eventLoop) { transaction in
                transaction
                    .set(key: self.IDAsKey(ID: comment.ID), value: comment.getIDAsKey())
                    .flatMap { self.incrementPendingCounter(within: $0) }
                    .flatMap { $0.commit() }
            }
        }

        public static func clearRoutine(
            comment: Models.Comment,
            storage: Storage,
            on eventLoop: EventLoop
        ) -> EventLoopFuture<Void> {
            storage.withTransaction(on: eventLoop) { transaction in
                transaction
                    .clear(key: self.IDAsKey(ID: comment.ID))
                    .flatMap { self.decrementPendingCounter(within: $0) }
                    .flatMap { $0.commit() }
            }
        }

        private static func incrementPendingCounter(
            within transaction: AnyFDBTransaction
        ) -> EventLoopFuture<AnyFDBTransaction> {
            transaction.atomic(.add, key: self.counterSubspace, value: Int(1))
        }

        private static func decrementPendingCounter(
            within transaction: AnyFDBTransaction
        ) -> EventLoopFuture<AnyFDBTransaction> {
            transaction.atomic(.add, key: self.counterSubspace, value: Int(-1))
        }

        public static func getPendingCount(storage: Storage, on eventLoop: EventLoop) -> EventLoopFuture<Int> {
            storage
                .withTransaction(on: eventLoop) { $0.get(key: self.counterSubspace, snapshot: true, commit: true) }
                .flatMapThrowing { (maybeBytes: Bytes?) -> Int in
                    guard let bytes = maybeBytes else {
                        return 0
                    }
                    return try bytes.cast()
                }
        }

        public static func getUnapprovedComments(
            storage: Storage,
            on eventLoop: EventLoop
        ) -> EventLoopFuture<[Models.Comment]> {
            storage.withTransaction(on: eventLoop) { transaction in
                transaction
                    .get(range: self.subspacePrefix.range)
                    .flatMap { (results, _) -> EventLoopFuture<[Models.Comment?]> in
                        EventLoopFuture.reduce(
                            into: [Models.Comment?](),
                            results.records.map { kv in
                                Models.Comment.loadByRaw(IDBytes: kv.value, storage: storage, on: eventLoop)
                            },
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
