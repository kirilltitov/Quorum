import Entita2FDB

public extension Models {
    final public class Post: ModelInt {
        public static var IDKey: KeyPath<Models.Post, Int> = \.ID

        public static var fullEntityName = false

        public enum CodingKeys: String, CodingKey {
            case ID = "a"
            case IDUser = "b"
            case isCommentable = "c"
        }

        public let ID: Int
        public let IDUser: E2.UUID
        public var isCommentable: Bool

        public init(ID: Int, IDUser: E2.UUID, isCommentable: Bool) {
            self.ID = ID
            self.IDUser = IDUser
            self.isCommentable = isCommentable
        }
    }
}
