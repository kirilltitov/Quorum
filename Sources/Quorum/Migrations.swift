import Foundation
import LGNCore
import LGNC
import Entita2FDB
import Entita

let migrations: Migrations = [
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
//        let _ = try Logic.Comment.insert(comment: comment, as: _defaultUser, on: eventLoopGroup.eventLoop).wait()
//        let _ = try Logic.Comment.approve(comment: comment, on: eventLoopGroup.eventLoop).wait()
//        let _ = try Logic.Comment.insert(comment: comment2, as: _defaultUser, on: eventLoopGroup.eventLoop).wait()
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
    {
        try fdb.get(range: Models.Like.getRootPrefix().range).records.forEach { row in
            let tuple = try FDB.Tuple(from: row.key).tuple
            guard 1 == 1
                && tuple.count >= 5
                && tuple[tuple.count - 5] as? String == Models.Post.entityName
                && tuple[tuple.count - 3] as? String == Models.Comment.entityName,
                let IDPost = tuple[tuple.count - 4] as? Int,
                let IDComment = tuple[tuple.count - 2] as? Int
            else { return }
            let transaction = try fdb.begin(on: eventLoopGroup.eventLoop).wait()
            _ = try Models.Like.incrementLikesCounterFor(
                comment: Models.Comment(ID: IDComment, IDUser: defaultUser, IDPost: IDPost, IDReplyComment: nil, body: ""),
                within: transaction
            ).wait()
            try transaction.commit().wait()
        }
    },
    {
        try fdb.get(range: Models.User.subspacePrefix.range).records.forEach { row in
            var dict: Entita.Dict = try row.value.unpackFromJSON()
            dict["dateLastComment"] = Int(0)
            try fdb.set(key: row.key, value: dict.pack(to: .JSON))
        }
    },
]
