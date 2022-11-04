import LGNC
import NIOHTTP1

public extension Models.User {
    @TaskLocal
    static var current: Models.User? = nil
}

class AuthWebSockeetRouter: LGNC.WebSocket.SimpleRouter {
    private var currentUser: Models.User? = nil

    override func shouldUpgrade(head: HTTPRequestHead) async throws -> HTTPHeaders? {
        let cookies = head.headers["Cookie"].parseCookies()

        func extract(_ param: String) throws -> LGNC.Entity.Cookie {
            guard
                let rawCookie = cookies[param],
                let cookie = LGNC.Entity.Cookie(header: rawCookie, defaultDomain: "")
            else {
                throw LGNC.E.ServiceError("No '\(param)' cookie")
            }
            return cookie
        }

//        self.currentUser = try await Logic.User.authenticate(
//            session: try extract("session").value,
//            portal: try extract("portal").value,
//            author: try extract("author").value
//        )

        return try await super.shouldUpgrade(head: head)
    }

    override func route(request: LGNC.WebSocket.Request) async throws -> LGNC.WebSocket.Response? {
        try await Models.User.$current.withValue(self.currentUser) {
            try await super.route(request: request)
        }
    }
}
