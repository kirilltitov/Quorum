import Foundation
import LGNCore
import FDB
import FDBEntity

public extension Models {
    struct User: Model, FDB.IndexedEntity, Sendable {
        public typealias Identifier = FDB.UUID

        public enum IndexKey: String, FDB.EntityIndexKey {
            case username

            /// This case is lcfirst (`Like`) and not `like` because of backward compatibility,
            /// as ucfirst version has been used before
            case Like
        }

        public enum AccessLevel: String, Codable, Sendable {
            case User
            case PowerUser
            case Moderator
            case Admin
        }

        public static var IDKey: KeyPath<Models.User, FDB.UUID> { \.ID }

        public static let unknown = User(
            ID: FDB.UUID("00000000-0000-0000-0000-000000000000")!,
            username: "Frank Strino",
            accessLevel: .User
        )

        public static let indices: [IndexKey: FDB.EntityIndex<Models.User>] = [
            .username: FDB.EntityIndex(\.username, unique: true),
        ]

        public let ID: FDB.UUID

        // synchronizable from Author
        public var username: String
        public var accessLevel: AccessLevel

        public var dateLastComment: Date
        public var mutedUntil: Date?
        public var color: String

        public var isAtLeastModerator: Bool {
            self.accessLevel == .Moderator || self.accessLevel == .Admin
        }

        public var isOrdinaryUser: Bool {
            self.accessLevel == .User
        }

        public var shouldSkipPremoderation: Bool {
            self.isAtLeastModerator || self.accessLevel == .PowerUser
        }

        public init(
            ID: FDB.UUID,
            username: String,
            accessLevel: AccessLevel
        ) {
            self.ID = ID
            self.username = username
            self.accessLevel = accessLevel

            self.mutedUntil = nil
            self.color = "default"
            self.dateLastComment = .distantPast
        }
    }
}
