import Generated
import LGNCore
import LGNC

class CreatePostController {
    typealias Contract = SQuorum.Contracts.CreatePost

    static func setup() {
        Contract.guarantee { (request: Contract.Request, info: LGNC.RequestInfo) -> Future<Contract.Response> in
            Logic.User
                .authorize(token: request.token, on: info.eventLoop)
                .thenThrowing { user in
                    guard user.ID == adminUserID else {
                        throw LGNC.ContractError.GeneralError("You are not admin :P", 403)
                    }
                    return user
                }
                .then { (user: Models.User) in
                    Logic.Post
                        .get(by: request.IDPost, snapshot: true, on: info.eventLoop)
                        .map { (user, $0) }
                }
                .thenThrowing { user, maybePost in
                    guard maybePost == nil else {
                        throw LGNC.ContractError.GeneralError("Post with ID \(request.IDPost) already exists", 409)
                    }
                    return user
                }
                .then { (user: Models.User) in
                    Models.Post(ID: request.IDPost, IDUser: user.ID, isCommentable: true).save(on: info.eventLoop)
                }
                .map { Contract.Response() }
        }
    }
}
