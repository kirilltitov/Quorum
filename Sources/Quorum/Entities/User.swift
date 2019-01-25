import Entita2FDB

public extension Models {
    final public class User: Model {
        public static var IDKey: KeyPath<Models.User, E2.UUID> = \.ID

        public static let unknown = User(
            ID: E2.UUID("00000000-0000-0000-0000-000000000000")!,
            username: "Frank Strino",
            isAdmin: false
        )

        public let ID: E2.UUID
        public let username: String
        public let isAdmin: Bool

        public init(
            ID: E2.UUID,
            username: String,
            isAdmin: Bool = false
        ) {
            self.ID = ID
            self.username = username
            self.isAdmin = isAdmin
        }
    }
}
