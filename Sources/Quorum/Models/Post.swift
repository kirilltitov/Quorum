import FDBEntity

public extension Models {
    enum Post {
        public typealias Identifier = Int

        public static let entityName = "post"
        public static var subspacePrefix: FDB.Subspace {
            return App.current.subspaceCounter[self.entityName]["comments"]
        }
    }
}
