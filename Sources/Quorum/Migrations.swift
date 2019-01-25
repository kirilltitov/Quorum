import Foundation
import LGNCore
import LGNC
import Entita2FDB

fileprivate let comment = Models.Comment(
    ID: try! Models.Comment.getNextID(on: eventLoopGroup.eventLoop).wait(),
    IDUser: defaultUser,
    IDPost: 1,
    IDReplyComment: nil,
    isDeleted: false,
    body: "Так!",
    dateCreated: Date(),
    dateUpdated: Date.distantPast
)

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
        let _ = try Logic.Comment.insert(
            comment: comment,
            on: eventLoopGroup.eventLoop
        ).wait()
    },
    {
        let _ = try Logic.Comment.likeOrUnlike(
            comment: comment,
            by: Models.User(ID: defaultUser, username: "Kirill Titov", isAdmin: true),
            on: eventLoopGroup.eventLoop
        ).wait()
    },
    {
        let _ = try Logic.Comment.likeOrUnlike(
            comment: comment,
            by: Models.User(ID: E2.UUID(), username: "Kirill Titov", isAdmin: true),
            on: eventLoopGroup.eventLoop
        ).wait()
    },
    {
        let _ = try Logic.Comment.likeOrUnlike(
            comment: comment,
            by: Models.User(ID: E2.UUID(), username: "Kirill Titov", isAdmin: true),
            on: eventLoopGroup.eventLoop
        ).wait()
    },
]
