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
                "DeleteComment": (
                    visibility: Services.Quorum.Contracts.DeleteComment.visibility,
                    transports: Services.Quorum.Contracts.DeleteComment.transports
                ),
                "UndeleteComment": (
                    visibility: Services.Quorum.Contracts.UndeleteComment.visibility,
                    transports: Services.Quorum.Contracts.UndeleteComment.transports
                ),
                "HideComment": (
                    visibility: Services.Quorum.Contracts.HideComment.visibility,
                    transports: Services.Quorum.Contracts.HideComment.transports
                ),
                "UnhideComment": (
                    visibility: Services.Quorum.Contracts.UnhideComment.visibility,
                    transports: Services.Quorum.Contracts.UnhideComment.transports
                ),
                "ApproveComment": (
                    visibility: Services.Quorum.Contracts.ApproveComment.visibility,
                    transports: Services.Quorum.Contracts.ApproveComment.transports
                ),
                "Comments": (
                    visibility: Services.Quorum.Contracts.Comments.visibility,
                    transports: Services.Quorum.Contracts.Comments.transports
                ),
                "CreateComment": (
                    visibility: Services.Quorum.Contracts.CreateComment.visibility,
                    transports: Services.Quorum.Contracts.CreateComment.transports
                ),
                "EditComment": (
                    visibility: Services.Quorum.Contracts.EditComment.visibility,
                    transports: Services.Quorum.Contracts.EditComment.transports
                ),
                "LikeComment": (
                    visibility: Services.Quorum.Contracts.LikeComment.visibility,
                    transports: Services.Quorum.Contracts.LikeComment.transports
                ),
                "PendingComments": (
                    visibility: Services.Quorum.Contracts.PendingComments.visibility,
                    transports: Services.Quorum.Contracts.PendingComments.transports
                ),
                "RejectComment": (
                    visibility: Services.Quorum.Contracts.RejectComment.visibility,
                    transports: Services.Quorum.Contracts.RejectComment.transports
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
                "RaiseEvent": (
                    visibility: Services.Author.Contracts.RaiseEvent.visibility,
                    transports: Services.Author.Contracts.RaiseEvent.transports
                ),
                "AnnounceEvent": (
                    visibility: Services.Author.Contracts.AnnounceEvent.visibility,
                    transports: Services.Author.Contracts.AnnounceEvent.transports
                ),
                "Login": (
                    visibility: Services.Author.Contracts.Login.visibility,
                    transports: Services.Author.Contracts.Login.transports
                ),
                "InternalLogin": (
                    visibility: Services.Author.Contracts.InternalLogin.visibility,
                    transports: Services.Author.Contracts.InternalLogin.transports
                ),
                "UserInfo": (
                    visibility: Services.Author.Contracts.UserInfo.visibility,
                    transports: Services.Author.Contracts.UserInfo.transports
                ),
                "UserInfoInternal": (
                    visibility: Services.Author.Contracts.UserInfoInternal.visibility,
                    transports: Services.Author.Contracts.UserInfoInternal.transports
                ),
                "Authenticate": (
                    visibility: Services.Author.Contracts.Authenticate.visibility,
                    transports: Services.Author.Contracts.Authenticate.transports
                ),
                "ChangePassword": (
                    visibility: Services.Author.Contracts.ChangePassword.visibility,
                    transports: Services.Author.Contracts.ChangePassword.transports
                ),
                "ValidateEmail": (
                    visibility: Services.Author.Contracts.ValidateEmail.visibility,
                    transports: Services.Author.Contracts.ValidateEmail.transports
                ),
                "ResendValidationEmail": (
                    visibility: Services.Author.Contracts.ResendValidationEmail.visibility,
                    transports: Services.Author.Contracts.ResendValidationEmail.transports
                ),
                "ResetPasswordStep1": (
                    visibility: Services.Author.Contracts.ResetPasswordStep1.visibility,
                    transports: Services.Author.Contracts.ResetPasswordStep1.transports
                ),
                "ResetPasswordStep2": (
                    visibility: Services.Author.Contracts.ResetPasswordStep2.visibility,
                    transports: Services.Author.Contracts.ResetPasswordStep2.transports
                ),
                "InternalSignup": (
                    visibility: Services.Author.Contracts.InternalSignup.visibility,
                    transports: Services.Author.Contracts.InternalSignup.transports
                ),
                "Signup": (
                    visibility: Services.Author.Contracts.Signup.visibility,
                    transports: Services.Author.Contracts.Signup.transports
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

            public static func initWithValidation(from dictionary: Entita.Dict, requestInfo: LGNCore.RequestInfo) -> Future<FieldMapping> {
                let eventLoop = requestInfo.eventLoop

                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "map": [],
                ]

                var _map: [String: String] = [String: String]()

                do {
                    do {
                        _map = try FieldMapping.extract(param: "map", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["map"]!.append(eventLoop.makeSucceededFuture(("map", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                } catch {
                    return eventLoop.makeFailedFuture(error)
                }

                return self
                    .reduce(validators: validatorFutures, on: eventLoop)
                    .flatMapThrowing { errors in
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

            public static func initWithValidation(from dictionary: Entita.Dict, requestInfo: LGNCore.RequestInfo) -> Future<ServiceFieldMapping> {
                let eventLoop = requestInfo.eventLoop

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
                        validatorFutures["Request"]!.append(eventLoop.makeSucceededFuture(("Request", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _Response = try ServiceFieldMapping.extract(param: "Response", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["Response"]!.append(eventLoop.makeSucceededFuture(("Response", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                } catch {
                    return eventLoop.makeFailedFuture(error)
                }

                return self
                    .reduce(validators: validatorFutures, on: eventLoop)
                    .flatMapThrowing { errors in
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

            public static func initWithValidation(from dictionary: Entita.Dict, requestInfo: LGNCore.RequestInfo) -> Future<ServiceFieldMappings> {
                let eventLoop = requestInfo.eventLoop

                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "map": [],
                ]

                var _map: [String: ServiceFieldMapping] = [String: ServiceFieldMapping]()

                do {
                    do {
                        _map = try ServiceFieldMappings.extract(param: "map", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["map"]!.append(eventLoop.makeSucceededFuture(("map", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                } catch {
                    return eventLoop.makeFailedFuture(error)
                }

                return self
                    .reduce(validators: validatorFutures, on: eventLoop)
                    .flatMapThrowing { errors in
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

            public static func initWithValidation(from dictionary: Entita.Dict, requestInfo: LGNCore.RequestInfo) -> Future<CharacterInfo> {
                let eventLoop = requestInfo.eventLoop

                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "monad": [],
                ]

                var _monad: String = String()

                do {
                    do {
                        _monad = try CharacterInfo.extract(param: "monad", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["monad"]!.append(eventLoop.makeSucceededFuture(("monad", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                } catch {
                    return eventLoop.makeFailedFuture(error)
                }

                return self
                    .reduce(validators: validatorFutures, on: eventLoop)
                    .flatMapThrowing { errors in
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

        public final class EventRequest: ContractEntity {
            public static let keyDictionary: [String: String] = [
                "event": "b",
            ]

            public let event: String

            public init(
                event: String
            ) {
                self.event = event
            }

            public static func initWithValidation(from dictionary: Entita.Dict, requestInfo: LGNCore.RequestInfo) -> Future<EventRequest> {
                let eventLoop = requestInfo.eventLoop

                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "event": [],
                ]

                var _event: String = String()

                do {
                    do {
                        _event = try EventRequest.extract(param: "event", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["event"]!.append(eventLoop.makeSucceededFuture(("event", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                } catch {
                    return eventLoop.makeFailedFuture(error)
                }

                return self
                    .reduce(validators: validatorFutures, on: eventLoop)
                    .flatMapThrowing { errors in
                        guard errors.count == 0 else {
                            throw LGNC.E.DecodeError(errors)
                        }
                        return self.init(
                            event: _event
                        )
                    }
            }

            public convenience init(from dictionary: Entita.Dict) throws {
                self.init(
                    event: try EventRequest.extract(param: "event", from: dictionary)
                )
            }

            public func getDictionary() throws -> Entita.Dict {
                return [
                    self.getDictionaryKey("event"): try self.encode(self.event),
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
                "language": "g",
                "recaptchaToken": "h",
            ]

            public let username: String
            public let email: String
            public let password1: String
            public let password2: String
            public let sex: String
            public let language: String
            public let recaptchaToken: String

            private static var validatorUsernameClosure: Validation.CallbackWithAllowedValues<CallbackValidatorUsernameAllowedValues>.Callback?
            private static var validatorEmailClosure: Validation.CallbackWithAllowedValues<CallbackValidatorEmailAllowedValues>.Callback?

            public init(
                username: String,
                email: String,
                password1: String,
                password2: String,
                sex: String,
                language: String,
                recaptchaToken: String
            ) {
                self.username = username
                self.email = email
                self.password1 = password1
                self.password2 = password2
                self.sex = sex
                self.language = language
                self.recaptchaToken = recaptchaToken
            }

            public static func initWithValidation(from dictionary: Entita.Dict, requestInfo: LGNCore.RequestInfo) -> Future<UserSignupRequest> {
                let eventLoop = requestInfo.eventLoop

                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "username": [],
                    "email": [],
                    "password1": [],
                    "password2": [],
                    "sex": [],
                    "language": [],
                    "recaptchaToken": [],
                ]

                var _username: String = String()
                var _email: String = String()
                var _password1: String = String()
                var _password2: String = String()
                var _sex: String = String()
                var _language: String = String()
                var _recaptchaToken: String = String()

                do {
                    do {
                        _username = try UserSignupRequest.extract(param: "username", from: dictionary)

                        if let error = Validation.Regexp(pattern: "^[a-zA-Zа-яА-Я0-9_\\- ]+$", message: "Username must only consist of letters, numbers and underscores").validate(_username, requestInfo.locale) {
                            validatorFutures["username"]!.append(eventLoop.makeSucceededFuture(("username", error)))
                        }

                        if let error = Validation.Length.Min(length: 3).validate(_username, requestInfo.locale) {
                            validatorFutures["username"]!.append(eventLoop.makeSucceededFuture(("username", error)))
                        }

                        if let error = Validation.Length.Max(length: 24).validate(_username, requestInfo.locale) {
                            validatorFutures["username"]!.append(eventLoop.makeSucceededFuture(("username", error)))
                        }

                        if let validatorUsernameClosure = self.validatorUsernameClosure {
                            validatorFutures["username"]!.append(
                                Validation.CallbackWithAllowedValues<CallbackValidatorUsernameAllowedValues>(callback: validatorUsernameClosure).validate(
                                    _username,
                                    requestInfo.locale,
                                    on: eventLoop
                                ).map { ("username", $0) }
                            )
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["username"]!.append(eventLoop.makeSucceededFuture(("username", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _email = try UserSignupRequest.extract(param: "email", from: dictionary)

                        if let error = Validation.Regexp(pattern: "^.+@.+\\..+$", message: "Invalid email format").validate(_email, requestInfo.locale) {
                            validatorFutures["email"]!.append(eventLoop.makeSucceededFuture(("email", error)))
                        }

                        if let validatorEmailClosure = self.validatorEmailClosure {
                            validatorFutures["email"]!.append(
                                Validation.CallbackWithAllowedValues<CallbackValidatorEmailAllowedValues>(callback: validatorEmailClosure).validate(
                                    _email,
                                    requestInfo.locale,
                                    on: eventLoop
                                ).map { ("email", $0) }
                            )
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["email"]!.append(eventLoop.makeSucceededFuture(("email", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _password1 = try UserSignupRequest.extract(param: "password1", from: dictionary)

                        if let error = Validation.Length.Min(length: 6, message: "Password must be at least {Length} characters long").validate(_password1, requestInfo.locale) {
                            validatorFutures["password1"]!.append(eventLoop.makeSucceededFuture(("password1", error)))
                        }

                        if let error = Validation.Length.Max(length: 64, message: "Password must be less than {Length} characters long").validate(_password1, requestInfo.locale) {
                            validatorFutures["password1"]!.append(eventLoop.makeSucceededFuture(("password1", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["password1"]!.append(eventLoop.makeSucceededFuture(("password1", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _password2 = try UserSignupRequest.extract(param: "password2", from: dictionary)

                        if let error = Validation.Identical(right: _password1, message: "Passwords must match").validate(_password2, requestInfo.locale) {
                            validatorFutures["password2"]!.append(eventLoop.makeSucceededFuture(("password2", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["password2"]!.append(eventLoop.makeSucceededFuture(("password2", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _sex = try UserSignupRequest.extract(param: "sex", from: dictionary)

                        if let error = Validation.In(allowedValues: ["Male", "Female", "Attack helicopter"]).validate(_sex, requestInfo.locale) {
                            validatorFutures["sex"]!.append(eventLoop.makeSucceededFuture(("sex", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["sex"]!.append(eventLoop.makeSucceededFuture(("sex", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _language = try UserSignupRequest.extract(param: "language", from: dictionary)

                        if let error = Validation.In(allowedValues: ["en", "ru"]).validate(_language, requestInfo.locale) {
                            validatorFutures["language"]!.append(eventLoop.makeSucceededFuture(("language", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["language"]!.append(eventLoop.makeSucceededFuture(("language", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _recaptchaToken = try UserSignupRequest.extract(param: "recaptchaToken", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["recaptchaToken"]!.append(eventLoop.makeSucceededFuture(("recaptchaToken", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                } catch {
                    return eventLoop.makeFailedFuture(error)
                }

                return self
                    .reduce(validators: validatorFutures, on: eventLoop)
                    .flatMapThrowing { errors in
                        guard errors.count == 0 else {
                            throw LGNC.E.DecodeError(errors)
                        }
                        return self.init(
                            username: _username,
                            email: _email,
                            password1: _password1,
                            password2: _password2,
                            sex: _sex,
                            language: _language,
                            recaptchaToken: _recaptchaToken
                        )
                    }
            }

            public convenience init(from dictionary: Entita.Dict) throws {
                self.init(
                    username: try UserSignupRequest.extract(param: "username", from: dictionary),
                    email: try UserSignupRequest.extract(param: "email", from: dictionary),
                    password1: try UserSignupRequest.extract(param: "password1", from: dictionary),
                    password2: try UserSignupRequest.extract(param: "password2", from: dictionary),
                    sex: try UserSignupRequest.extract(param: "sex", from: dictionary),
                    language: try UserSignupRequest.extract(param: "language", from: dictionary),
                    recaptchaToken: try UserSignupRequest.extract(param: "recaptchaToken", from: dictionary)
                )
            }

            public func getDictionary() throws -> Entita.Dict {
                return [
                    self.getDictionaryKey("username"): try self.encode(self.username),
                    self.getDictionaryKey("email"): try self.encode(self.email),
                    self.getDictionaryKey("password1"): try self.encode(self.password1),
                    self.getDictionaryKey("password2"): try self.encode(self.password2),
                    self.getDictionaryKey("sex"): try self.encode(self.sex),
                    self.getDictionaryKey("language"): try self.encode(self.language),
                    self.getDictionaryKey("recaptchaToken"): try self.encode(self.recaptchaToken),
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
                "id": "c",
                "name": "d",
                "port": "e",
            ]

            public let type: String
            public let id: String
            public let name: String
            public let port: Int

            private static var validatorNameClosure: Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>.Callback?

            public init(
                type: String,
                id: String,
                name: String,
                port: Int
            ) {
                self.type = type
                self.id = id
                self.name = name
                self.port = port
            }

            public static func initWithValidation(from dictionary: Entita.Dict, requestInfo: LGNCore.RequestInfo) -> Future<NodeInfo> {
                let eventLoop = requestInfo.eventLoop

                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "type": [],
                    "id": [],
                    "name": [],
                    "port": [],
                ]

                var _type: String = String()
                var _id: String = String()
                var _name: String = String()
                var _port: Int = Int()

                do {
                    do {
                        _type = try NodeInfo.extract(param: "type", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["type"]!.append(eventLoop.makeSucceededFuture(("type", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _id = try NodeInfo.extract(param: "id", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["id"]!.append(eventLoop.makeSucceededFuture(("id", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _name = try NodeInfo.extract(param: "name", from: dictionary)

                        if let validatorNameClosure = self.validatorNameClosure {
                            validatorFutures["name"]!.append(
                                Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>(callback: validatorNameClosure).validate(
                                    _name,
                                    requestInfo.locale,
                                    on: eventLoop
                                ).map { ("name", $0) }
                            )
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["name"]!.append(eventLoop.makeSucceededFuture(("name", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _port = try NodeInfo.extract(param: "port", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["port"]!.append(eventLoop.makeSucceededFuture(("port", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                } catch {
                    return eventLoop.makeFailedFuture(error)
                }

                return self
                    .reduce(validators: validatorFutures, on: eventLoop)
                    .flatMapThrowing { errors in
                        guard errors.count == 0 else {
                            throw LGNC.E.DecodeError(errors)
                        }
                        return self.init(
                            type: _type,
                            id: _id,
                            name: _name,
                            port: _port
                        )
                    }
            }

            public convenience init(from dictionary: Entita.Dict) throws {
                self.init(
                    type: try NodeInfo.extract(param: "type", from: dictionary),
                    id: try NodeInfo.extract(param: "id", from: dictionary),
                    name: try NodeInfo.extract(param: "name", from: dictionary),
                    port: try NodeInfo.extract(param: "port", from: dictionary)
                )
            }

            public func getDictionary() throws -> Entita.Dict {
                return [
                    self.getDictionaryKey("type"): try self.encode(self.type),
                    self.getDictionaryKey("id"): try self.encode(self.id),
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

            public static func initWithValidation(from dictionary: Entita.Dict, requestInfo: LGNCore.RequestInfo) -> Future<PingRequest> {
                let eventLoop = requestInfo.eventLoop

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
                                    _name,
                                    requestInfo.locale,
                                    on: eventLoop
                                ).map { ("name", $0) }
                            )
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["name"]!.append(eventLoop.makeSucceededFuture(("name", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _entities = try PingRequest.extract(param: "entities", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["entities"]!.append(eventLoop.makeSucceededFuture(("entities", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                } catch {
                    return eventLoop.makeFailedFuture(error)
                }

                return self
                    .reduce(validators: validatorFutures, on: eventLoop)
                    .flatMapThrowing { errors in
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

            public static func initWithValidation(from dictionary: Entita.Dict, requestInfo: LGNCore.RequestInfo) -> Future<PingResponse> {
                let eventLoop = requestInfo.eventLoop

                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "result": [],
                ]

                var _result: String = String()

                do {
                    do {
                        _result = try PingResponse.extract(param: "result", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["result"]!.append(eventLoop.makeSucceededFuture(("result", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                } catch {
                    return eventLoop.makeFailedFuture(error)
                }

                return self
                    .reduce(validators: validatorFutures, on: eventLoop)
                    .flatMapThrowing { errors in
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

            public static func initWithValidation(from dictionary: Entita.Dict, requestInfo: LGNCore.RequestInfo) -> Future<CheckinRequest> {
                let eventLoop = requestInfo.eventLoop

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
                        validatorFutures["type"]!.append(eventLoop.makeSucceededFuture(("type", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _name = try CheckinRequest.extract(param: "name", from: dictionary)

                        if let validatorNameClosure = self.validatorNameClosure {
                            validatorFutures["name"]!.append(
                                Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>(callback: validatorNameClosure).validate(
                                    _name,
                                    requestInfo.locale,
                                    on: eventLoop
                                ).map { ("name", $0) }
                            )
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["name"]!.append(eventLoop.makeSucceededFuture(("name", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _port = try CheckinRequest.extract(param: "port", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["port"]!.append(eventLoop.makeSucceededFuture(("port", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _entities = try CheckinRequest.extract(param: "entities", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["entities"]!.append(eventLoop.makeSucceededFuture(("entities", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                } catch {
                    return eventLoop.makeFailedFuture(error)
                }

                return self
                    .reduce(validators: validatorFutures, on: eventLoop)
                    .flatMapThrowing { errors in
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

            public static func initWithValidation(from dictionary: Entita.Dict, requestInfo: LGNCore.RequestInfo) -> Future<CheckinResponse> {
                let eventLoop = requestInfo.eventLoop

                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "result": [],
                ]

                var _result: String = String()

                do {
                    do {
                        _result = try CheckinResponse.extract(param: "result", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["result"]!.append(eventLoop.makeSucceededFuture(("result", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                } catch {
                    return eventLoop.makeFailedFuture(error)
                }

                return self
                    .reduce(validators: validatorFutures, on: eventLoop)
                    .flatMapThrowing { errors in
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
                "email": "c",
                "password": "d",
                "recaptchaToken": "e",
            ]

            public let portal: String
            public let email: String
            public let password: String
            public let recaptchaToken: String?

            public init(
                portal: String,
                email: String,
                password: String,
                recaptchaToken: String? = nil
            ) {
                self.portal = portal
                self.email = email
                self.password = password
                self.recaptchaToken = recaptchaToken
            }

            public static func initWithValidation(from dictionary: Entita.Dict, requestInfo: LGNCore.RequestInfo) -> Future<LoginRequest> {
                let eventLoop = requestInfo.eventLoop

                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "portal": [],
                    "email": [],
                    "password": [],
                    "recaptchaToken": [],
                ]

                var _portal: String = String()
                var _email: String = String()
                var _password: String = String()
                var _recaptchaToken: String?

                do {
                    do {
                        _portal = try LoginRequest.extract(param: "portal", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["portal"]!.append(eventLoop.makeSucceededFuture(("portal", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _email = try LoginRequest.extract(param: "email", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["email"]!.append(eventLoop.makeSucceededFuture(("email", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _password = try LoginRequest.extract(param: "password", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["password"]!.append(eventLoop.makeSucceededFuture(("password", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _recaptchaToken = try LoginRequest.extract(param: "recaptchaToken", from: dictionary, isOptional: true)
                    } catch Entita.E.ExtractError {
                        validatorFutures["recaptchaToken"]!.append(eventLoop.makeSucceededFuture(("recaptchaToken", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                } catch {
                    return eventLoop.makeFailedFuture(error)
                }

                return self
                    .reduce(validators: validatorFutures, on: eventLoop)
                    .flatMapThrowing { errors in
                        guard errors.count == 0 else {
                            throw LGNC.E.DecodeError(errors)
                        }
                        return self.init(
                            portal: _portal,
                            email: _email,
                            password: _password,
                            recaptchaToken: _recaptchaToken
                        )
                    }
            }

            public convenience init(from dictionary: Entita.Dict) throws {
                self.init(
                    portal: try LoginRequest.extract(param: "portal", from: dictionary),
                    email: try LoginRequest.extract(param: "email", from: dictionary),
                    password: try LoginRequest.extract(param: "password", from: dictionary),
                    recaptchaToken: try LoginRequest.extract(param: "recaptchaToken", from: dictionary, isOptional: true)
                )
            }

            public func getDictionary() throws -> Entita.Dict {
                return [
                    self.getDictionaryKey("portal"): try self.encode(self.portal),
                    self.getDictionaryKey("email"): try self.encode(self.email),
                    self.getDictionaryKey("password"): try self.encode(self.password),
                    self.getDictionaryKey("recaptchaToken"): try self.encode(self.recaptchaToken),
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

            public static func initWithValidation(from dictionary: Entita.Dict, requestInfo: LGNCore.RequestInfo) -> Future<LoginResponse> {
                let eventLoop = requestInfo.eventLoop

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
                        validatorFutures["token"]!.append(eventLoop.makeSucceededFuture(("token", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _userID = try LoginResponse.extract(param: "userID", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["userID"]!.append(eventLoop.makeSucceededFuture(("userID", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                } catch {
                    return eventLoop.makeFailedFuture(error)
                }

                return self
                    .reduce(validators: validatorFutures, on: eventLoop)
                    .flatMapThrowing { errors in
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

            public static func initWithValidation(from dictionary: Entita.Dict, requestInfo: LGNCore.RequestInfo) -> Future<CommentUserInfo> {
                let eventLoop = requestInfo.eventLoop

                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "name": [],
                ]

                var _name: String = String()

                do {
                    do {
                        _name = try CommentUserInfo.extract(param: "name", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["name"]!.append(eventLoop.makeSucceededFuture(("name", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                } catch {
                    return eventLoop.makeFailedFuture(error)
                }

                return self
                    .reduce(validators: validatorFutures, on: eventLoop)
                    .flatMapThrowing { errors in
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
                "status": "g",
                "body": "h",
                "likes": "i",
                "dateCreated": "j",
                "dateUpdated": "k",
            ]

            public let ID: Int
            public let IDUser: String
            public let userName: String
            public let IDPost: Int
            public let IDReplyComment: Int?
            public let status: String
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
                status: String,
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
                self.status = status
                self.body = body
                self.likes = likes
                self.dateCreated = dateCreated
                self.dateUpdated = dateUpdated
            }

            public static func await(
                ID: Int,
                IDUser IDUserFuture: Future<String>,
                userName userNameFuture: Future<String>,
                IDPost: Int,
                IDReplyComment: Int?,
                status: String,
                body: String,
                likes likesFuture: Future<Int>,
                dateCreated: String,
                dateUpdated: String
            ) -> Future<Comment> {
                return likesFuture.eventLoop.makeSucceededFuture(()).flatMap { () in
                    IDUserFuture.map { IDUser in IDUser }
                }
                .flatMap { IDUser in
                    userNameFuture.map { userName in (IDUser, userName) }
                }
                .flatMap { IDUser, userName in
                    likesFuture.map { likes in (IDUser, userName, likes) }
                }
                .map { IDUser, userName, likes in
                    Comment(
                        ID: ID,
                        IDUser: IDUser,
                        userName: userName,
                        IDPost: IDPost,
                        IDReplyComment: IDReplyComment,
                        status: status,
                        body: body,
                        likes: likes,
                        dateCreated: dateCreated,
                        dateUpdated: dateUpdated
                    )
                }
            }

            public static func initWithValidation(from dictionary: Entita.Dict, requestInfo: LGNCore.RequestInfo) -> Future<Comment> {
                let eventLoop = requestInfo.eventLoop

                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    "ID": [],
                    "IDUser": [],
                    "userName": [],
                    "IDPost": [],
                    "IDReplyComment": [],
                    "status": [],
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
                var _status: String = String()
                var _body: String = String()
                var _likes: Int = Int()
                var _dateCreated: String = String()
                var _dateUpdated: String = String()

                do {
                    do {
                        _ID = try Comment.extract(param: "ID", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["ID"]!.append(eventLoop.makeSucceededFuture(("ID", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _IDUser = try Comment.extract(param: "IDUser", from: dictionary)

                        if let error = Validation.UUID().validate(_IDUser, requestInfo.locale) {
                            validatorFutures["IDUser"]!.append(eventLoop.makeSucceededFuture(("IDUser", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["IDUser"]!.append(eventLoop.makeSucceededFuture(("IDUser", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _userName = try Comment.extract(param: "userName", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["userName"]!.append(eventLoop.makeSucceededFuture(("userName", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _IDPost = try Comment.extract(param: "IDPost", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["IDPost"]!.append(eventLoop.makeSucceededFuture(("IDPost", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _IDReplyComment = try Comment.extract(param: "IDReplyComment", from: dictionary, isOptional: true)
                    } catch Entita.E.ExtractError {
                        validatorFutures["IDReplyComment"]!.append(eventLoop.makeSucceededFuture(("IDReplyComment", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _status = try Comment.extract(param: "status", from: dictionary)

                        if let error = Validation.In(allowedValues: ["pending", "deleted", "hidden", "published"]).validate(_status, requestInfo.locale) {
                            validatorFutures["status"]!.append(eventLoop.makeSucceededFuture(("status", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["status"]!.append(eventLoop.makeSucceededFuture(("status", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _body = try Comment.extract(param: "body", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["body"]!.append(eventLoop.makeSucceededFuture(("body", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _likes = try Comment.extract(param: "likes", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["likes"]!.append(eventLoop.makeSucceededFuture(("likes", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _dateCreated = try Comment.extract(param: "dateCreated", from: dictionary)

                        if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(_dateCreated, requestInfo.locale) {
                            validatorFutures["dateCreated"]!.append(eventLoop.makeSucceededFuture(("dateCreated", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["dateCreated"]!.append(eventLoop.makeSucceededFuture(("dateCreated", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _dateUpdated = try Comment.extract(param: "dateUpdated", from: dictionary)

                        if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(_dateUpdated, requestInfo.locale) {
                            validatorFutures["dateUpdated"]!.append(eventLoop.makeSucceededFuture(("dateUpdated", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["dateUpdated"]!.append(eventLoop.makeSucceededFuture(("dateUpdated", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                } catch {
                    return eventLoop.makeFailedFuture(error)
                }

                return self
                    .reduce(validators: validatorFutures, on: eventLoop)
                    .flatMapThrowing { errors in
                        guard errors.count == 0 else {
                            throw LGNC.E.DecodeError(errors)
                        }
                        return self.init(
                            ID: _ID,
                            IDUser: _IDUser,
                            userName: _userName,
                            IDPost: _IDPost,
                            IDReplyComment: _IDReplyComment,
                            status: _status,
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
                    status: try Comment.extract(param: "status", from: dictionary),
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
                    self.getDictionaryKey("status"): try self.encode(self.status),
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

            public static func initWithValidation(from _: Entita.Dict, requestInfo: LGNCore.RequestInfo) -> Future<Empty> {
                let eventLoop = requestInfo.eventLoop

                var validatorFutures: [String: [Future<(String, ValidatorError?)>]] = [
                    :
                ]

                do {
                } catch {
                    return eventLoop.makeFailedFuture(error)
                }

                return self
                    .reduce(validators: validatorFutures, on: eventLoop)
                    .flatMapThrowing { errors in
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
                "authorName": "m",
                "accessLevel": "n",
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
            public var authorName: String
            public var accessLevel: String

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
                authorName: String,
                accessLevel: String
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
                self.authorName = authorName
                self.accessLevel = accessLevel
            }

            public static func initWithValidation(from dictionary: Entita.Dict, requestInfo: LGNCore.RequestInfo) -> Future<User> {
                let eventLoop = requestInfo.eventLoop

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
                    "authorName": [],
                    "accessLevel": [],
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
                var _authorName: String = String()
                var _accessLevel: String = String()

                do {
                    do {
                        _ID = try User.extract(param: "ID", from: dictionary)

                        if let error = Validation.UUID().validate(_ID, requestInfo.locale) {
                            validatorFutures["ID"]!.append(eventLoop.makeSucceededFuture(("ID", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["ID"]!.append(eventLoop.makeSucceededFuture(("ID", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _username = try User.extract(param: "username", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["username"]!.append(eventLoop.makeSucceededFuture(("username", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _email = try User.extract(param: "email", from: dictionary)

                        if let error = Validation.Regexp(pattern: "^.+@.+\\..+$", message: "Invalid email format").validate(_email, requestInfo.locale) {
                            validatorFutures["email"]!.append(eventLoop.makeSucceededFuture(("email", error)))
                        }

                        if let error = Validation.Length.Min(length: 6).validate(_email, requestInfo.locale) {
                            validatorFutures["email"]!.append(eventLoop.makeSucceededFuture(("email", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["email"]!.append(eventLoop.makeSucceededFuture(("email", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _password = try User.extract(param: "password", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["password"]!.append(eventLoop.makeSucceededFuture(("password", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _sex = try User.extract(param: "sex", from: dictionary)

                        if let error = Validation.In(allowedValues: ["Male", "Female", "Attack helicopter"]).validate(_sex, requestInfo.locale) {
                            validatorFutures["sex"]!.append(eventLoop.makeSucceededFuture(("sex", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["sex"]!.append(eventLoop.makeSucceededFuture(("sex", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _isBanned = try User.extract(param: "isBanned", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["isBanned"]!.append(eventLoop.makeSucceededFuture(("isBanned", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _ip = try User.extract(param: "ip", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["ip"]!.append(eventLoop.makeSucceededFuture(("ip", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _country = try User.extract(param: "country", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["country"]!.append(eventLoop.makeSucceededFuture(("country", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _dateUnsuccessfulLogin = try User.extract(param: "dateUnsuccessfulLogin", from: dictionary)

                        if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(_dateUnsuccessfulLogin, requestInfo.locale) {
                            validatorFutures["dateUnsuccessfulLogin"]!.append(eventLoop.makeSucceededFuture(("dateUnsuccessfulLogin", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["dateUnsuccessfulLogin"]!.append(eventLoop.makeSucceededFuture(("dateUnsuccessfulLogin", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _dateSignup = try User.extract(param: "dateSignup", from: dictionary)

                        if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(_dateSignup, requestInfo.locale) {
                            validatorFutures["dateSignup"]!.append(eventLoop.makeSucceededFuture(("dateSignup", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["dateSignup"]!.append(eventLoop.makeSucceededFuture(("dateSignup", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _dateLogin = try User.extract(param: "dateLogin", from: dictionary)

                        if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(_dateLogin, requestInfo.locale) {
                            validatorFutures["dateLogin"]!.append(eventLoop.makeSucceededFuture(("dateLogin", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["dateLogin"]!.append(eventLoop.makeSucceededFuture(("dateLogin", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _authorName = try User.extract(param: "authorName", from: dictionary)
                    } catch Entita.E.ExtractError {
                        validatorFutures["authorName"]!.append(eventLoop.makeSucceededFuture(("authorName", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                    do {
                        _accessLevel = try User.extract(param: "accessLevel", from: dictionary)

                        if let error = Validation.In(allowedValues: ["User", "Moderator", "Admin"]).validate(_accessLevel, requestInfo.locale) {
                            validatorFutures["accessLevel"]!.append(eventLoop.makeSucceededFuture(("accessLevel", error)))
                        }
                    } catch Entita.E.ExtractError {
                        validatorFutures["accessLevel"]!.append(eventLoop.makeSucceededFuture(("accessLevel", Validation.Error.MissingValue(requestInfo.locale))))
                    }
                } catch {
                    return eventLoop.makeFailedFuture(error)
                }

                return self
                    .reduce(validators: validatorFutures, on: eventLoop)
                    .flatMapThrowing { errors in
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
                            authorName: _authorName,
                            accessLevel: _accessLevel
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
                    authorName: try User.extract(param: "authorName", from: dictionary),
                    accessLevel: try User.extract(param: "accessLevel", from: dictionary)
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
                    self.getDictionaryKey("authorName"): try self.encode(self.authorName),
                    self.getDictionaryKey("accessLevel"): try self.encode(self.accessLevel),
                ]
            }
        }
    }
}
