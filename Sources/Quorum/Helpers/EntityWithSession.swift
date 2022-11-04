import LGNC
import AsyncHTTPClient

public protocol AnyEntityWithSession {
    var session: LGNC.Entity.Cookie { get }
    var portal: LGNC.Entity.Cookie { get }
    var author: LGNC.Entity.Cookie { get }
}

public protocol AnyEntityWithMaybeSession {
    var session: LGNC.Entity.Cookie? { get }
    var portal: LGNC.Entity.Cookie? { get }
    var author: LGNC.Entity.Cookie? { get }
}
