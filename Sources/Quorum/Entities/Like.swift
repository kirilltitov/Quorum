import LGNCore
import NIO
import Entita2FDB

// not to be created at all
public extension Models {
    final public class Like: ModelInt {
        public static var IDKey: KeyPath<Like, Int> = \.ID

        public static var fullEntityName = false

        public let ID: Int

        fileprivate init(ID: Int) {
            self.ID = ID
        }

        fileprivate static func getRootPrefix(forPostID ID: Post.Identifier) -> FDB.Subspace {
            return self.subspacePrefix[Post.entityName][ID]
        }

        fileprivate static func getRootCommentsPrefix(forPostID ID: Post.Identifier) -> FDB.Subspace {
            return self.getRootPrefix(forPostID: ID)[Comment.entityName]
        }

        fileprivate static func getCommentsLikesPrefix(for comment: Comment) -> FDB.Subspace {
            return self.getRootCommentsPrefix(forPostID: comment.IDPost)[comment.ID]
        }

        fileprivate static func getCommentsLikesPrefix(for post: Post) -> FDB.Subspace {
            return self.getRootCommentsPrefix(forPostID: post.ID)
        }

        fileprivate static func getPostLikesPrefix(forPostID ID: Post.Identifier) -> FDB.Subspace {
            return self.getRootPrefix(forPostID: ID)[Post.entityName]
        }

        fileprivate static func getPostLikesPrefix(for post: Post) -> FDB.Subspace {
            return self.getPostLikesPrefix(forPostID: post.ID)
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
                .then { $0.get(range: self.getCommentsLikesPrefix(for: comment).range, snapshot: true, commit: true) }
                .map { $0.0.records.count }
        }

        public static func getLikesForCommentsIn(
            post: Post,
            with transaction: FDB.Transaction,
            on eventLoop: EventLoop
        ) -> Future<[Comment.Identifier: Int]> {
            return transaction
                .get(range: self.getCommentsLikesPrefix(for: post).range)
                .map { (results: FDB.KeyValuesResult, _: FDB.Transaction) -> [Comment.Identifier: Int] in
                    var result = [Comment.Identifier: Int]()

                    for record in results.records {
                        guard
                            let tuple = try? FDB.Tuple(from: record.key).tuple.compactMap { $0 },
                            tuple.count > 2,
                            let ID = tuple[tuple.count - 2] as? Comment.Identifier
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
            return fdb.withTransaction(on: eventLoop) { transaction in
                self.processLikeTo(comment: comment, by: user, with: transaction)
                    .then { transaction in
                        transaction.get(
                            range: self.getCommentsLikesPrefix(for: comment).range,
                            snapshot: true,
                            commit: true
                        )
                    }
                    .map { $0.0.records.count }
            }
        }

        private static func processLikeTo(
            comment: Comment,
            by user: User,
            with transaction: FDB.Transaction
        ) -> Future<FDB.Transaction> {
            let commentLikeKey = self.getCommentsLikesPrefix(for: comment)[user.ID]
            let userLikeIndexKey = user.getIndexIndexKeyForIndex(name: self.entityName, value: comment.ID)

            return transaction
                .get(key: self.getCommentsLikesPrefix(for: comment)[user.ID])
                .then { (maybeLike, transaction) -> Future<FDB.Transaction> in
                    maybeLike == nil
                        ? transaction
                            .set(key: commentLikeKey, value: [])
                            .then { $0.set(key: userLikeIndexKey, value: []) }
                        : transaction
                            .clear(key: commentLikeKey)
                            .then { $0.clear(key: userLikeIndexKey) }
                }
        }
    }
}
