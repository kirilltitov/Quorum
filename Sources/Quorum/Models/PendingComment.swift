import FDB
import FDBEntity

public extension Models {
    /// Comments awaiting moderation: `PendingComment / <comment ID>` → key of the comment, plus a counter
    enum PendingComment {
        public static let entityName = "PendingComment"

        public static var subspacePrefix: FDB.Subspace {
            App.current.subspaceMain[Self.entityName]
        }

        static var counterKey: FDB.Subspace {
            App.current.subspaceCounter["unapproved"]
        }

        static func key(for comment: Models.Comment) -> FDB.Subspace {
            self.subspacePrefix[comment.ID]
        }

        public static func savePending(comment: Models.Comment, within transaction: borrowing FDB.Transaction) {
            transaction.set(key: self.key(for: comment), value: comment.getIDAsKey())
            transaction.atomic(.add, key: self.counterKey, value: Int64(1))
        }

        /// Removes the comment from the pending list (if it's there)
        public static func clear(comment: Models.Comment, within transaction: borrowing FDB.Transaction) async throws {
            guard try await transaction.get(key: self.key(for: comment)).value != nil else {
                return
            }
            transaction.clear(key: self.key(for: comment))
            transaction.atomic(.add, key: self.counterKey, value: Int64(-1))
        }

        public static func getPendingCount() async throws -> Int {
            max(0, try await App.current.fdb.get(key: self.counterKey, snapshot: true).counterValue)
        }

        public static func getUnapprovedComments() async throws -> [Models.Comment] {
            try await App.current.fdb.withTransaction { transaction in
                var result: [Models.Comment] = []
                for record in try await transaction.getAll(self.subspacePrefix.range, snapshot: true) {
                    if let comment = try await Models.Comment.loadByRaw(key: record.value, within: transaction) {
                        result.append(comment)
                    }
                }
                return result
            }
        }
    }
}
