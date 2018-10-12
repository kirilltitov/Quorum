import LGNC
import FDB
import NIO

Services.Quorum.guaranteeCreateContract { request, requestInfo in
    return Services.Quorum.Contracts.Create.Response()
}

try Services.Quorum.serveLGNS(
    salt: "foobar",
    key: "skjdhfjksdhfkjsd",
    requiredBitmask: [],
    readTimeout: .seconds(1),
    writeTimeout: .seconds(1)
)

