import Foundation
import Generated
import LGNC
import Entita2
import FDB
import NIO

public extension Logic {
    public class Post {
        public class CommentWithLikes {
            public let comment: Models.Comment
            private(set) var likes: Int = 0

            public init(_ comment: Models.Comment) {
                self.comment = comment
            }

            func incrementLikes() {
                self.likes += 1
            }
        }

        public enum E: Error {
            case PostNotFound
        }

        private static let postsLRU: CacheLRU<Int, Models.Post> = CacheLRU(capacity: 1000)

        public static func get(by ID: Int, on eventLoop: EventLoop) -> Future<Models.Post?> {
            return self.postsLRU.getOrSet(by: ID, on: eventLoop) {
                Models.Post.load(
                    by: ID,
                    on: eventLoop
                )
            }
        }

        public static func getThrowing(by ID: Int, on eventLoop: EventLoop) -> Future<Models.Post> {
            return self
                .get(by: ID, on: eventLoop)
                .thenThrowing { maybePost in
                    guard let post = maybePost else {
                        throw LGNC.ContractError.GeneralError("Post not found", 404)
                    }
                    return post
                }
        }

        public static func isExistingAndCommentable(_ ID: Int, on eventLoop: EventLoop) -> Future<Bool> {
            return self
                .get(by: ID, on: eventLoop)
                .map { $0?.isCommentable ?? false }
        }

        public static func getCommentsFor(
            ID: Int,
            as user: Models.User? = nil,
            on eventLoop: EventLoop
        ) -> Future<[CommentWithLikes]> {
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
                var result: [CommentWithLikes] = []
                var currentCommentWithLikes: CommentWithLikes?
                for record in $0.records {
                    let tuple = Tuple(from: record.key)
                    if Models.Comment.doesRelateToThis(tuple: tuple) {
                        let comment = try Models.Comment(from: record.value)
                        if let user = user {
                            if user.isOrdinaryUser && (comment.isDeleted == true || comment.isApproved == false) {
                                continue
                            }
                        } else if comment.isDeleted == true || comment.isApproved == false {
                            continue
                        }
                        let instance = CommentWithLikes(comment)
                        currentCommentWithLikes = instance
                        result.append(instance)
                    } else if Models.Like.doesRelateToThis(tuple: tuple) {
                        currentCommentWithLikes?.incrementLikes()
                    }
                }
                return result
            }
        }
    }
}
