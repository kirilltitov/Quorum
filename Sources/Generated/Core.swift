import Entita
import LGNC
import LGNCore
import LGNP
import LGNS
import NIO

public struct Services {
    public typealias ContentType = LGNP.Message.ContentType

    public static let registry: LGNC.ServicesRegistry = [
        "Quorum": (
            transports: Services.Quorum.transports,
            contracts: [
                "Comments": (
                    visibility: Services.Quorum.Contracts.Comments.visibility,
                    transports: Services.Quorum.Contracts.Comments.transports
                ),
                "UnapprovedComments": (
                    visibility: Services.Quorum.Contracts.UnapprovedComments.visibility,
                    transports: Services.Quorum.Contracts.UnapprovedComments.transports
                ),
                "Create": (
                    visibility: Services.Quorum.Contracts.Create.visibility,
                    transports: Services.Quorum.Contracts.Create.transports
                ),
                "Edit": (
                    visibility: Services.Quorum.Contracts.Edit.visibility,
                    transports: Services.Quorum.Contracts.Edit.transports
                ),
                "Delete": (
                    visibility: Services.Quorum.Contracts.Delete.visibility,
                    transports: Services.Quorum.Contracts.Delete.transports
                ),
                "Undelete": (
                    visibility: Services.Quorum.Contracts.Undelete.visibility,
                    transports: Services.Quorum.Contracts.Undelete.transports
                ),
                "Like": (
                    visibility: Services.Quorum.Contracts.Like.visibility,
                    transports: Services.Quorum.Contracts.Like.transports
                ),
                "Approve": (
                    visibility: Services.Quorum.Contracts.Approve.visibility,
                    transports: Services.Quorum.Contracts.Approve.transports
                ),
                "Reject": (
                    visibility: Services.Quorum.Contracts.Reject.visibility,
                    transports: Services.Quorum.Contracts.Reject.transports
                ),
                "RefreshUser": (
                    visibility: Services.Quorum.Contracts.RefreshUser.visibility,
                    transports: Services.Quorum.Contracts.RefreshUser.transports
                ),
            ]
        ),
        "Author": (
            transports: Services.Author.transports,
            contracts: [
                "Checkin": (
                    visibility: Services.Author.Contracts.Checkin.visibility,
                    transports: Services.Author.Contracts.Checkin.transports
                ),
                "Ping": (
                    visibility: Services.Author.Contracts.Ping.visibility,
                    transports: Services.Author.Contracts.Ping.transports
                ),
                "Signup": (
                    visibility: Services.Author.Contracts.Signup.visibility,
                    transports: Services.Author.Contracts.Signup.transports
                ),
                "Login": (
                    visibility: Services.Author.Contracts.Login.visibility,
                    transports: Services.Author.Contracts.Login.transports
                ),
                "InternalSignup": (
                    visibility: Services.Author.Contracts.InternalSignup.visibility,
                    transports: Services.Author.Contracts.InternalSignup.transports
                ),
                "InternalLogin": (
                    visibility: Services.Author.Contracts.InternalLogin.visibility,
                    transports: Services.Author.Contracts.InternalLogin.transports
                ),
                "UserInfo": (
                    visibility: Services.Author.Contracts.UserInfo.visibility,
                    transports: Services.Author.Contracts.UserInfo.transports
                ),
                "Authenticate": (
                    visibility: Services.Author.Contracts.Authenticate.visibility,
                    transports: Services.Author.Contracts.Authenticate.transports
                ),
            ]
        ),
    ]

    public struct Shared {
        public final class FieldMapping: ContractEntity {
            public static let keyDictionary: [String: String] = [
                :
            ]

            public let map: [String: String]

            public init(
                map: [String: String] = [String: String]()
            ) {
                self.map = map
            }

            public static func initWithValidation(from dictionary: Entita.Dict, on eventLoop: EventLoop) -> Future<FieldMapping> {
                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "map": [],
                ]

                var _map: [String: String] = [String: String]()

                do {
                    do {
                        _map = try FieldMapping.extract(param: "map", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["map"]!.append(eventLoop.newSucceededFuture(result: ("map", Validation.Error.MissingValue())))
                    }
                } catch {
                    return eventLoop.newFailedFuture(error: error)
                }

                return self.reduce(
                    validators: validatorFutures,
                    on: eventLoop
                ).thenThrowing { errors in
                    guard errors.count == 0 else {
                        throw LGNC.E.DecodeError(errors)
                    }
                    return self.init(
                        map: _map
                    )
                }
            }

            public convenience init(from dictionary: Entita.Dict) throws {
                self.init(
                    map: try FieldMapping.extract(param: "map", from: dictionary)
                )
            }

            public func getDictionary() throws -> Entita.Dict {
                return [
                    self.getDictionaryKey("map"): try self.encode(self.map),
                ]
            }
        }

        public final class ServiceFieldMapping: ContractEntity {
            public static let keyDictionary: [String: String] = [
                :
            ]

            public let Request: FieldMapping
            public let Response: FieldMapping

            public init(
                Request: FieldMapping,
                Response: FieldMapping
            ) {
                self.Request = Request
                self.Response = Response
            }

            public static func initWithValidation(from dictionary: Entita.Dict, on eventLoop: EventLoop) -> Future<ServiceFieldMapping> {
                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "Request": [],
                    "Response": [],
                ]

                var _Request: FieldMapping = FieldMapping()
                var _Response: FieldMapping = FieldMapping()

                do {
                    do {
                        _Request = try ServiceFieldMapping.extract(param: "Request", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["Request"]!.append(eventLoop.newSucceededFuture(result: ("Request", Validation.Error.MissingValue())))
                    }
                    do {
                        _Response = try ServiceFieldMapping.extract(param: "Response", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["Response"]!.append(eventLoop.newSucceededFuture(result: ("Response", Validation.Error.MissingValue())))
                    }
                } catch {
                    return eventLoop.newFailedFuture(error: error)
                }

                return self.reduce(
                    validators: validatorFutures,
                    on: eventLoop
                ).thenThrowing { errors in
                    guard errors.count == 0 else {
                        throw LGNC.E.DecodeError(errors)
                    }
                    return self.init(
                        Request: _Request,
                        Response: _Response
                    )
                }
            }

            public convenience init(from dictionary: Entita.Dict) throws {
                self.init(
                    Request: try ServiceFieldMapping.extract(param: "Request", from: dictionary),
                    Response: try ServiceFieldMapping.extract(param: "Response", from: dictionary)
                )
            }

            public func getDictionary() throws -> Entita.Dict {
                return [
                    self.getDictionaryKey("Request"): try self.encode(self.Request),
                    self.getDictionaryKey("Response"): try self.encode(self.Response),
                ]
            }
        }

        public final class ServiceFieldMappings: ContractEntity {
            public static let keyDictionary: [String: String] = [
                :
            ]

            public let map: [String: ServiceFieldMapping]

            public init(
                map: [String: ServiceFieldMapping]
            ) {
                self.map = map
            }

            public static func initWithValidation(from dictionary: Entita.Dict, on eventLoop: EventLoop) -> Future<ServiceFieldMappings> {
                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "map": [],
                ]

                var _map: [String: ServiceFieldMapping] = [String: ServiceFieldMapping]()

                do {
                    do {
                        _map = try ServiceFieldMappings.extract(param: "map", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["map"]!.append(eventLoop.newSucceededFuture(result: ("map", Validation.Error.MissingValue())))
                    }
                } catch {
                    return eventLoop.newFailedFuture(error: error)
                }

                return self.reduce(
                    validators: validatorFutures,
                    on: eventLoop
                ).thenThrowing { errors in
                    guard errors.count == 0 else {
                        throw LGNC.E.DecodeError(errors)
                    }
                    return self.init(
                        map: _map
                    )
                }
            }

            public convenience init(from dictionary: Entita.Dict) throws {
                self.init(
                    map: try ServiceFieldMappings.extract(param: "map", from: dictionary)
                )
            }

