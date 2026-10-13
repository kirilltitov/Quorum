import Foundation
import Testing
import LGNC
import FDB
import FDBEntity
@testable import Quorum

@Suite("Hashids")
struct HashidsTests {
    let hashids = Hashids(salt: "TXRcA(q7)1fZDp5z0v{_52", minHashLength: 5)

    @Test func roundTrip() {
        for ID in [1, 2, 42, 1711, 100_500, Int(Int32.max), Int.max / 2] {
            let hash = self.hashids.encode(ID)!
            #expect(self.hashids.decode(hash) == [ID])
        }
    }

    @Test func garbageIsRejected() {
        let inputs = [
            "", " ", "a", "zzzzz", "😀😀😀😀😀", String(repeating: "z", count: 1000), String(repeating: "9", count: 64),
            "\u{0}\u{0}\u{0}", "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
        ]
        for input in inputs {
            #expect(self.hashids.decode(input).count <= 1)
        }
        // A valid hash with a changed character is not a valid hash anymore
        var hash = Array(self.hashids.encode(42)!)
        hash[hash.count - 1] = hash[hash.count - 1] == "a" ? "b" : "a"
        #expect(self.hashids.decode(String(hash)) != [42])
    }
}

@Suite("Quorum", .serialized)
struct QuorumTests {
    init() {
        TestApp.setUp
    }

