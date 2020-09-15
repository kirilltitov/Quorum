import Foundation
import Generated

func guaranteeLocalAuthorContracts() {
    SAuthor.Contracts.UserInfoInternal.guarantee { (request, context) throws -> Services.Shared.User in
        Services.Shared.User(
            ID: defaultUser.string,
            username: "teonoman",
            email: "teo.noman@gmail.com",
            password: "sdfdfg",
            sex: "Male",
            isBanned: false,
            ip: "195.248.161.225",
            country: "RU",
            dateUnsuccessfulLogin: Date.distantPast.formatted,
            dateSignup: Date().formatted,
            dateLogin: Date().formatted,
            authorName: "viktor",
            accessLevel: "Admin"
        )
    }

    SAuthor.Contracts.Authenticate.guarantee { (request, info) -> SAuthor.Contracts.Authenticate.Response in
        .init(IDUser: defaultUser.string)
    }
}