            public func getDictionary() throws -> Entita.Dict {
                return [
                    self.getDictionaryKey("map"): try self.encode(self.map),
                ]
            }
        }

        public final class CharacterInfo: ContractEntity {
            public static let keyDictionary: [String: String] = [
                "monad": "b",
            ]

            public let monad: String

            public init(
                monad: String
            ) {
                self.monad = monad
            }

            public static func initWithValidation(from dictionary: Entita.Dict, on eventLoop: EventLoop) -> Future<CharacterInfo> {
                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "monad": [],
                ]

                var _monad: String = String()

                do {
                    do {
                        _monad = try CharacterInfo.extract(param: "monad", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["monad"]!.append(eventLoop.newSucceededFuture(result: ("monad", Validation.Error.MissingValue())))
                    }
                } catch {
                    return eventLoop.newFailedFuture(error: error)
                }

                return self.reduce(
                    validators: validatorFutures,
                    on: eventLoop
                ).thenThrowing { errors in
                    guard errors.count == 0 else {
                        throw LGNC.E.DecodeError(errors)
                    }
                    return self.init(
                        monad: _monad
                    )
                }
            }

            public convenience init(from dictionary: Entita.Dict) throws {
                self.init(
                    monad: try CharacterInfo.extract(param: "monad", from: dictionary)
                )
            }

            public func getDictionary() throws -> Entita.Dict {
                return [
                    self.getDictionaryKey("monad"): try self.encode(self.monad),
                ]
            }
        }

        public final class UserSignupRequest: ContractEntity {
            public enum CallbackValidatorUsernameAllowedValues: String, CallbackWithAllowedValuesRepresentable, ValidatorErrorRepresentable {
                public typealias InputValue = String

                case UserWithGivenUsernameAlreadyExists = "User with given username already exists"

                public func getErrorTuple() -> (message: String, code: Int) {
                    switch self {
                    case .UserWithGivenUsernameAlreadyExists: return (message: self.rawValue, code: 10001)
                    }
                }
            }

            public enum CallbackValidatorEmailAllowedValues: String, CallbackWithAllowedValuesRepresentable, ValidatorErrorRepresentable {
                public typealias InputValue = String

                case UserWithGivenEmailAlreadyExists = "User with given email already exists"

                public func getErrorTuple() -> (message: String, code: Int) {
                    switch self {
                    case .UserWithGivenEmailAlreadyExists: return (message: self.rawValue, code: 10001)
                    }
                }
            }

            public static let keyDictionary: [String: String] = [
                "username": "b",
                "email": "c",
                "password1": "d",
                "password2": "e",
                "sex": "f",
            ]

            public let username: String
            public let email: String
            public let password1: String
            public let password2: String
            public let sex: String

            private static var validatorUsernameClosure: Validation.CallbackWithAllowedValues<CallbackValidatorUsernameAllowedValues>.Callback?
            private static var validatorEmailClosure: Validation.CallbackWithAllowedValues<CallbackValidatorEmailAllowedValues>.Callback?

            public init(
                username: String,
                email: String,
                password1: String,
                password2: String,
                sex: String
            ) {
                self.username = username
                self.email = email
                self.password1 = password1
                self.password2 = password2
                self.sex = sex
            }

            public static func initWithValidation(from dictionary: Entita.Dict, on eventLoop: EventLoop) -> Future<UserSignupRequest> {
                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "username": [],
                    "email": [],
                    "password1": [],
                    "password2": [],
                    "sex": [],
                ]

                var _username: String = String()
                var _email: String = String()
                var _password1: String = String()
                var _password2: String = String()
                var _sex: String = String()

