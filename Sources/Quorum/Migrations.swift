import Foundation
import LGNCore
import LGNC
import Entita2FDB

fileprivate let _defaultUser: Models.User! = try! Logic.User.get(by: defaultUser, on: eventLoopGroup.eventLoop).wait()

let migrations: Migrations = [
    {
        LGNCore.log("Migration: Creating initial records")
        let IDUser = defaultUser
        for
            item
        in
            [
                1: true,
                35: false,
            ]
        {
        try Models.Post(ID: item.key, IDUser: IDUser, isCommentable: item.value)
            .save(on: eventLoopGroup.eventLoop)
            .wait()
        }
    },
    {
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
]
