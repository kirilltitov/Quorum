import LGNCore
import LGNC
import Generated

/// Returns comments counters for given posts IDs
public enum CommentsCountersController {
    typealias Contract = Services.Quorum.Contracts.CommentsCounters

    public static func setup() {
        Contract.guarantee { (request: Contract.Request) async throws -> Contract.Response in
            Contract.Response(counters: try await Logic.Post.getCommentCountersForPosts(IDs: request.IDs))
        }
    }
}
