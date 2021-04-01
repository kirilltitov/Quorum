import Foundation
import Generated
import LGNCore
import LGNS
import LGNC
import Entita2

fileprivate typealias Contract = Services.Quorum.Contracts.CreateComment

extension Contract.Request: AnyEntityWithSession {}

public struct CreateController {
    public static func setup() {
        Contract.Request.validateIDPost { ID in
            switch try await Logic.Post.getPostStatus(ID) {
            case .NotFound: return .PostNotFound
            case .NotCommentable: return .PostIsReadOnly
            default: return nil
            }
        }

        Contract.Request.validateIDReplyComment { ID in
            guard try await Logic.Comment.doExists(ID: ID) == true else {
                return .ReplyingCommentNotFound
            }
            return nil
        }

        Contract.guarantee { (request: Contract.Request) async throws -> Contract.Response in
            let user = try await Logic.User.authenticate(request: request)

            guard let IDPost = Logic.Post.decodeHash(ID: request.IDPost) else {
                throw LGNC.ContractError.GeneralError("Invalid post ID", 400)
            }

            let comment = Models.Comment(
                ID: try await Models.Comment.getNextID(),
                IDUser: user.ID,
                IDPost: IDPost,
                IDReplyComment: request.IDReplyComment,
                body: Logic.Comment.getProcessedBody(from: request.body)
            )
            try await Logic.Comment.insert(comment: comment, as: user)
            return try await comment.getContractComment()
        }
    }
}
