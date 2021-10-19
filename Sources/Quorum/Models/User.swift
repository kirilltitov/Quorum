import Foundation
import LGNCore
import Entita2FDB

public extension Models {
    final class User: Model, Entita2FDBIndexedEntity, @unchecked Sendable {
        public typealias Identifier = E2.UUID

        public enum IndexKey: String, AnyIndexKey {
            case username

            /// This case is lcfirst (`Like`) and not `like` because of backward compatibility,
            /// as ucfirst version has been used before
            case Like
        }

        public enum AccessLevel: String, Codable {
            case User
            case PowerUser
            case Moderator
            case Admin
        }

        public static var IDKey: KeyPath<Models.User, E2.UUID> = \.ID
        public static var storage = App.current.fdb

        public static let unknown = User(
            ID: E2.UUID("00000000-0000-0000-0000-000000000000")!,
            username: "Frank Strino",
            accessLevel: .User
        )

        public static var indices: [IndexKey: Entita2.Index<Models.User>] = [
            .username: E2.Index(\.username, unique: true),
        ]

        public let ID: E2.UUID

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
            ID: E2.UUID,
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

        public func set(accessLevel: AccessLevel) async throws {
            self.accessLevel = accessLevel

            try await self.save()
        }
    }
}
