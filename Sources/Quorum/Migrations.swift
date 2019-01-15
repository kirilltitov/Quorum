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
                2: true,
                3: true,
                4: true,
                5: true,
                6: true,
                7: true,
                8: true,
                15: true,
                16: true,
                17: true,
                18: true,
                19: true,
                23: true,
                24: true,
                25: true,
                26: true,
                27: true,
                28: true,
                29: true,
                30: true,
                31: true,
                32: true,
                33: true,
                34: true,
                35: false,
            ]
        {
        try Models.Post(ID: item.key, IDUser: IDUser, isCommentable: item.value)
            .save(on: eventLoopGroup.eventLoop)
            .wait()
        }
    },
    {
        try Logic.Comment.insert(
            comment: comment,
            on: eventLoopGroup.eventLoop
        ).wait()
    },
    {
        let _ = try Logic.Comment.like(
            comment: comment,
            by: Models.User(ID: defaultUser, username: "Kirill Titov", isAdmin: true),
            on: eventLoopGroup.eventLoop
        ).wait()
    },
    {
        let _ = try Logic.Comment.like(
            comment: comment,
            by: Models.User(ID: E2.UUID(), username: "Kirill Titov", isAdmin: true),
            on: eventLoopGroup.eventLoop
        ).wait()
    },
    {
        let _ = try Logic.Comment.like(
            comment: comment,
            by: Models.User(ID: E2.UUID(), username: "Kirill Titov", isAdmin: true),
            on: eventLoopGroup.eventLoop
        ).wait()
    },
]
