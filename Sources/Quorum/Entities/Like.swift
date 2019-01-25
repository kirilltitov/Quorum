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

        fileprivate static func getPrefix(for comment: Comment) -> Subspace {
            return comment._getFullPrefix()[self.entityName]
        }

        public static func getCommentID(from tuple: Tuple) -> Models.Comment.Identifier? {
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
                .begin(eventLoop: eventLoop)
                .then { $0.get(range: self.getPrefix(for: comment).range, commit: true) }
                .map { $0.0.records.count }
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
            return fdb
                .begin(eventLoop: eventLoop)
                .then { $0.get(key: self.getPrefix(for: comment)[user.ID]) }
                .then { (maybeLike, transaction) -> Future<Transaction> in
                    if maybeLike == nil {
                        return transaction.set(key: self.getPrefix(for: comment)[user.ID], value: Bytes())
                    } else {
                        return transaction.clear(key: self.getPrefix(for: comment)[user.ID])
                    }
                }
                .then { transaction in transaction.get(range: self.getPrefix(for: comment).range, commit: true) }
                .map { $0.0.records.count }
        }
    }
}
