import LGNCore
import LGNC
import Generated

/// Returns comments counters for given posts IDs
public enum CommentsCountersController {
    typealias Contract = Services.Quorum.Contracts.CommentsCounters

    public static func setup() {
        Contract.guarantee { (request: Contract.Request, info: LGNCore.RequestInfo) -> Future<Contract.Response> in
            Logic.Post
                .getCommentCountersForPosts(IDs: request.IDs, on: info.eventLoop)
                .map { Contract.Response(counters: $0) }
        }
    }
}
