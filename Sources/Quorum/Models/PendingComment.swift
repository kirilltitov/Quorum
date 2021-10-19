import NIO
import Entita2FDB

// not to be created at all
public extension Models {
    final class PendingComment: ModelInt {
        public static var IDKey: KeyPath<PendingComment, Int> = \.ID
        public static var fullEntityName = false
        public static var storage = App.current.fdb

        private static let counterSubspace = App.current.subspaceCounter["unapproved"]

        public let ID: Int

        fileprivate init(ID: Int) {
            self.ID = ID
        }

        public static func savePending(comment: Models.Comment) async throws {
            try await Self.storage.withTransaction { transaction in
                transaction.set(key: self.IDAsKey(ID: comment.ID), value: comment.getIDAsKey())
                self.incrementPendingCounter(within: transaction)
                try await transaction.commit()
            }
        }

        public static func clearRoutine(comment: Models.Comment) async throws {
            try await Self.storage.withTransaction { transaction in
                transaction.clear(key: self.IDAsKey(ID: comment.ID))
                self.decrementPendingCounter(within: transaction)
                try await transaction.commit()
            }
        }

        private static func incrementPendingCounter(within transaction: AnyFDBTransaction) {
            transaction.atomic(.add, key: self.counterSubspace, value: Int(1))
        }

        private static func decrementPendingCounter(within transaction: AnyFDBTransaction) {
            transaction.atomic(.add, key: self.counterSubspace, value: Int(-1))
        }

        public static func getPendingCount() async throws -> Int {
            try await Self.storage.withTransaction { transaction in
                guard let bytes = try await transaction.get(key: self.counterSubspace, snapshot: true) else {
                    return 0
                }
                return try bytes.cast()
            }
        }

        public static func getUnapprovedComments() async throws -> [Models.Comment] {
            try await Self.storage.withTransaction { transaction in
                let records = try await transaction.get(range: self.subspacePrefix.range)

                var result: [Models.Comment] = []

                for record in records.records {
                    guard let comment = try await Models.Comment.loadByRaw(IDBytes: record.value) else {
                        continue
                    }
                    result.append(comment)
                }

                return result
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
