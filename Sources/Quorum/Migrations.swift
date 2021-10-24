import Foundation
import LGNCore
import LGNLog
import LGNC
import Entita2FDB
import Entita

func getMigrations() -> Migrations {
    [
        {
    //        let _defaultUser: Models.User! = try! Logic.User.get(by: defaultUser).wait()
    //
    //        let firstID = try! Models.Comment.getNextID(on: eventLoopGroup.eventLoop).wait()
    //        let comment = Models.Comment(
    //            ID: firstID,
    //            IDUser: defaultUser,
    //            IDPost: 1,
    //            IDReplyComment: nil,
    //            body: "Так!"
    //        )
    //
    //        let secondID = try! Models.Comment.getNextID(on: eventLoopGroup.eventLoop).wait()
    //        let comment2 = Models.Comment(
    //            ID: secondID,
    //            IDUser: defaultUser,
    //            IDPost: 1,
    //            IDReplyComment: firstID,
    //            body: "Second"
    //        )
    //
    //        let _ = try Logic.Comment.insert(comment: comment, as: _defaultUserGroup.eventLoop).wait()
    //        let _ = try Logic.Comment.approve(comment: commentGroup.eventLoop).wait()
    //        let _ = try Logic.Comment.insert(comment: comment2, as: _defaultUserGroup.eventLoop).wait()
    //        let _ = try Logic.Comment.likeOrUnlike(
    //            comment: comment,
    //            by: Models.User(ID: defaultUser, username: "Kirill Titov", accessLevel: .Admin),
    //            on: eventLoopGroup.eventLoop
    //        ).wait()
    //        let _ = try Logic.Comment.likeOrUnlike(
    //            comment: comment,
    //            by: Models.User(ID: E2.UUID(), username: "Kirill Titov", accessLevel: .Admin),
    //            on: eventLoopGroup.eventLoop
    //        ).wait()
    //        let _ = try Logic.Comment.likeOrUnlike(
    //            comment: comment,
    //            by: Models.User(ID: E2.UUID(), username: "Kirill Titov", accessLevel: .Admin),
    //            on: eventLoopGroup.eventLoop
    //        ).wait()
        },
        {
            for row in try await App.current.fdb.get(range: Models.Comment._getPrefix().range).records {
                let tuple = try FDB.Tuple(from: row.key)
                if tuple.tuple.count != 6 {
                    return
                }
                guard let IDPost: Int = tuple.tuple[3] as? Int else {
                    return
                }
                try await Logic.Post.incrementCommentCounterForPost(ID: IDPost)
            }
        },
        {
            for row in try await App.current.fdb.get(range: Models.Like.getRootPrefix().range).records {
                let tuple = try FDB.Tuple(from: row.key).tuple
                guard 1 == 1
                    && tuple.count >= 5
                    && tuple[tuple.count - 5] as? String == Models.Post.entityName
                    && tuple[tuple.count - 3] as? String == Models.Comment.entityName,
                    let IDPost = tuple[tuple.count - 4] as? Int,
                    let IDComment = tuple[tuple.count - 2] as? Int
                else { return }
                let transaction: AnyFDBTransaction = try App.current.fdb.begin()
                Models.Like.incrementLikesCounterFor(
                    comment: Models.Comment(ID: IDComment, IDUser: App.defaultUser, IDPost: IDPost, IDReplyComment: nil, body: ""),
                    within: transaction
                )
                try await transaction.commit()
            }
        },
        {
            for row in try await App.current.fdb.get(range: Models.User.subspacePrefix.range).records {
                var dict: Entita.Dict = try row.value.unpackFromJSON()
                dict["dateLastComment"] = Int(0)
                try await App.current.fdb.set(key: row.key, value: dict.pack(to: .JSON))
            }
        },
        {
            let logger = Logger.current

            guard try await Models.PendingComment.getPendingCount() < 0 else {
                logger.info("Pending counter is greater or equal to zero, no need to perform migration")
                return
            }

            logger.info("Zeroing out pending counter")
            try await App.current.fdb.set(
                key: Models.PendingComment.counterSubspace,
                value: LGNCore.getBytes(Int(0))
            )
        },
    ]
}