                do {
                    do {
                        _username = try UserSignupRequest.extract(param: "username", from: dictionary)

                        if let error = Validation.Regexp(pattern: "^[a-zA-Zа-яА-Я0-9_\\- ]+$", message: "Username must only consist of letters, numbers and underscores").validate(input: _username) {
                            validatorFutures["username"]!.append(eventLoop.newSucceededFuture(result: ("username", error)))
                        }

                        if let error = Validation.Length.Min(length: 3).validate(input: _username) {
                            validatorFutures["username"]!.append(eventLoop.newSucceededFuture(result: ("username", error)))
                        }

                        if let error = Validation.Length.Max(length: 24).validate(input: _username) {
                            validatorFutures["username"]!.append(eventLoop.newSucceededFuture(result: ("username", error)))
                        }

                        if let validatorUsernameClosure = self.validatorUsernameClosure {
                            validatorFutures["username"]!.append(
                                Validation.CallbackWithAllowedValues<CallbackValidatorUsernameAllowedValues>(callback: validatorUsernameClosure).validate(
                                    input: _username,
                                    on: eventLoop
                                ).map { ("username", $0) }
                            )
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["username"]!.append(eventLoop.newSucceededFuture(result: ("username", Validation.Error.MissingValue())))
                    }
                    do {
                        _email = try UserSignupRequest.extract(param: "email", from: dictionary)

                        if let error = Validation.Regexp(pattern: "^.+@.+\\..+$", message: "Invalid email format").validate(input: _email) {
                            validatorFutures["email"]!.append(eventLoop.newSucceededFuture(result: ("email", error)))
                        }

                        if let validatorEmailClosure = self.validatorEmailClosure {
                            validatorFutures["email"]!.append(
                                Validation.CallbackWithAllowedValues<CallbackValidatorEmailAllowedValues>(callback: validatorEmailClosure).validate(
                                    input: _email,
                                    on: eventLoop
                                ).map { ("email", $0) }
                            )
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["email"]!.append(eventLoop.newSucceededFuture(result: ("email", Validation.Error.MissingValue())))
                    }
                    do {
                        _password1 = try UserSignupRequest.extract(param: "password1", from: dictionary)

                        if let error = Validation.Length.Min(length: 6).validate(input: _password1) {
                            validatorFutures["password1"]!.append(eventLoop.newSucceededFuture(result: ("password1", error)))
                        }

                        if let error = Validation.Length.Max(length: 64, message: "Password must be less than 64 characters long").validate(input: _password1) {
                            validatorFutures["password1"]!.append(eventLoop.newSucceededFuture(result: ("password1", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["password1"]!.append(eventLoop.newSucceededFuture(result: ("password1", Validation.Error.MissingValue())))
                    }
                    do {
                        _password2 = try UserSignupRequest.extract(param: "password2", from: dictionary)

                        if let error = Validation.Identical(right: _password1, message: "Passwords must match").validate(input: _password2) {
                            validatorFutures["password2"]!.append(eventLoop.newSucceededFuture(result: ("password2", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["password2"]!.append(eventLoop.newSucceededFuture(result: ("password2", Validation.Error.MissingValue())))
                    }
                    do {
                        _sex = try UserSignupRequest.extract(param: "sex", from: dictionary)

                        if let error = Validation.In(allowedValues: ["Male", "Female", "Attack helicopter"]).validate(input: _sex) {
                            validatorFutures["sex"]!.append(eventLoop.newSucceededFuture(result: ("sex", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["sex"]!.append(eventLoop.newSucceededFuture(result: ("sex", Validation.Error.MissingValue())))
                    }
                } catch {
                    return eventLoop.newFailedFuture(error: error)
                }

                return self.reduce(
                    validators: validatorFutures,
                    on: eventLoop
                ).thenThrowing { errors in
                    guard errors.count == 0 else {
                        throw LGNC.E.DecodeError(errors)
                    }
                    return self.init(
                        username: _username,
                        email: _email,
                        password1: _password1,
                        password2: _password2,
                        sex: _sex
                    )
                }
            }

            public convenience init(from dictionary: Entita.Dict) throws {
                self.init(
                    username: try UserSignupRequest.extract(param: "username", from: dictionary),
                    email: try UserSignupRequest.extract(param: "email", from: dictionary),
                    password1: try UserSignupRequest.extract(param: "password1", from: dictionary),
                    password2: try UserSignupRequest.extract(param: "password2", from: dictionary),
                    sex: try UserSignupRequest.extract(param: "sex", from: dictionary)
                )
            }

            public func getDictionary() throws -> Entita.Dict {
                return [
                    self.getDictionaryKey("username"): try self.encode(self.username),
                    self.getDictionaryKey("email"): try self.encode(self.email),
                    self.getDictionaryKey("password1"): try self.encode(self.password1),
                    self.getDictionaryKey("password2"): try self.encode(self.password2),
                    self.getDictionaryKey("sex"): try self.encode(self.sex),
                ]
            }

            public static func validateUsername(
                _ callback: @escaping Validation.CallbackWithAllowedValues<CallbackValidatorUsernameAllowedValues>.Callback
            ) {
                self.validatorUsernameClosure = callback
            }

            public static func validateEmail(
                _ callback: @escaping Validation.CallbackWithAllowedValues<CallbackValidatorEmailAllowedValues>.Callback
            ) {
                self.validatorEmailClosure = callback
            }
        }

        public final class UserSignupResponse: ContractEntity {
            public static let keyDictionary: [String: String] = [
                "ID": "a",
                "username": "c",
                "email": "d",
                "sex": "e",
                "ip": "f",
                "country": "g",
                "dateSignup": "h",
                "dateLogin": "i",
                "currentCharacter": "j",
                "authorName": "k",
                "accessLevel": "l",
                "characters": "m",
                "token": "n",
            ]

            public let ID: String
            public let username: String
            public let email: String
            public let sex: String
            public let ip: String
            public let country: String
            public let dateSignup: String
            public let dateLogin: String
            public let currentCharacter: String?
            public let authorName: String
            public let accessLevel: String
            public let characters: [String: CharacterInfo]
            public let token: String

            public init(
                ID: String,
                username: String,
                email: String,
                sex: String,
                ip: String,
                country: String,
                dateSignup: String,
                dateLogin: String,
                currentCharacter: String? = nil,
                authorName: String,
                accessLevel: String,
                characters: [String: CharacterInfo] = [String: CharacterInfo](),
                token: String
            ) {
                self.ID = ID
                self.username = username
                self.email = email
                self.sex = sex
                self.ip = ip
                self.country = country
                self.dateSignup = dateSignup
                self.dateLogin = dateLogin
                self.currentCharacter = currentCharacter
                self.authorName = authorName
                self.accessLevel = accessLevel
                self.characters = characters
                self.token = token
            }

            public static func initWithValidation(from dictionary: Entita.Dict, on eventLoop: EventLoop) -> Future<UserSignupResponse> {
                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "ID": [],
                    "username": [],
                    "email": [],
                    "sex": [],
                    "ip": [],
                    "country": [],
                    "dateSignup": [],
                    "dateLogin": [],
                    "currentCharacter": [],
                    "authorName": [],
                    "accessLevel": [],
                    "characters": [],
                    "token": [],
                ]

                var _ID: String = String()
                var _username: String = String()
                var _email: String = String()
                var _sex: String = String()
                var _ip: String = String()
                var _country: String = String()
                var _dateSignup: String = String()
                var _dateLogin: String = String()
                var _currentCharacter: String?
                var _authorName: String = String()
                var _accessLevel: String = String()
                var _characters: [String: CharacterInfo] = [String: CharacterInfo]()
                var _token: String = String()

                do {
                    do {
                        _ID = try UserSignupResponse.extract(param: "ID", from: dictionary)

                        if let error = Validation.UUID().validate(input: _ID) {
                            validatorFutures["ID"]!.append(eventLoop.newSucceededFuture(result: ("ID", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["ID"]!.append(eventLoop.newSucceededFuture(result: ("ID", Validation.Error.MissingValue())))
                    }
                    do {
                        _username = try UserSignupResponse.extract(param: "username", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["username"]!.append(eventLoop.newSucceededFuture(result: ("username", Validation.Error.MissingValue())))
                    }
                    do {
                        _email = try UserSignupResponse.extract(param: "email", from: dictionary)

                        if let error = Validation.Regexp(pattern: "^.+@.+\\..+$", message: "Invalid email format").validate(input: _email) {
                            validatorFutures["email"]!.append(eventLoop.newSucceededFuture(result: ("email", error)))
                        }

                        if let error = Validation.Length.Min(length: 6).validate(input: _email) {
                            validatorFutures["email"]!.append(eventLoop.newSucceededFuture(result: ("email", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["email"]!.append(eventLoop.newSucceededFuture(result: ("email", Validation.Error.MissingValue())))
                    }
                    do {
                        _sex = try UserSignupResponse.extract(param: "sex", from: dictionary)

                        if let error = Validation.In(allowedValues: ["Male", "Female", "Attack helicopter"]).validate(input: _sex) {
                            validatorFutures["sex"]!.append(eventLoop.newSucceededFuture(result: ("sex", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["sex"]!.append(eventLoop.newSucceededFuture(result: ("sex", Validation.Error.MissingValue())))
                    }
                    do {
                        _ip = try UserSignupResponse.extract(param: "ip", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["ip"]!.append(eventLoop.newSucceededFuture(result: ("ip", Validation.Error.MissingValue())))
                    }
                    do {
                        _country = try UserSignupResponse.extract(param: "country", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["country"]!.append(eventLoop.newSucceededFuture(result: ("country", Validation.Error.MissingValue())))
                    }
                    do {
                        _dateSignup = try UserSignupResponse.extract(param: "dateSignup", from: dictionary)

                        if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(input: _dateSignup) {
                            validatorFutures["dateSignup"]!.append(eventLoop.newSucceededFuture(result: ("dateSignup", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["dateSignup"]!.append(eventLoop.newSucceededFuture(result: ("dateSignup", Validation.Error.MissingValue())))
                    }
                    do {
                        _dateLogin = try UserSignupResponse.extract(param: "dateLogin", from: dictionary)

                        if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(input: _dateLogin) {
                            validatorFutures["dateLogin"]!.append(eventLoop.newSucceededFuture(result: ("dateLogin", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["dateLogin"]!.append(eventLoop.newSucceededFuture(result: ("dateLogin", Validation.Error.MissingValue())))
                    }
                    do {
                        _currentCharacter = try UserSignupResponse.extract(param: "currentCharacter", from: dictionary, isOptional: true)
                    } catch Entita.E.ExtractError {
                        validatorFutures["currentCharacter"]!.append(eventLoop.newSucceededFuture(result: ("currentCharacter", Validation.Error.MissingValue())))
                    }
                    do {
                        _authorName = try UserSignupResponse.extract(param: "authorName", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["authorName"]!.append(eventLoop.newSucceededFuture(result: ("authorName", Validation.Error.MissingValue())))
                    }
                    do {
                        _accessLevel = try UserSignupResponse.extract(param: "accessLevel", from: dictionary)

                        if let error = Validation.In(allowedValues: ["User", "Moderator", "Admin"]).validate(input: _accessLevel) {
                            validatorFutures["accessLevel"]!.append(eventLoop.newSucceededFuture(result: ("accessLevel", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["accessLevel"]!.append(eventLoop.newSucceededFuture(result: ("accessLevel", Validation.Error.MissingValue())))
                    }
                    do {
                        _characters = try UserSignupResponse.extract(param: "characters", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["characters"]!.append(eventLoop.newSucceededFuture(result: ("characters", Validation.Error.MissingValue())))
                    }
                    do {
                        _token = try UserSignupResponse.extract(param: "token", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["token"]!.append(eventLoop.newSucceededFuture(result: ("token", Validation.Error.MissingValue())))
                    }
                } catch {
                    return eventLoop.newFailedFuture(error: error)
                }

                return self.reduce(
                    validators: validatorFutures,
                    on: eventLoop
                ).thenThrowing { errors in
                    guard errors.count == 0 else {
                        throw LGNC.E.DecodeError(errors)
                    }
                    return self.init(
                        ID: _ID,
                        username: _username,
                        email: _email,
                        sex: _sex,
                        ip: _ip,
                        country: _country,
                        dateSignup: _dateSignup,
                        dateLogin: _dateLogin,
                        currentCharacter: _currentCharacter,
                        authorName: _authorName,
                        accessLevel: _accessLevel,
                        characters: _characters,
                        token: _token
                    )
                }
            }

            public convenience init(from dictionary: Entita.Dict) throws {
                self.init(
                    ID: try UserSignupResponse.extract(param: "ID", from: dictionary),
                    username: try UserSignupResponse.extract(param: "username", from: dictionary),
                    email: try UserSignupResponse.extract(param: "email", from: dictionary),
                    sex: try UserSignupResponse.extract(param: "sex", from: dictionary),
                    ip: try UserSignupResponse.extract(param: "ip", from: dictionary),
                    country: try UserSignupResponse.extract(param: "country", from: dictionary),
                    dateSignup: try UserSignupResponse.extract(param: "dateSignup", from: dictionary),
                    dateLogin: try UserSignupResponse.extract(param: "dateLogin", from: dictionary),
                    currentCharacter: try UserSignupResponse.extract(param: "currentCharacter", from: dictionary, isOptional: true),
                    authorName: try UserSignupResponse.extract(param: "authorName", from: dictionary),
                    accessLevel: try UserSignupResponse.extract(param: "accessLevel", from: dictionary),
                    characters: try UserSignupResponse.extract(param: "characters", from: dictionary),
                    token: try UserSignupResponse.extract(param: "token", from: dictionary)
                )
            }

            public func getDictionary() throws -> Entita.Dict {
                return [
                    self.getDictionaryKey("ID"): try self.encode(self.ID),
                    self.getDictionaryKey("username"): try self.encode(self.username),
                    self.getDictionaryKey("email"): try self.encode(self.email),
                    self.getDictionaryKey("sex"): try self.encode(self.sex),
                    self.getDictionaryKey("ip"): try self.encode(self.ip),
                    self.getDictionaryKey("country"): try self.encode(self.country),
                    self.getDictionaryKey("dateSignup"): try self.encode(self.dateSignup),
                    self.getDictionaryKey("dateLogin"): try self.encode(self.dateLogin),
                    self.getDictionaryKey("currentCharacter"): try self.encode(self.currentCharacter),
                    self.getDictionaryKey("authorName"): try self.encode(self.authorName),
                    self.getDictionaryKey("accessLevel"): try self.encode(self.accessLevel),
                    self.getDictionaryKey("characters"): try self.encode(self.characters),
                    self.getDictionaryKey("token"): try self.encode(self.token),
                ]
            }
        }

        public final class NodeInfo: ContractEntity {
            public enum CallbackValidatorNameAllowedValues: String, CallbackWithAllowedValuesRepresentable, ValidatorErrorRepresentable {
                public typealias InputValue = String

                case NodeWithGivenNameAlreadyCheckedIn = "Node with given name already checked in"

                public func getErrorTuple() -> (message: String, code: Int) {
                    switch self {
                    case .NodeWithGivenNameAlreadyCheckedIn: return (message: self.rawValue, code: 409)
                    }
                }
            }

            public static let keyDictionary: [String: String] = [
                "type": "b",
                "name": "c",
                "port": "d",
            ]

            public let type: String
            public let name: String
            public let port: Int

            private static var validatorNameClosure: Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>.Callback?

            public init(
                type: String,
                name: String,
                port: Int
            ) {
                self.type = type
                self.name = name
                self.port = port
            }

            public static func initWithValidation(from dictionary: Entita.Dict, on eventLoop: EventLoop) -> Future<NodeInfo> {
                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "type": [],
                    "name": [],
                    "port": [],
                ]

                var _type: String = String()
                var _name: String = String()
                var _port: Int = Int()

                do {
                    do {
                        _type = try NodeInfo.extract(param: "type", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["type"]!.append(eventLoop.newSucceededFuture(result: ("type", Validation.Error.MissingValue())))
                    }
                    do {
                        _name = try NodeInfo.extract(param: "name", from: dictionary)

                        if let validatorNameClosure = self.validatorNameClosure {
                            validatorFutures["name"]!.append(
                                Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>(callback: validatorNameClosure).validate(
                                    input: _name,
                                    on: eventLoop
                                ).map { ("name", $0) }
                            )
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["name"]!.append(eventLoop.newSucceededFuture(result: ("name", Validation.Error.MissingValue())))
                    }
                    do {
                        _port = try NodeInfo.extract(param: "port", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["port"]!.append(eventLoop.newSucceededFuture(result: ("port", Validation.Error.MissingValue())))
                    }
                } catch {
                    return eventLoop.newFailedFuture(error: error)
                }

                return self.reduce(
                    validators: validatorFutures,
                    on: eventLoop
                ).thenThrowing { errors in
                    guard errors.count == 0 else {
                        throw LGNC.E.DecodeError(errors)
                    }
                    return self.init(
                        type: _type,
                        name: _name,
                        port: _port
                    )
                }
            }

            public convenience init(from dictionary: Entita.Dict) throws {
                self.init(
                    type: try NodeInfo.extract(param: "type", from: dictionary),
                    name: try NodeInfo.extract(param: "name", from: dictionary),
                    port: try NodeInfo.extract(param: "port", from: dictionary)
                )
            }

            public func getDictionary() throws -> Entita.Dict {
                return [
                    self.getDictionaryKey("type"): try self.encode(self.type),
                    self.getDictionaryKey("name"): try self.encode(self.name),
                    self.getDictionaryKey("port"): try self.encode(self.port),
                ]
            }

            public static func validateName(
                _ callback: @escaping Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>.Callback
            ) {
                self.validatorNameClosure = callback
            }
        }

        public final class PingRequest: ContractEntity {
            public enum CallbackValidatorNameAllowedValues: String, CallbackWithAllowedValuesRepresentable, ValidatorErrorRepresentable {
                public typealias InputValue = String

                case NodeWithGivenNameIsNotCheckedIn = "Node with given name is not checked in"

                public func getErrorTuple() -> (message: String, code: Int) {
                    switch self {
                    case .NodeWithGivenNameIsNotCheckedIn: return (message: self.rawValue, code: 404)
                    }
                }
            }

            public static let keyDictionary: [String: String] = [
                "name": "b",
                "entities": "c",
            ]

            public let name: String
            public let entities: Int

            private static var validatorNameClosure: Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>.Callback?

            public init(
                name: String,
                entities: Int
            ) {
                self.name = name
                self.entities = entities
            }

            public static func initWithValidation(from dictionary: Entita.Dict, on eventLoop: EventLoop) -> Future<PingRequest> {
                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "name": [],
                    "entities": [],
                ]

                var _name: String = String()
                var _entities: Int = Int()

                do {
                    do {
                        _name = try PingRequest.extract(param: "name", from: dictionary)

                        if let validatorNameClosure = self.validatorNameClosure {
                            validatorFutures["name"]!.append(
                                Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>(callback: validatorNameClosure).validate(
                                    input: _name,
                                    on: eventLoop
                                ).map { ("name", $0) }
                            )
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["name"]!.append(eventLoop.newSucceededFuture(result: ("name", Validation.Error.MissingValue())))
                    }
                    do {
                        _entities = try PingRequest.extract(param: "entities", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["entities"]!.append(eventLoop.newSucceededFuture(result: ("entities", Validation.Error.MissingValue())))
                    }
                } catch {
                    return eventLoop.newFailedFuture(error: error)
                }

                return self.reduce(
                    validators: validatorFutures,
                    on: eventLoop
                ).thenThrowing { errors in
                    guard errors.count == 0 else {
                        throw LGNC.E.DecodeError(errors)
                    }
                    return self.init(
                        name: _name,
                        entities: _entities
                    )
                }
            }

            public convenience init(from dictionary: Entita.Dict) throws {
                self.init(
                    name: try PingRequest.extract(param: "name", from: dictionary),
                    entities: try PingRequest.extract(param: "entities", from: dictionary)
                )
            }

            public func getDictionary() throws -> Entita.Dict {
                return [
                    self.getDictionaryKey("name"): try self.encode(self.name),
                    self.getDictionaryKey("entities"): try self.encode(self.entities),
                ]
            }

            public static func validateName(
                _ callback: @escaping Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>.Callback
            ) {
                self.validatorNameClosure = callback
            }
        }

        public final class PingResponse: ContractEntity {
            public static let keyDictionary: [String: String] = [
                "result": "b",
            ]

            public let result: String

            public init(
                result: String
            ) {
                self.result = result
            }

            public static func initWithValidation(from dictionary: Entita.Dict, on eventLoop: EventLoop) -> Future<PingResponse> {
                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "result": [],
                ]

                var _result: String = String()

                do {
                    do {
                        _result = try PingResponse.extract(param: "result", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["result"]!.append(eventLoop.newSucceededFuture(result: ("result", Validation.Error.MissingValue())))
                    }
                } catch {
                    return eventLoop.newFailedFuture(error: error)
                }

                return self.reduce(
                    validators: validatorFutures,
                    on: eventLoop
                ).thenThrowing { errors in
                    guard errors.count == 0 else {
                        throw LGNC.E.DecodeError(errors)
                    }
                    return self.init(
                        result: _result
                    )
                }
            }

            public convenience init(from dictionary: Entita.Dict) throws {
                self.init(
                    result: try PingResponse.extract(param: "result", from: dictionary)
                )
            }

            public func getDictionary() throws -> Entita.Dict {
                return [
                    self.getDictionaryKey("result"): try self.encode(self.result),
                ]
            }
        }

        public final class CheckinRequest: ContractEntity {
            public enum CallbackValidatorNameAllowedValues: String, CallbackWithAllowedValuesRepresentable, ValidatorErrorRepresentable {
                public typealias InputValue = String

                case NodeWithGivenNameAlreadyCheckedIn = "Node with given name already checked in"

                public func getErrorTuple() -> (message: String, code: Int) {
                    switch self {
                    case .NodeWithGivenNameAlreadyCheckedIn: return (message: self.rawValue, code: 409)
                    }
                }
            }

            public static let keyDictionary: [String: String] = [
                "type": "b",
                "name": "c",
                "port": "d",
                "entities": "e",
            ]

            public let type: String
            public let name: String
            public let port: Int
            public let entities: Int

            private static var validatorNameClosure: Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>.Callback?

            public init(
                type: String,
                name: String,
                port: Int,
                entities: Int
            ) {
                self.type = type
                self.name = name
                self.port = port
                self.entities = entities
            }

            public static func initWithValidation(from dictionary: Entita.Dict, on eventLoop: EventLoop) -> Future<CheckinRequest> {
                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "type": [],
                    "name": [],
                    "port": [],
                    "entities": [],
                ]

                var _type: String = String()
                var _name: String = String()
                var _port: Int = Int()
                var _entities: Int = Int()

                do {
                    do {
                        _type = try CheckinRequest.extract(param: "type", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["type"]!.append(eventLoop.newSucceededFuture(result: ("type", Validation.Error.MissingValue())))
                    }
                    do {
                        _name = try CheckinRequest.extract(param: "name", from: dictionary)

                        if let validatorNameClosure = self.validatorNameClosure {
                            validatorFutures["name"]!.append(
                                Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>(callback: validatorNameClosure).validate(
                                    input: _name,
                                    on: eventLoop
                                ).map { ("name", $0) }
                            )
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["name"]!.append(eventLoop.newSucceededFuture(result: ("name", Validation.Error.MissingValue())))
                    }
                    do {
                        _port = try CheckinRequest.extract(param: "port", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["port"]!.append(eventLoop.newSucceededFuture(result: ("port", Validation.Error.MissingValue())))
                    }
                    do {
                        _entities = try CheckinRequest.extract(param: "entities", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["entities"]!.append(eventLoop.newSucceededFuture(result: ("entities", Validation.Error.MissingValue())))
                    }
                } catch {
                    return eventLoop.newFailedFuture(error: error)
                }

                return self.reduce(
                    validators: validatorFutures,
                    on: eventLoop
                ).thenThrowing { errors in
                    guard errors.count == 0 else {
                        throw LGNC.E.DecodeError(errors)
                    }
                    return self.init(
                        type: _type,
                        name: _name,
                        port: _port,
                        entities: _entities
                    )
                }
            }

            public convenience init(from dictionary: Entita.Dict) throws {
                self.init(
                    type: try CheckinRequest.extract(param: "type", from: dictionary),
                    name: try CheckinRequest.extract(param: "name", from: dictionary),
                    port: try CheckinRequest.extract(param: "port", from: dictionary),
                    entities: try CheckinRequest.extract(param: "entities", from: dictionary)
                )
            }

            public func getDictionary() throws -> Entita.Dict {
                return [
                    self.getDictionaryKey("type"): try self.encode(self.type),
                    self.getDictionaryKey("name"): try self.encode(self.name),
                    self.getDictionaryKey("port"): try self.encode(self.port),
                    self.getDictionaryKey("entities"): try self.encode(self.entities),
                ]
            }

            public static func validateName(
                _ callback: @escaping Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>.Callback
            ) {
                self.validatorNameClosure = callback
            }
        }

        public final class CheckinResponse: ContractEntity {
            public static let keyDictionary: [String: String] = [
                "result": "b",
            ]

            public let result: String

            public init(
                result: String
            ) {
                self.result = result
            }

            public static func initWithValidation(from dictionary: Entita.Dict, on eventLoop: EventLoop) -> Future<CheckinResponse> {
                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "result": [],
                ]

                var _result: String = String()

                do {
                    do {
                        _result = try CheckinResponse.extract(param: "result", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["result"]!.append(eventLoop.newSucceededFuture(result: ("result", Validation.Error.MissingValue())))
                    }
                } catch {
                    return eventLoop.newFailedFuture(error: error)
                }

                return self.reduce(
                    validators: validatorFutures,
                    on: eventLoop
                ).thenThrowing { errors in
                    guard errors.count == 0 else {
                        throw LGNC.E.DecodeError(errors)
                    }
                    return self.init(
                        result: _result
                    )
                }
            }

            public convenience init(from dictionary: Entita.Dict) throws {
                self.init(
                    result: try CheckinResponse.extract(param: "result", from: dictionary)
                )
            }

            public func getDictionary() throws -> Entita.Dict {
                return [
                    self.getDictionaryKey("result"): try self.encode(self.result),
                ]
            }
        }

        public final class LoginRequest: ContractEntity {
            public static let keyDictionary: [String: String] = [
                "portal": "b",
                "login": "c",
                "password": "d",
            ]

            public let portal: String
            public let login: String
            public let password: String

            public init(
                portal: String,
                login: String,
                password: String
            ) {
                self.portal = portal
                self.login = login
                self.password = password
            }

            public static func initWithValidation(from dictionary: Entita.Dict, on eventLoop: EventLoop) -> Future<LoginRequest> {
                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "portal": [],
                    "login": [],
                    "password": [],
                ]

                var _portal: String = String()
                var _login: String = String()
                var _password: String = String()

                do {
                    do {
                        _portal = try LoginRequest.extract(param: "portal", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["portal"]!.append(eventLoop.newSucceededFuture(result: ("portal", Validation.Error.MissingValue())))
                    }
                    do {
                        _login = try LoginRequest.extract(param: "login", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["login"]!.append(eventLoop.newSucceededFuture(result: ("login", Validation.Error.MissingValue())))
                    }
                    do {
                        _password = try LoginRequest.extract(param: "password", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["password"]!.append(eventLoop.newSucceededFuture(result: ("password", Validation.Error.MissingValue())))
                    }
                } catch {
                    return eventLoop.newFailedFuture(error: error)
                }

                return self.reduce(
                    validators: validatorFutures,
                    on: eventLoop
                ).thenThrowing { errors in
                    guard errors.count == 0 else {
                        throw LGNC.E.DecodeError(errors)
                    }
                    return self.init(
                        portal: _portal,
                        login: _login,
                        password: _password
                    )
                }
            }

            public convenience init(from dictionary: Entita.Dict) throws {
                self.init(
                    portal: try LoginRequest.extract(param: "portal", from: dictionary),
                    login: try LoginRequest.extract(param: "login", from: dictionary),
                    password: try LoginRequest.extract(param: "password", from: dictionary)
                )
            }

            public func getDictionary() throws -> Entita.Dict {
                return [
                    self.getDictionaryKey("portal"): try self.encode(self.portal),
                    self.getDictionaryKey("login"): try self.encode(self.login),
                    self.getDictionaryKey("password"): try self.encode(self.password),
                ]
            }
        }

        public final class LoginResponse: ContractEntity {
            public static let keyDictionary: [String: String] = [
                "token": "b",
                "userID": "c",
            ]

            public let token: String
            public let userID: String

            public init(
                token: String,
                userID: String
            ) {
                self.token = token
                self.userID = userID
            }

            public static func initWithValidation(from dictionary: Entita.Dict, on eventLoop: EventLoop) -> Future<LoginResponse> {
                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "token": [],
                    "userID": [],
                ]

                var _token: String = String()
                var _userID: String = String()

                do {
                    do {
                        _token = try LoginResponse.extract(param: "token", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["token"]!.append(eventLoop.newSucceededFuture(result: ("token", Validation.Error.MissingValue())))
                    }
                    do {
                        _userID = try LoginResponse.extract(param: "userID", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["userID"]!.append(eventLoop.newSucceededFuture(result: ("userID", Validation.Error.MissingValue())))
                    }
                } catch {
                    return eventLoop.newFailedFuture(error: error)
                }

                return self.reduce(
                    validators: validatorFutures,
                    on: eventLoop
                ).thenThrowing { errors in
                    guard errors.count == 0 else {
                        throw LGNC.E.DecodeError(errors)
                    }
                    return self.init(
                        token: _token,
                        userID: _userID
                    )
                }
            }

            public convenience init(from dictionary: Entita.Dict) throws {
                self.init(
                    token: try LoginResponse.extract(param: "token", from: dictionary),
                    userID: try LoginResponse.extract(param: "userID", from: dictionary)
                )
            }

            public func getDictionary() throws -> Entita.Dict {
                return [
                    self.getDictionaryKey("token"): try self.encode(self.token),
                    self.getDictionaryKey("userID"): try self.encode(self.userID),
                ]
            }
        }

        public final class CommentUserInfo: ContractEntity {
            public static let keyDictionary: [String: String] = [
                "name": "b",
            ]

            public let name: String

            public init(
                name: String
            ) {
                self.name = name
            }

            public static func initWithValidation(from dictionary: Entita.Dict, on eventLoop: EventLoop) -> Future<CommentUserInfo> {
                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "name": [],
                ]

                var _name: String = String()

                do {
                    do {
                        _name = try CommentUserInfo.extract(param: "name", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["name"]!.append(eventLoop.newSucceededFuture(result: ("name", Validation.Error.MissingValue())))
                    }
                } catch {
                    return eventLoop.newFailedFuture(error: error)
                }

                return self.reduce(
                    validators: validatorFutures,
                    on: eventLoop
                ).thenThrowing { errors in
                    guard errors.count == 0 else {
                        throw LGNC.E.DecodeError(errors)
                    }
                    return self.init(
                        name: _name
                    )
                }
            }

            public convenience init(from dictionary: Entita.Dict) throws {
                self.init(
                    name: try CommentUserInfo.extract(param: "name", from: dictionary)
                )
            }

            public func getDictionary() throws -> Entita.Dict {
                return [
                    self.getDictionaryKey("name"): try self.encode(self.name),
                ]
            }
        }

        public final class Comment: ContractEntity {
            public static let keyDictionary: [String: String] = [
                "ID": "a",
                "IDUser": "c",
                "userName": "d",
                "IDPost": "e",
                "IDReplyComment": "f",
                "isDeleted": "g",
                "isApproved": "h",
                "body": "i",
                "likes": "j",
                "dateCreated": "k",
                "dateUpdated": "l",
            ]

            public let ID: Int
            public let IDUser: String
            public let userName: String
            public let IDPost: Int
            public let IDReplyComment: Int?
            public let isDeleted: Bool
            public let isApproved: Bool
            public let body: String
            public let likes: Int
            public let dateCreated: String
            public let dateUpdated: String

            public init(
                ID: Int,
                IDUser: String,
                userName: String,
                IDPost: Int,
                IDReplyComment: Int? = nil,
                isDeleted: Bool,
                isApproved: Bool,
                body: String,
                likes: Int,
                dateCreated: String,
                dateUpdated: String
            ) {
                self.ID = ID
                self.IDUser = IDUser
                self.userName = userName
                self.IDPost = IDPost
                self.IDReplyComment = IDReplyComment
                self.isDeleted = isDeleted
                self.isApproved = isApproved
                self.body = body
                self.likes = likes
                self.dateCreated = dateCreated
                self.dateUpdated = dateUpdated
            }

            public static func await(
                on eventLoop: EventLoop,
                ID: Int,
                IDUser IDUserFuture: Future<String>,
                userName userNameFuture: Future<String>,
                IDPost: Int,
                IDReplyComment: Int?,
                isDeleted: Bool,
                isApproved: Bool,
                body: String,
                likes likesFuture: Future<Int>,
                dateCreated: String,
                dateUpdated: String
            ) -> Future<Comment> {
                return eventLoop.newSucceededFuture(result: ()).then { () in
                    IDUserFuture.map { IDUser in IDUser }
                }
                .then { IDUser in
                    userNameFuture.map { userName in (IDUser, userName) }
                }
                .then { IDUser, userName in
                    likesFuture.map { likes in (IDUser, userName, likes) }
                }
                .map { IDUser, userName, likes in
                    Comment(
                        ID: ID,
                        IDUser: IDUser,
                        userName: userName,
                        IDPost: IDPost,
                        IDReplyComment: IDReplyComment,
                        isDeleted: isDeleted,
                        isApproved: isApproved,
                        body: body,
                        likes: likes,
                        dateCreated: dateCreated,
                        dateUpdated: dateUpdated
                    )
                }
            }

            public static func initWithValidation(from dictionary: Entita.Dict, on eventLoop: EventLoop) -> Future<Comment> {
                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "ID": [],
                    "IDUser": [],
                    "userName": [],
                    "IDPost": [],
                    "IDReplyComment": [],
                    "isDeleted": [],
                    "isApproved": [],
                    "body": [],
                    "likes": [],
                    "dateCreated": [],
                    "dateUpdated": [],
                ]

                var _ID: Int = Int()
                var _IDUser: String = String()
                var _userName: String = String()
                var _IDPost: Int = Int()
                var _IDReplyComment: Int?
                var _isDeleted: Bool = Bool()
                var _isApproved: Bool = Bool()
                var _body: String = String()
                var _likes: Int = Int()
                var _dateCreated: String = String()
                var _dateUpdated: String = String()

                do {
                    do {
                        _ID = try Comment.extract(param: "ID", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["ID"]!.append(eventLoop.newSucceededFuture(result: ("ID", Validation.Error.MissingValue())))
                    }
                    do {
                        _IDUser = try Comment.extract(param: "IDUser", from: dictionary)

                        if let error = Validation.UUID().validate(input: _IDUser) {
                            validatorFutures["IDUser"]!.append(eventLoop.newSucceededFuture(result: ("IDUser", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["IDUser"]!.append(eventLoop.newSucceededFuture(result: ("IDUser", Validation.Error.MissingValue())))
                    }
                    do {
                        _userName = try Comment.extract(param: "userName", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["userName"]!.append(eventLoop.newSucceededFuture(result: ("userName", Validation.Error.MissingValue())))
                    }
                    do {
                        _IDPost = try Comment.extract(param: "IDPost", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["IDPost"]!.append(eventLoop.newSucceededFuture(result: ("IDPost", Validation.Error.MissingValue())))
                    }
                    do {
                        _IDReplyComment = try Comment.extract(param: "IDReplyComment", from: dictionary, isOptional: true)
                    } catch Entita.E.ExtractError {
                        validatorFutures["IDReplyComment"]!.append(eventLoop.newSucceededFuture(result: ("IDReplyComment", Validation.Error.MissingValue())))
                    }
                    do {
                        _isDeleted = try Comment.extract(param: "isDeleted", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["isDeleted"]!.append(eventLoop.newSucceededFuture(result: ("isDeleted", Validation.Error.MissingValue())))
                    }
                    do {
                        _isApproved = try Comment.extract(param: "isApproved", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["isApproved"]!.append(eventLoop.newSucceededFuture(result: ("isApproved", Validation.Error.MissingValue())))
                    }
                    do {
                        _body = try Comment.extract(param: "body", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["body"]!.append(eventLoop.newSucceededFuture(result: ("body", Validation.Error.MissingValue())))
                    }
                    do {
                        _likes = try Comment.extract(param: "likes", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["likes"]!.append(eventLoop.newSucceededFuture(result: ("likes", Validation.Error.MissingValue())))
                    }
                    do {
                        _dateCreated = try Comment.extract(param: "dateCreated", from: dictionary)

                        if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(input: _dateCreated) {
                            validatorFutures["dateCreated"]!.append(eventLoop.newSucceededFuture(result: ("dateCreated", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["dateCreated"]!.append(eventLoop.newSucceededFuture(result: ("dateCreated", Validation.Error.MissingValue())))
                    }
                    do {
                        _dateUpdated = try Comment.extract(param: "dateUpdated", from: dictionary)

                        if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(input: _dateUpdated) {
                            validatorFutures["dateUpdated"]!.append(eventLoop.newSucceededFuture(result: ("dateUpdated", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["dateUpdated"]!.append(eventLoop.newSucceededFuture(result: ("dateUpdated", Validation.Error.MissingValue())))
                    }
                } catch {
                    return eventLoop.newFailedFuture(error: error)
                }

                return self.reduce(
                    validators: validatorFutures,
                    on: eventLoop
                ).thenThrowing { errors in
                    guard errors.count == 0 else {
                        throw LGNC.E.DecodeError(errors)
                    }
                    return self.init(
                        ID: _ID,
                        IDUser: _IDUser,
                        userName: _userName,
                        IDPost: _IDPost,
                        IDReplyComment: _IDReplyComment,
                        isDeleted: _isDeleted,
                        isApproved: _isApproved,
                        body: _body,
                        likes: _likes,
                        dateCreated: _dateCreated,
                        dateUpdated: _dateUpdated
                    )
                }
            }

            public convenience init(from dictionary: Entita.Dict) throws {
                self.init(
                    ID: try Comment.extract(param: "ID", from: dictionary),
                    IDUser: try Comment.extract(param: "IDUser", from: dictionary),
                    userName: try Comment.extract(param: "userName", from: dictionary),
                    IDPost: try Comment.extract(param: "IDPost", from: dictionary),
                    IDReplyComment: try Comment.extract(param: "IDReplyComment", from: dictionary, isOptional: true),
                    isDeleted: try Comment.extract(param: "isDeleted", from: dictionary),
                    isApproved: try Comment.extract(param: "isApproved", from: dictionary),
                    body: try Comment.extract(param: "body", from: dictionary),
                    likes: try Comment.extract(param: "likes", from: dictionary),
                    dateCreated: try Comment.extract(param: "dateCreated", from: dictionary),
                    dateUpdated: try Comment.extract(param: "dateUpdated", from: dictionary)
                )
            }

            public func getDictionary() throws -> Entita.Dict {
                return [
                    self.getDictionaryKey("ID"): try self.encode(self.ID),
                    self.getDictionaryKey("IDUser"): try self.encode(self.IDUser),
                    self.getDictionaryKey("userName"): try self.encode(self.userName),
                    self.getDictionaryKey("IDPost"): try self.encode(self.IDPost),
                    self.getDictionaryKey("IDReplyComment"): try self.encode(self.IDReplyComment),
                    self.getDictionaryKey("isDeleted"): try self.encode(self.isDeleted),
                    self.getDictionaryKey("isApproved"): try self.encode(self.isApproved),
                    self.getDictionaryKey("body"): try self.encode(self.body),
                    self.getDictionaryKey("likes"): try self.encode(self.likes),
                    self.getDictionaryKey("dateCreated"): try self.encode(self.dateCreated),
                    self.getDictionaryKey("dateUpdated"): try self.encode(self.dateUpdated),
                ]
            }
        }

        public final class Empty: ContractEntity {
            public static let keyDictionary: [String: String] = [
                :
            ]

            public init(
            ) {
            }

            public static func initWithValidation(from _: Entita.Dict, on eventLoop: EventLoop) -> Future<Empty> {
                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    :
                ]

                do {
                } catch {
                    return eventLoop.newFailedFuture(error: error)
                }

                return self.reduce(
                    validators: validatorFutures,
                    on: eventLoop
                ).thenThrowing { errors in
                    guard errors.count == 0 else {
                        throw LGNC.E.DecodeError(errors)
                    }
                    return self.init()
                }
            }

            public convenience init(from _: Entita.Dict) throws {
                self.init()
            }

            public func getDictionary() throws -> Entita.Dict {
                return [:]
            }
        }

        public final class User: ContractEntity {
            public static let keyDictionary: [String: String] = [
                "ID": "a",
                "username": "c",
                "email": "d",
                "password": "e",
                "sex": "f",
                "isBanned": "g",
                "ip": "h",
                "country": "i",
                "dateUnsuccessfulLogin": "j",
                "dateSignup": "k",
                "dateLogin": "l",
                "currentCharacter": "m",
                "authorName": "n",
                "accessLevel": "o",
                "characters": "p",
            ]

            public var ID: String
            public var username: String
            public var email: String
            public var password: String
            public var sex: String
            public var isBanned: Bool
            public var ip: String
            public var country: String
            public var dateUnsuccessfulLogin: String
            public var dateSignup: String
            public var dateLogin: String
            public var currentCharacter: String?
            public var authorName: String
            public var accessLevel: String
            public var characters: [String: CharacterInfo]

            public init(
                ID: String,
                username: String,
                email: String,
                password: String,
                sex: String,
                isBanned: Bool,
                ip: String,
                country: String,
                dateUnsuccessfulLogin: String,
                dateSignup: String,
                dateLogin: String,
                currentCharacter: String? = nil,
                authorName: String,
                accessLevel: String,
                characters: [String: CharacterInfo] = [String: CharacterInfo]()
            ) {
                self.ID = ID
                self.username = username
                self.email = email
                self.password = password
                self.sex = sex
                self.isBanned = isBanned
                self.ip = ip
                self.country = country
                self.dateUnsuccessfulLogin = dateUnsuccessfulLogin
                self.dateSignup = dateSignup
                self.dateLogin = dateLogin
                self.currentCharacter = currentCharacter
                self.authorName = authorName
                self.accessLevel = accessLevel
                self.characters = characters
            }

            public static func initWithValidation(from dictionary: Entita.Dict, on eventLoop: EventLoop) -> Future<User> {
                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "ID": [],
                    "username": [],
                    "email": [],
                    "password": [],
                    "sex": [],
                    "isBanned": [],
                    "ip": [],
                    "country": [],
                    "dateUnsuccessfulLogin": [],
                    "dateSignup": [],
                    "dateLogin": [],
                    "currentCharacter": [],
                    "authorName": [],
                    "accessLevel": [],
                    "characters": [],
                ]

                var _ID: String = String()
                var _username: String = String()
                var _email: String = String()
                var _password: String = String()
                var _sex: String = String()
                var _isBanned: Bool = Bool()
                var _ip: String = String()
                var _country: String = String()
                var _dateUnsuccessfulLogin: String = String()
                var _dateSignup: String = String()
                var _dateLogin: String = String()
                var _currentCharacter: String?
                var _authorName: String = String()
                var _accessLevel: String = String()
                var _characters: [String: CharacterInfo] = [String: CharacterInfo]()

                do {
                    do {
                        _ID = try User.extract(param: "ID", from: dictionary)

                        if let error = Validation.UUID().validate(input: _ID) {
                            validatorFutures["ID"]!.append(eventLoop.newSucceededFuture(result: ("ID", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["ID"]!.append(eventLoop.newSucceededFuture(result: ("ID", Validation.Error.MissingValue())))
                    }
                    do {
                        _username = try User.extract(param: "username", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["username"]!.append(eventLoop.newSucceededFuture(result: ("username", Validation.Error.MissingValue())))
                    }
                    do {
                        _email = try User.extract(param: "email", from: dictionary)

                        if let error = Validation.Regexp(pattern: "^.+@.+\\..+$", message: "Invalid email format").validate(input: _email) {
                            validatorFutures["email"]!.append(eventLoop.newSucceededFuture(result: ("email", error)))
                        }

                        if let error = Validation.Length.Min(length: 6).validate(input: _email) {
                            validatorFutures["email"]!.append(eventLoop.newSucceededFuture(result: ("email", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["email"]!.append(eventLoop.newSucceededFuture(result: ("email", Validation.Error.MissingValue())))
                    }
                    do {
                        _password = try User.extract(param: "password", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["password"]!.append(eventLoop.newSucceededFuture(result: ("password", Validation.Error.MissingValue())))
                    }
                    do {
                        _sex = try User.extract(param: "sex", from: dictionary)

                        if let error = Validation.In(allowedValues: ["Male", "Female", "Attack helicopter"]).validate(input: _sex) {
                            validatorFutures["sex"]!.append(eventLoop.newSucceededFuture(result: ("sex", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["sex"]!.append(eventLoop.newSucceededFuture(result: ("sex", Validation.Error.MissingValue())))
                    }
                    do {
                        _isBanned = try User.extract(param: "isBanned", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["isBanned"]!.append(eventLoop.newSucceededFuture(result: ("isBanned", Validation.Error.MissingValue())))
                    }
                    do {
                        _ip = try User.extract(param: "ip", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["ip"]!.append(eventLoop.newSucceededFuture(result: ("ip", Validation.Error.MissingValue())))
                    }
                    do {
                        _country = try User.extract(param: "country", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["country"]!.append(eventLoop.newSucceededFuture(result: ("country", Validation.Error.MissingValue())))
                    }
                    do {
                        _dateUnsuccessfulLogin = try User.extract(param: "dateUnsuccessfulLogin", from: dictionary)

                        if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(input: _dateUnsuccessfulLogin) {
                            validatorFutures["dateUnsuccessfulLogin"]!.append(eventLoop.newSucceededFuture(result: ("dateUnsuccessfulLogin", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["dateUnsuccessfulLogin"]!.append(eventLoop.newSucceededFuture(result: ("dateUnsuccessfulLogin", Validation.Error.MissingValue())))
                    }
                    do {
                        _dateSignup = try User.extract(param: "dateSignup", from: dictionary)

                        if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(input: _dateSignup) {
                            validatorFutures["dateSignup"]!.append(eventLoop.newSucceededFuture(result: ("dateSignup", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["dateSignup"]!.append(eventLoop.newSucceededFuture(result: ("dateSignup", Validation.Error.MissingValue())))
                    }
                    do {
                        _dateLogin = try User.extract(param: "dateLogin", from: dictionary)

                        if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(input: _dateLogin) {
                            validatorFutures["dateLogin"]!.append(eventLoop.newSucceededFuture(result: ("dateLogin", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["dateLogin"]!.append(eventLoop.newSucceededFuture(result: ("dateLogin", Validation.Error.MissingValue())))
                    }
                    do {
                        _currentCharacter = try User.extract(param: "currentCharacter", from: dictionary, isOptional: true)
                    } catch Entita.E.ExtractError {
                        validatorFutures["currentCharacter"]!.append(eventLoop.newSucceededFuture(result: ("currentCharacter", Validation.Error.MissingValue())))
                    }
                    do {
                        _authorName = try User.extract(param: "authorName", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["authorName"]!.append(eventLoop.newSucceededFuture(result: ("authorName", Validation.Error.MissingValue())))
                    }
                    do {
                        _accessLevel = try User.extract(param: "accessLevel", from: dictionary)

                        if let error = Validation.In(allowedValues: ["User", "Moderator", "Admin"]).validate(input: _accessLevel) {
                            validatorFutures["accessLevel"]!.append(eventLoop.newSucceededFuture(result: ("accessLevel", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["accessLevel"]!.append(eventLoop.newSucceededFuture(result: ("accessLevel", Validation.Error.MissingValue())))
                    }
                    do {
                        _characters = try User.extract(param: "characters", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["characters"]!.append(eventLoop.newSucceededFuture(result: ("characters", Validation.Error.MissingValue())))
                    }
                } catch {
                    return eventLoop.newFailedFuture(error: error)
                }

                return self.reduce(
                    validators: validatorFutures,
                    on: eventLoop
                ).thenThrowing { errors in
                    guard errors.count == 0 else {
                        throw LGNC.E.DecodeError(errors)
                    }
                    return self.init(
                        ID: _ID,
                        username: _username,
                        email: _email,
                        password: _password,
                        sex: _sex,
                        isBanned: _isBanned,
                        ip: _ip,
                        country: _country,
                        dateUnsuccessfulLogin: _dateUnsuccessfulLogin,
                        dateSignup: _dateSignup,
                        dateLogin: _dateLogin,
                        currentCharacter: _currentCharacter,
                        authorName: _authorName,
                        accessLevel: _accessLevel,
                        characters: _characters
                    )
                }
            }

            public convenience init(from dictionary: Entita.Dict) throws {
                self.init(
                    ID: try User.extract(param: "ID", from: dictionary),
                    username: try User.extract(param: "username", from: dictionary),
                    email: try User.extract(param: "email", from: dictionary),
                    password: try User.extract(param: "password", from: dictionary),
                    sex: try User.extract(param: "sex", from: dictionary),
                    isBanned: try User.extract(param: "isBanned", from: dictionary),
                    ip: try User.extract(param: "ip", from: dictionary),
                    country: try User.extract(param: "country", from: dictionary),
                    dateUnsuccessfulLogin: try User.extract(param: "dateUnsuccessfulLogin", from: dictionary),
                    dateSignup: try User.extract(param: "dateSignup", from: dictionary),
                    dateLogin: try User.extract(param: "dateLogin", from: dictionary),
                    currentCharacter: try User.extract(param: "currentCharacter", from: dictionary, isOptional: true),
                    authorName: try User.extract(param: "authorName", from: dictionary),
                    accessLevel: try User.extract(param: "accessLevel", from: dictionary),
                    characters: try User.extract(param: "characters", from: dictionary)
                )
            }

            public func getDictionary() throws -> Entita.Dict {
                return [
                    self.getDictionaryKey("ID"): try self.encode(self.ID),
                    self.getDictionaryKey("username"): try self.encode(self.username),
                    self.getDictionaryKey("email"): try self.encode(self.email),
                    self.getDictionaryKey("password"): try self.encode(self.password),
                    self.getDictionaryKey("sex"): try self.encode(self.sex),
                    self.getDictionaryKey("isBanned"): try self.encode(self.isBanned),
                    self.getDictionaryKey("ip"): try self.encode(self.ip),
                    self.getDictionaryKey("country"): try self.encode(self.country),
                    self.getDictionaryKey("dateUnsuccessfulLogin"): try self.encode(self.dateUnsuccessfulLogin),
                    self.getDictionaryKey("dateSignup"): try self.encode(self.dateSignup),
                    self.getDictionaryKey("dateLogin"): try self.encode(self.dateLogin),
                    self.getDictionaryKey("currentCharacter"): try self.encode(self.currentCharacter),
                    self.getDictionaryKey("authorName"): try self.encode(self.authorName),
                    self.getDictionaryKey("accessLevel"): try self.encode(self.accessLevel),
                    self.getDictionaryKey("characters"): try self.encode(self.characters),
                ]
            }
        }
    }
}