    /// Keys must stay byte-identical to the ones written by previous versions
    @Test func keyLayout() {
        let root = Packed.s(TestApp.realm) + Packed.s("Quorum")
        let user = Models.User(ID: App.defaultUser, username: "teonoman", accessLevel: .Admin)
        var comment = Models.Comment(ID: 42, IDUser: user.ID, IDPost: 7, IDReplyComment: nil, body: "Hi")
        comment.status = .published

        #expect(comment.getIDAsKey() == root + Packed.s("post") + Packed.i(7) + Packed.s("Comment") + Packed.i(42))
        #expect(
            Models.Comment.getIndexKeyForUniqueIndex(key: .ID, value: 42).prefix
                == root + Packed.s("idx") + Packed.s("Comment") + Packed.s("ID") + Packed.i(42)
        )
        #expect(
            Models.User.IDAsKey(ID: user.ID) == root + Packed.s("User") + Packed.b(user.ID.bytes)
        )
        #expect(
            Models.User.getIndexKeyForUniqueIndex(key: .username, value: "teonoman").prefix
                == root + Packed.s("idx") + Packed.s("User") + Packed.s("username") + Packed.s("teonoman")
        )
        #expect(Models.Comment.sequenceKey.prefix == root + Packed.s("idx") + Packed.s("Comment"))
        #expect(
            Models.Like.getCommentsLikesPrefix(for: comment)[user.ID].prefix
                == root + Packed.s("Like") + Packed.s("post") + Packed.i(7) + Packed.s("Comment") + Packed.i(42)
                    + Packed.b(user.ID.bytes)
        )
        #expect(
            Models.Like.getLikesCounterSubspaceFor(comment: comment).prefix
                == root + Packed.s("Like") + Packed.s("cnt") + Packed.s("post") + Packed.i(7) + Packed.s("Comment")
                    + Packed.i(42)
        )
        #expect(
            user.getIndexIndexKeyForIndex(key: .Like, value: 42).prefix
                == root + Packed.s("idx") + Packed.s("User") + Packed.s("idx") + Packed.b(user.ID.bytes)
                    + Packed.s("Like") + Packed.i(42)
        )
        #expect(
            Models.PendingComment.key(for: comment).prefix == root + Packed.s("PendingComment") + Packed.i(42)
        )
        #expect(Models.PendingComment.counterKey.prefix == root + Packed.s("cnt") + Packed.s("unapproved"))
        #expect(
            Models.Post.subspacePrefix[7].prefix == root + Packed.s("cnt") + Packed.s("post") + Packed.s("comments")
                + Packed.i(7)
        )
    }

    /// Entities written by previous versions (Entita2 JSON) are readable
    @Test func legacyJSON() throws {
        let json = """
        {"ID":"AAAAABY3ADQXEQAAAAAAAA==","username":"teonoman","accessLevel":"Admin",\
        "dateLastComment":-63114076800,"color":"default"}
        """
        let user = try Models.User(from: Bytes(json.utf8))
        #expect(user.ID == App.defaultUser)
        #expect(user.accessLevel == .Admin)
        #expect(user.dateLastComment == .distantPast)
    }

    func makeUser(_ accessLevel: Models.User.AccessLevel) async throws -> Models.User {
        let user = Models.User(
            ID: FDB.UUID(),
            username: "user-\(UUID().uuidString)",
            accessLevel: accessLevel
        )
        try await user.insert()
        return user
    }

    func pending() async throws -> Set<Int> {
        Set(try await Models.PendingComment.getUnapprovedComments().map { $0.ID })
    }

    @Test func commentLifecycle() async throws {
        let IDPost = Int.random(in: 1 ..< 1_000_000)
        let author = try await self.makeUser(.User)
        let moderator = try await self.makeUser(.Moderator)
        let reader = try await self.makeUser(.User)
        let pendingBefore = try await Models.PendingComment.getPendingCount()

        // A comment of an ordinary user awaits moderation
        let comment = try await Logic.Comment.create(IDPost: IDPost, IDReplyComment: nil, body: "Hello", as: author)
        #expect(comment.status == .pending)
        #expect(try await self.pending().contains(comment.ID))
        #expect(try await Models.PendingComment.getPendingCount() == pendingBefore + 1)
        #expect(try await Logic.Post.getCommentsFor(ID: IDPost, as: reader).isEmpty)
        #expect(try await Logic.Post.getCommentsFor(ID: IDPost, as: author).map { $0.comment.ID } == [comment.ID])

        // Cooldown
        await #expect(throws: LGNC.ContractError.self) {
            try await Logic.Comment.create(IDPost: IDPost, IDReplyComment: nil, body: "Again", as: author)
        }

        // Approval publishes it once
        #expect(try await Logic.Comment.approve(ID: comment.ID).status == .published)
        #expect(try await Logic.Comment.approve(ID: comment.ID).status == .published)
        #expect(try await !self.pending().contains(comment.ID))
        #expect(try await Models.PendingComment.getPendingCount() == pendingBefore)
        let encodedID = Logic.Post.encodeHash(ID: IDPost)
        #expect(try await Logic.Post.getCommentCountersForPosts(IDs: [encodedID, "garbage"]) == [encodedID: 1])
        #expect(try await Logic.Post.getCommentsFor(ID: IDPost, as: reader).map { $0.comment.ID } == [comment.ID])

        // Moderators skip premoderation
        let reply = try await Logic.Comment.create(IDPost: IDPost, IDReplyComment: comment.ID, body: "Hi", as: moderator)
        #expect(reply.status == .published)
        #expect(try await Logic.Post.getCommentCountersForPosts(IDs: [encodedID]) == [encodedID: 2])

        // Likes
        #expect(try await Logic.Comment.likeOrUnlike(comment: comment, by: author) == 0) // own comment
        #expect(try await Logic.Comment.likeOrUnlike(comment: try await Logic.Comment.getThrowing(by: comment.ID), by: reader) == 1)
        #expect(try await Logic.Comment.likeOrUnlike(comment: try await Logic.Comment.getThrowing(by: comment.ID), by: moderator) == 2)
        #expect(try await Logic.Comment.likeOrUnlike(comment: try await Logic.Comment.getThrowing(by: comment.ID), by: reader) == 1)
        let withLikes = try await Logic.Post.getCommentsFor(ID: IDPost, as: reader)
        #expect(withLikes.first { $0.comment.ID == comment.ID }?.likes == 1)

        // Editing
        await #expect(throws: LGNC.ContractError.self) {
            try await Logic.Comment.edit(ID: comment.ID, body: "Hacked", by: reader)
        }
        #expect(try await Logic.Comment.edit(ID: comment.ID, body: "Edited", by: moderator).body == "Edited")
        let history = try await Models.Comment.History.loadAll(
            in: Models.Comment.History.subspacePrefix[comment.ID]
        )
        #expect(history.map { $0.newBody } == ["Edited"])

        // Can't hide a comment with published replies
        await #expect(throws: LGNC.ContractError.self) {
            try await Logic.Comment.hide(ID: comment.ID)
        }
        try await Logic.Comment.hide(ID: reply.ID)
        #expect(try await Logic.Post.getCommentCountersForPosts(IDs: [encodedID]) == [encodedID: 1])
        #expect(try await Logic.Post.getCommentsFor(ID: IDPost, as: reader).map { $0.comment.ID } == [comment.ID])
        try await Logic.Comment.unhide(ID: reply.ID)
        #expect(try await Logic.Post.getCommentCountersForPosts(IDs: [encodedID]) == [encodedID: 2])

        // Deleting
        await #expect(throws: LGNC.ContractError.self) {
            try await Logic.Comment.delete(ID: reply.ID, by: author)
        }
        try await Logic.Comment.delete(ID: comment.ID, by: author)
        let deleted = try await Logic.Post.getCommentsFor(ID: IDPost, as: reader).first { $0.comment.ID == comment.ID }
        #expect(deleted?.comment.status == .deleted)
        #expect(deleted?.comment.body == "")
        #expect(try await Logic.Comment.undelete(ID: comment.ID).status == .published)

        // Rejecting removes a pending comment completely
        let rejected = try await Logic.Comment.create(IDPost: IDPost, IDReplyComment: nil, body: "Spam", as: reader)
        try await Logic.Comment.reject(ID: rejected.ID)
        try await Logic.Comment.reject(ID: comment.ID) // not pending, nothing happens
        #expect(try await Logic.Comment.get(by: rejected.ID) == nil)
        #expect(try await Logic.Comment.get(by: comment.ID) != nil)
        #expect(try await Models.PendingComment.getPendingCount() == pendingBefore)
    }

    @Test func concurrentCommentsGetUniqueIDs() async throws {
        let IDPost = Int.random(in: 1 ..< 1_000_000)
        let users = try await (0 ..< 20).asyncMap { _ in try await self.makeUser(.Moderator) }
        let comments = try await withThrowingTaskGroup(of: Models.Comment.self) { group in
            for user in users {
                group.addTask {
                    try await Logic.Comment.create(IDPost: IDPost, IDReplyComment: nil, body: "Hi", as: user)
                }
            }
            return try await group.reduce(into: []) { $0.append($1) }
        }
        #expect(Set(comments.map { $0.ID }).count == 20)
        let encodedID = Logic.Post.encodeHash(ID: IDPost)
        #expect(try await Logic.Post.getCommentCountersForPosts(IDs: [encodedID]) == [encodedID: 20])
    }

    @Test func accessLevelAndCache() async throws {
        let user = try await self.makeUser(.User)
        #expect(try await Logic.User.get(by: user.ID)?.accessLevel == .User)
        try await Logic.User.set(accessLevel: .PowerUser, for: user.ID)
        #expect(try await Logic.User.get(by: user.ID)?.accessLevel == .PowerUser)
        // Users unknown to Quorum are loaded from Author (a local stub here)
        await Logic.User.invalidate(ID: App.defaultUser)
        #expect(try await Logic.User.get(by: App.defaultUser)?.username == "teonoman")
    }

    @Test func authorNames() {
        #expect(Logic.User.isValidAuthorName("viktor"))
        #expect(Logic.User.isValidAuthorName("node-2"))
        #expect(!Logic.User.isValidAuthorName(""))
        #expect(!Logic.User.isValidAuthorName("evil.com"))
        #expect(!Logic.User.isValidAuthorName("a/b"))
        #expect(!Logic.User.isValidAuthorName("Viktor"))
        #expect(!Logic.User.isValidAuthorName(String(repeating: "a", count: 64)))
    }
}
