import Foundation
import Entita2FDB

public extension Models {
    final public class User: Model, Entita2FDBIndexedEntity {
        public enum AccessLevel: String, Codable {
            case User, Moderator, Admin
        }

        public static var IDKey: KeyPath<Models.User, E2.UUID> = \.ID

        public static let unknown = User(
            ID: E2.UUID("00000000-0000-0000-0000-000000000000")!,
            username: "Frank Strino",
            accessLevel: .User
        )

        public static var indices: [String : Entita2.Index<Models.User>] = [:]

        public let ID: E2.UUID

        // synchronizable from Author
        public var username: String
        public var accessLevel: AccessLevel

        public var mutedUntil: Date? = nil
        public var color: String = "default"

        public var isAtLeastModerator: Bool {
            return self.accessLevel == .Moderator || self.accessLevel == .Admin
        }

        public var isOrdinaryUser: Bool {
            return self.accessLevel == .User
        }

        public init(
            ID: E2.UUID,
            username: String,
            accessLevel: AccessLevel
        ) {
            self.ID = ID
            self.username = username
            self.accessLevel = accessLevel
        }
    }
}
