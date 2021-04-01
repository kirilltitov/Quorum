import Entita2FDB

public extension Models {
    enum Post {
        public typealias Identifier = Int

        public static let entityName = "post"
        public static var subspacePrefix: FDB.Subspace {
            return subspaceCounter[self.entityName]["comments"]
        }
    }
}
