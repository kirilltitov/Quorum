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

            func incrementLikes(_ likes: Int = 1) {
                self.likes += likes
            }
        }

        public enum E: Error {
            case PostNotFound
        }

        private static let postsLRU: CacheLRU<Int, Models.Post> = CacheLRU(capacity: 1000)

        public static func get(by ID: Int, snapshot: Bool, on eventLoop: EventLoop) -> Future<Models.Post?> {
            return self.postsLRU.getOrSet(by: ID, on: eventLoop) {
                Models.Post.loadWithTransaction(
                    by: ID,
                    snapshot: snapshot,
                    on: eventLoop
                ).map { $0.0 }
            }
        }

        public static func getThrowing(
            by ID: Int,
            snapshot: Bool,
            on eventLoop: EventLoop
        ) -> Future<Models.Post> {
            return self
                .get(by: ID, snapshot: snapshot, on: eventLoop)
                .thenThrowing { maybePost in
                    guard let post = maybePost else {
                        throw LGNC.ContractError.GeneralError("Post not found", 404)
                    }
                    return post
                }
        }

        public static func isExistingAndCommentable(_ ID: Int, on eventLoop: EventLoop) -> Future<Bool> {
            return self
                .get(by: ID, snapshot: false, on: eventLoop)
                .map { $0?.isCommentable ?? false }
        }

        public static func getCommentsFor(
            ID: Int,
            as user: Models.User? = nil,
            on eventLoop: EventLoop
        ) -> Future<[CommentWithLikes]> {
            return self.get(
                by: ID,
                snapshot: true,
                on: eventLoop
            ).thenThrowing {
                guard let post = $0 else {
                    throw E.PostNotFound
                }
                return post
            }.then { (post: Models.Post) in
                fdb.withTransaction(on: eventLoop) { transaction in
                    Models.Comment.loadAll(
                        bySubspace: Models.Comment._getPostPrefix(post.ID),
                        with: transaction,
                        snapshot: true,
                        on: eventLoop
                    ).map { results in
                        var result = [CommentWithLikes]()

                        for (_, comment) in results {
                            if user?.isAtLeastModerator == false {
                                if comment.status == .hidden || comment.status == .pending {
                                    continue
                                }
                                if comment.status == .deleted {
                                    comment.body = ""
                                }
                            }
                            result.append(CommentWithLikes(comment))
                        }

                        return result
                    }.then { commentsWithLikes in
                        Models.Like
                            .getLikesForCommentsIn(post: post, with: transaction, on: eventLoop)
                            .map { (commentsWithLikes, $0) }
                    }.map { (commentsWithLikes: [CommentWithLikes], likesInfo: [Models.Comment.Identifier: Int]) in
                        commentsWithLikes.forEach { commentWithLikes in
                            if let likes = likesInfo[commentWithLikes.comment.ID] {
                                commentWithLikes.incrementLikes(likes)
                            }
                        }
                        return commentsWithLikes
                    }
                }
            }
        }
    }
}
