import LGNCore
import NIO
import Entita2FDB

// not to be created at all
public extension Models {
    final class Like: ModelInt {
        public static var IDKey: KeyPath<Like, Int> = \.ID

        public static var fullEntityName = false

        public let ID: Int

        fileprivate init(ID: Int) {
            self.ID = ID
        }

        fileprivate static func getLikesCounterPrefixSubspace(forPostID ID: Post.Identifier) -> FDB.Subspace {
            return self.subspacePrefix["cnt"][Post.entityName][ID]
        }

        fileprivate static func getLikesCounterSubspaceFor(comment: Comment) -> FDB.Subspace {
            return self.getLikesCounterPrefixSubspace(forPostID: comment.IDPost)[Comment.entityName][comment.ID]
        }

        /* fileprivate */ public static func getRootPrefix() -> FDB.Subspace {
            return self.subspacePrefix[Post.entityName]
        }

        fileprivate static func getRootPrefix(forPostID ID: Post.Identifier) -> FDB.Subspace {
            return self.getRootPrefix()[ID]
        }

        fileprivate static func getRootCommentsPrefix(forPostID ID: Post.Identifier) -> FDB.Subspace {
            return self.getRootPrefix(forPostID: ID)[Comment.entityName]
        }

        fileprivate static func getCommentsLikesPrefix(for comment: Comment) -> FDB.Subspace {
            return self.getRootCommentsPrefix(forPostID: comment.IDPost)[comment.ID]
        }

        fileprivate static func getPostLikesPrefix(forPostID ID: Post.Identifier) -> FDB.Subspace {
            return self.getRootPrefix(forPostID: ID)[Post.entityName]
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

        public static func getLikesFor(comment: Comment, on eventLoop: EventLoop) -> Future<Int> {
            return fdb
                .begin(on: eventLoop)
                .flatMap {
                    $0.get(key: self.getLikesCounterSubspaceFor(comment: comment), snapshot: true, commit: true)
                }
                .map { (maybeBytes: Bytes?) in maybeBytes?.cast() ?? 0 }
        }

        public static func getLikesForCommentsIn(
            postID: Int,
            within transaction: FDB.Transaction,
            on eventLoop: EventLoop
        ) -> Future<[Comment.Identifier: Int]> {
            return transaction
                .get(range: self.getLikesCounterPrefixSubspace(forPostID: postID).range, snapshot: true)
                .map { (results: FDB.KeyValuesResult, _: FDB.Transaction) -> [Comment.Identifier: Int] in
                    var result = [Comment.Identifier: Int]()

                    // Can't use results.records.map because skipping rows becomes unreasonably more difficult
                    for record in results.records {
                        guard
                            let tuple = try? FDB.Tuple(from: record.key).tuple.compactMap { $0 },
                            let ID = tuple.last as? Comment.Identifier
                            else { continue }
                        result[ID] = (result[ID] ?? 0) + 1
                    }

                    return result
                }
        }

        public static func getLikesFor(
            comment: Comment,
            user: User,
            on eventLoop: EventLoop
        ) -> Future<(Models.Comment, Int, Models.User)> {
            return self
                .getLikesFor(comment: comment, on: eventLoop)
                .map { (comment, $0, user) }
        }

        public static func likeOrUnlike(comment: Comment, by user: User, on eventLoop: EventLoop) -> Future<Int> {
            return self
                .processLikeTo(comment: comment, by: user, on: eventLoop)
                .flatMap { self.getLikesFor(comment: comment, on: eventLoop) }
        }

        fileprivate static func updateLikesCounterFor(
            comment: Comment,
            count: Int,
            within transaction: FDB.Transaction
        ) -> Future<FDB.Transaction> {
            return transaction.atomic(.add, key: self.getLikesCounterSubspaceFor(comment: comment), value: count)
        }

        /* fileprivate */ public static func incrementLikesCounterFor(
            comment: Comment,
            within transaction: FDB.Transaction
        ) -> Future<FDB.Transaction> {
            return self.updateLikesCounterFor(comment: comment, count: 1, within: transaction)
        }

        fileprivate static func decrementLikesCounterFor(
            comment: Comment,
            within transaction: FDB.Transaction
        ) -> Future<FDB.Transaction> {
            return self.updateLikesCounterFor(comment: comment, count: -1, within: transaction)
        }

        fileprivate static func processLikeTo(
            comment: Comment,
            by user: User,
            on eventLoop: EventLoop
        ) -> Future<Void> {
            let commentLikeKey = self.getCommentsLikesPrefix(for: comment)[user.ID]
            let userLikeIndexKey = user.getIndexIndexKeyForIndex(name: self.entityName, value: comment.ID)

            return fdb.withTransaction(on: eventLoop) { transaction in
                transaction
                    .get(key: self.getCommentsLikesPrefix(for: comment)[user.ID])
                        .flatMap { (maybeLike, transaction) -> Future<FDB.Transaction> in
                        maybeLike == nil
                            ? transaction
                                .set(key: commentLikeKey, value: [])
                                .flatMap { $0.set(key: userLikeIndexKey, value: []) }
                                .flatMap { self.incrementLikesCounterFor(comment: comment, within: $0) }
                            : transaction
                                .clear(key: commentLikeKey)
                                .flatMap { $0.clear(key: userLikeIndexKey) }
                                .flatMap { self.decrementLikesCounterFor(comment: comment, within: $0) }
                    }
                    .map { _ in Void() }
            }
        }
    }
}
