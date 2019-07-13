import Foundation
import LGNCore
import Entita2FDB

public extension Models {
    final class User: Model, Entita2FDBIndexedEntity {
        public enum AccessLevel: String, Codable {
            case User
            case PowerUser
            case Moderator
            case Admin
        }

        public static var IDKey: KeyPath<Models.User, E2.UUID> = \.ID

        public static let unknown = User(
            ID: E2.UUID("00000000-0000-0000-0000-000000000000")!,
            username: "Frank Strino",
            accessLevel: .User
        )

        public static var indices: [String : Entita2.Index<Models.User>] = [
            "username": E2.Index(\.username, unique: true),
        ]

        public let ID: E2.UUID

        // synchronizable from Author
        public var username: String
        public var accessLevel: AccessLevel

        public var dateLastComment: Date
        public var mutedUntil: Date?
        public var color: String

        public var isAtLeastModerator: Bool {
            return self.accessLevel == .Moderator || self.accessLevel == .Admin
        }

        public var isOrdinaryUser: Bool {
            return self.accessLevel == .User
        }

        public var shouldSkipPremoderation: Bool {
            return self.isAtLeastModerator || self.accessLevel == .PowerUser
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

        public func set(accessLevel: AccessLevel, on eventLoop: EventLoop) -> Future<Void> {
            self.accessLevel = accessLevel

            return self.save(on: eventLoop)
        }
    }
}
