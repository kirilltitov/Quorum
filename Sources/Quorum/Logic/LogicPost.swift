import Foundation
import Generated
import LGNC
import Entita2
import FDB
import NIO

public extension Logic {
    public class Post {
        public struct CommentWithLikes {
            public let comment: Models.Comment
            private(set) var likes: Int

            mutating func incrementLikes() {
                self.likes += 1
            }
        }

        public enum E: Error {
            case PostNotFound
        }

        private static let postsLRU: CacheLRU<Int, Models.Post> = CacheLRU(capacity: 1000)

        public static func get(by ID: Int, on eventLoop: EventLoop) -> Future<Models.Post?> {
            return self.postsLRU.getOrSet(for: ID) {
                Models.Post.load(
                    by: ID,
                    on: eventLoop
                )
            }
        }

        public static func isExistingAndCommentable(_ ID: Int, on eventLoop: EventLoop) -> Future<Bool> {
            return self
                .get(by: ID, on: eventLoop)
                .map { $0?.isCommentable ?? false }
        }

        public static func getCommentsFor(
            ID: Int,
            on eventLoop: EventLoop
        ) -> Future<[Models.Comment.Identifier: CommentWithLikes]> {
            return self.get(
                by: ID,
                on: eventLoop
            ).thenThrowing {
                guard let post = $0 else {
                    throw E.PostNotFound
                }
                return post
            }.then { (post: Models.Post) -> Future<(Models.Post, Transaction)> in
                fdb.begin(eventLoop: eventLoop).map { (post, $0) }
            }.then { (post, transaction) in
                transaction
                    .get(range: Models.Comment._getPostPrefix(post.ID).range)
                    .map { $0.0 }
            }.thenThrowing {
                var result: [Models.Comment.Identifier: CommentWithLikes] = [:]
                for record in $0.records {
                    let tuple = Tuple(from: record.key)
                    if Models.Comment.doesRelateToThis(tuple: tuple) {
                        let comment = try Models.Comment(from: record.value)
                        result[comment.ID] = CommentWithLikes(comment: comment, likes: 0)
                    } else if Models.Like.doesRelateToThis(tuple: tuple) {
                        if let commentID = Models.Like.getCommentID(from: tuple) {
                            result[commentID]?.incrementLikes()
                        }
                    }
                }
                return result
            }
        }
    }
}
