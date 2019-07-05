import Foundation
import LGNCore
import LGNC
import Entita2FDB

let migrations: Migrations = [
    {
        let _defaultUser: Models.User! = try! Logic.User.get(by: defaultUser).wait()

        let firstID = try! Models.Comment.getNextID(on: eventLoopGroup.eventLoop).wait()
        let comment = Models.Comment(
            ID: firstID,
            IDUser: defaultUser,
            IDPost: 1,
            IDReplyComment: nil,
            body: "Так!"
        )

        let secondID = try! Models.Comment.getNextID(on: eventLoopGroup.eventLoop).wait()
        let comment2 = Models.Comment(
            ID: secondID,
            IDUser: defaultUser,
            IDPost: 1,
            IDReplyComment: firstID,
            body: "Second"
        )

        let _ = try Logic.Comment.insert(comment: comment, as: _defaultUser, on: eventLoopGroup.eventLoop).wait()
        let _ = try Logic.Comment.approve(comment: comment, on: eventLoopGroup.eventLoop).wait()
        let _ = try Logic.Comment.insert(comment: comment2, as: _defaultUser, on: eventLoopGroup.eventLoop).wait()
        let _ = try Logic.Comment.likeOrUnlike(
            comment: comment,
            by: Models.User(ID: defaultUser, username: "Kirill Titov", accessLevel: .Admin),
            on: eventLoopGroup.eventLoop
        ).wait()
        let _ = try Logic.Comment.likeOrUnlike(
            comment: comment,
            by: Models.User(ID: E2.UUID(), username: "Kirill Titov", accessLevel: .Admin),
            on: eventLoopGroup.eventLoop
        ).wait()
        let _ = try Logic.Comment.likeOrUnlike(
            comment: comment,
            by: Models.User(ID: E2.UUID(), username: "Kirill Titov", accessLevel: .Admin),
            on: eventLoopGroup.eventLoop
        ).wait()
    },
    {
        try fdb.get(range: Models.Comment._getPrefix().range).records.forEach { row in
            let tuple = try FDB.Tuple(from: row.key)
            if tuple.tuple.count != 6 {
                return
            }
            guard let IDPost: Int = tuple.tuple[3] as? Int else {
                return
            }
            try Logic.Post.incrementCommentCounterForPost(ID: IDPost, on: eventLoopGroup.eventLoop).wait()
        }
    },
]
