import Generated
import LGNCore
import LGNC

class RefreshUserController {
    static func setup() {
        typealias Contract = Services.Quorum.Contracts.RefreshUser

        func contractRoutine(
            request: Contract.Request,
            info: LGNCore.RequestInfo
        ) -> Future<Contract.Response> {
            let eventLoop = info.eventLoop
            return Logic.User
                .authorize(token: request.token, on: eventLoop)
                .flatMapThrowing { (user: Models.User) throws -> Future<Void> in
                    guard user.accessLevel == .Admin else {
                        throw LGNC.ContractError.GeneralError("Not authorized", 403)
                    }
                    guard let IDUser = Models.User.Identifier(request.IDUser) else {
                        throw LGNC.ContractError.GeneralError("Invalid user ID: \(request.IDUser)", 403)
                    }
                    return Logic.User.refresh(ID: IDUser, on: eventLoop)
                }
                .map { _ in Contract.Response() }
        }

        Contract.guarantee(contractRoutine)
    }
}
