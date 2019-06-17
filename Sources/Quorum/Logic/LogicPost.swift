import Foundation
import Generated
import LGNC
import LGNCore
import Entita2
import FDB
import NIO

public extension Logic {
    enum Post {
        public enum Status: String {
            case OK, NotFound, NotCommentable
        }

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

        public static func getPostStatus(_ ID: Int, on eventLoop: EventLoop) -> Future<Status> {
            let url = "\(config[.WEBSITE_DOMAIN])/post/exists/\(ID)"

            return HTTPRequester
                .requestJSON(
                    method: .GET,
                    url: url,
                    on: eventLoop
                )
                .map { maybeData, _, error in
                    if let error = error {
                        defaultLogger.error("Could not execute remote service API at '\(url)': \(error)")
                        return .NotFound
                    }
                    guard maybeData?[json: "data", "result"] == true else {
                        return .NotFound
                    }

                    return .OK
                }
        }

        public static func getCommentsFor(
            ID: Int,
            as maybeUser: Models.User? = nil,
            on eventLoop: EventLoop
        ) -> Future<[CommentWithLikes]> {
            return fdb.withTransaction(on: eventLoop) { transaction in
                let rawCommentsProfiler = LGNCore.Profiler.begin()
                let commentsFuture = Models.Comment.loadAll(
                    bySubspace: Models.Comment._getPostPrefix(ID),
                    with: transaction,
                    snapshot: true,
                    on: eventLoop
                )

                commentsFuture.whenComplete { _ in
                    defaultLogger.info("Raw comments loaded in \(rawCommentsProfiler.end().rounded(toPlaces: 4))s")
                }

                return commentsFuture.map { results in
                    results
                        .filter { ID, comment in
                            // moderators can see all comments
                            if maybeUser?.isAtLeastModerator == true {
                                return true
                            }
                            // users can see their own comments
                            if comment.IDUser == maybeUser?.ID {
                                return true
                            }
                            // author should see own hidden comments as published
                            if comment.status == .hidden && comment.IDUser == maybeUser?.ID {
                                return true
                            }
                            // if comment isn't published or hidden, don't show it
                            if comment.status => [.pending, .hidden, .banHidden] {
                                return false
                            }
                            return true
                        }
                        .map { ID, comment in
                            // author should see own hidden comments as published
                            if comment.status == .hidden && comment.IDUser == maybeUser?.ID {
                                comment.status = .published
                            }
                            if comment.status == .deleted && maybeUser?.isAtLeastModerator == false {
                                comment.body = ""
                            }
                            return CommentWithLikes(comment)
                        }
                }.flatMap { commentsWithLikes in
                    Models.Like
                        .getLikesForCommentsIn(postID: ID, with: transaction, on: eventLoop)
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

//        private static let postsLRU: CacheLRU<Int, Models.Post> = CacheLRU(capacity: 1000)
//
//        public static func get(by ID: Int, snapshot: Bool, on eventLoop: EventLoop) -> Future<Models.Post?> {
//            return self.postsLRU.getOrSet(by: ID, on: eventLoop) {
//                Models.Post.loadWithTransaction(
//                    by: ID,
//                    snapshot: snapshot,
//                    on: eventLoop
//                ).map { $0.0 }
//            }
//        }
//
//        public static func getThrowing(
//            by ID: Int,
//            snapshot: Bool,
//            on eventLoop: EventLoop
//        ) -> Future<Models.Post> {
//            return self
//                .get(by: ID, snapshot: snapshot, on: eventLoop)
//                .thenThrowing { maybePost in
//                    guard let post = maybePost else {
//                        throw LGNC.ContractError.GeneralError("Post not found", 404)
//                    }
//                    return post
//                }
//        }
//
        }
    }
}
