import Entita
import LGNC
import LGNCore
import LGNP
import LGNS
import NIO

public enum Services {
    public enum Shared {
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

                let map: [String: String]? = try? self.extract(param: "map", from: dictionary)

                let validatorFutures: [String: Future<Void>] = [
                    "map": eventLoop.submit {
                        guard let _ = map else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                ]

                return self
                    .reduce(validators: validatorFutures, requestInfo: requestInfo)
                    .flatMapThrowing { errors in
                        guard errors.count == 0 else {
                            throw LGNC.E.DecodeError(errors.mapValues { [$0] })
                        }

                        return self.init(
                            map: map!
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

                let Request: FieldMapping? = try? self.extract(param: "Request", from: dictionary)
                let Response: FieldMapping? = try? self.extract(param: "Response", from: dictionary)

                let validatorFutures: [String: Future<Void>] = [
                    "Request": eventLoop.submit {
                        guard let _ = Request else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                    "Response": eventLoop.submit {
                        guard let _ = Response else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                ]

                return self
                    .reduce(validators: validatorFutures, requestInfo: requestInfo)
                    .flatMapThrowing { errors in
                        guard errors.count == 0 else {
                            throw LGNC.E.DecodeError(errors.mapValues { [$0] })
                        }

                        return self.init(
                            Request: Request!,
                            Response: Response!
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

                let map: [String: ServiceFieldMapping]? = try? self.extract(param: "map", from: dictionary)

                let validatorFutures: [String: Future<Void>] = [
                    "map": eventLoop.submit {
                        guard let _ = map else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                ]

                return self
                    .reduce(validators: validatorFutures, requestInfo: requestInfo)
                    .flatMapThrowing { errors in
                        guard errors.count == 0 else {
                            throw LGNC.E.DecodeError(errors.mapValues { [$0] })
                        }

                        return self.init(
                            map: map!
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

                let monad: String? = try? self.extract(param: "monad", from: dictionary)

                let validatorFutures: [String: Future<Void>] = [
                    "monad": eventLoop.submit {
                        guard let _ = monad else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                ]

                return self
                    .reduce(validators: validatorFutures, requestInfo: requestInfo)
                    .flatMapThrowing { errors in
                        guard errors.count == 0 else {
                            throw LGNC.E.DecodeError(errors.mapValues { [$0] })
                        }

                        return self.init(
                            monad: monad!
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

                let event: String? = try? self.extract(param: "event", from: dictionary)

                let validatorFutures: [String: Future<Void>] = [
                    "event": eventLoop.submit {
                        guard let _ = event else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                ]

                return self
                    .reduce(validators: validatorFutures, requestInfo: requestInfo)
                    .flatMapThrowing { errors in
                        guard errors.count == 0 else {
                            throw LGNC.E.DecodeError(errors.mapValues { [$0] })
                        }

                        return self.init(
                            event: event!
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

                let username: String? = try? self.extract(param: "username", from: dictionary)
                let email: String? = try? self.extract(param: "email", from: dictionary)
                let password1: String? = try? self.extract(param: "password1", from: dictionary)
                let password2: String? = try? self.extract(param: "password2", from: dictionary)
                let sex: String? = try? self.extract(param: "sex", from: dictionary)
                let language: String? = try? self.extract(param: "language", from: dictionary)
                let recaptchaToken: String? = try? self.extract(param: "recaptchaToken", from: dictionary)

                let validatorFutures: [String: Future<Void>] = [
                    "username": eventLoop.submit {
                        guard let _ = username else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    }.flatMap {
                        if let error = Validation.Regexp(pattern: "^[a-zA-Zа-яА-Я0-9_\\- ]+$", message: "Username must only consist of letters, numbers and underscores").validate(username!, requestInfo.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    }.flatMap {
                        if let error = Validation.Length.Min(length: 3).validate(username!, requestInfo.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    }.flatMap {
                        if let error = Validation.Length.Max(length: 24).validate(username!, requestInfo.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    }.flatMap {
                        guard let validator = self.validatorUsernameClosure else {
                            return eventLoop.makeSucceededFuture()
                        }
                        return Validation.CallbackWithAllowedValues<CallbackValidatorUsernameAllowedValues>(callback: validator).validate(
                            username!,
                            requestInfo.locale,
                            on: eventLoop
                        ).mapThrowing { maybeError in if let error = maybeError { throw error } }
                    },
                    "email": eventLoop.submit {
                        guard let _ = email else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    }.flatMap {
                        if let error = Validation.Regexp(pattern: "^.+@.+\\..+$", message: "Invalid email format").validate(email!, requestInfo.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    }.flatMap {
                        guard let validator = self.validatorEmailClosure else {
                            return eventLoop.makeSucceededFuture()
                        }
                        return Validation.CallbackWithAllowedValues<CallbackValidatorEmailAllowedValues>(callback: validator).validate(
                            email!,
                            requestInfo.locale,
                            on: eventLoop
                        ).mapThrowing { maybeError in if let error = maybeError { throw error } }
                    },
                    "password1": eventLoop.submit {
                        guard let _ = password1 else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    }.flatMap {
                        if let error = Validation.Length.Min(length: 6, message: "Password must be at least {Length} characters long").validate(password1!, requestInfo.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    }.flatMap {
                        if let error = Validation.Length.Max(length: 64, message: "Password must be less than {Length} characters long").validate(password1!, requestInfo.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                    "password2": eventLoop.submit {
                        guard let _ = password2 else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    }.flatMap {
                        if let error = Validation.Identical(right: password1!, message: "Passwords must match").validate(password2!, requestInfo.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                    "sex": eventLoop.submit {
                        guard let _ = sex else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    }.flatMap {
                        if let error = Validation.In(allowedValues: ["Male", "Female", "Attack helicopter"]).validate(sex!, requestInfo.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                    "language": eventLoop.submit {
                        guard let _ = language else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    }.flatMap {
                        if let error = Validation.In(allowedValues: ["en", "ru"]).validate(language!, requestInfo.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                    "recaptchaToken": eventLoop.submit {
                        guard let _ = recaptchaToken else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                ]

                return self
                    .reduce(validators: validatorFutures, requestInfo: requestInfo)
                    .flatMapThrowing { errors in
                        guard errors.count == 0 else {
                            throw LGNC.E.DecodeError(errors.mapValues { [$0] })
                        }

                        return self.init(
                            username: username!,
                            email: email!,
                            password1: password1!,
                            password2: password2!,
                            sex: sex!,
                            language: language!,
                            recaptchaToken: recaptchaToken!
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

                let type: String? = try? self.extract(param: "type", from: dictionary)
                let id: String? = try? self.extract(param: "id", from: dictionary)
                let name: String? = try? self.extract(param: "name", from: dictionary)
                let port: Int? = try? self.extract(param: "port", from: dictionary)

                let validatorFutures: [String: Future<Void>] = [
                    "type": eventLoop.submit {
                        guard let _ = type else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                    "id": eventLoop.submit {
                        guard let _ = id else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                    "name": eventLoop.submit {
                        guard let _ = name else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    }.flatMap {
                        guard let validator = self.validatorNameClosure else {
                            return eventLoop.makeSucceededFuture()
                        }
                        return Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>(callback: validator).validate(
                            name!,
                            requestInfo.locale,
                            on: eventLoop
                        ).mapThrowing { maybeError in if let error = maybeError { throw error } }
                    },
                    "port": eventLoop.submit {
                        guard let _ = port else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                ]

                return self
                    .reduce(validators: validatorFutures, requestInfo: requestInfo)
                    .flatMapThrowing { errors in
                        guard errors.count == 0 else {
                            throw LGNC.E.DecodeError(errors.mapValues { [$0] })
                        }

                        return self.init(
                            type: type!,
                            id: id!,
                            name: name!,
                            port: port!
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

                let name: String? = try? self.extract(param: "name", from: dictionary)
                let entities: Int? = try? self.extract(param: "entities", from: dictionary)

                let validatorFutures: [String: Future<Void>] = [
                    "name": eventLoop.submit {
                        guard let _ = name else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    }.flatMap {
                        guard let validator = self.validatorNameClosure else {
                            return eventLoop.makeSucceededFuture()
                        }
                        return Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>(callback: validator).validate(
                            name!,
                            requestInfo.locale,
                            on: eventLoop
                        ).mapThrowing { maybeError in if let error = maybeError { throw error } }
                    },
                    "entities": eventLoop.submit {
                        guard let _ = entities else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                ]

                return self
                    .reduce(validators: validatorFutures, requestInfo: requestInfo)
                    .flatMapThrowing { errors in
                        guard errors.count == 0 else {
                            throw LGNC.E.DecodeError(errors.mapValues { [$0] })
                        }

                        return self.init(
                            name: name!,
                            entities: entities!
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

                let result: String? = try? self.extract(param: "result", from: dictionary)

                let validatorFutures: [String: Future<Void>] = [
                    "result": eventLoop.submit {
                        guard let _ = result else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                ]

                return self
                    .reduce(validators: validatorFutures, requestInfo: requestInfo)
                    .flatMapThrowing { errors in
                        guard errors.count == 0 else {
                            throw LGNC.E.DecodeError(errors.mapValues { [$0] })
                        }

                        return self.init(
                            result: result!
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

                let type: String? = try? self.extract(param: "type", from: dictionary)
                let name: String? = try? self.extract(param: "name", from: dictionary)
                let port: Int? = try? self.extract(param: "port", from: dictionary)
                let entities: Int? = try? self.extract(param: "entities", from: dictionary)

                let validatorFutures: [String: Future<Void>] = [
                    "type": eventLoop.submit {
                        guard let _ = type else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                    "name": eventLoop.submit {
                        guard let _ = name else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    }.flatMap {
                        guard let validator = self.validatorNameClosure else {
                            return eventLoop.makeSucceededFuture()
                        }
                        return Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>(callback: validator).validate(
                            name!,
                            requestInfo.locale,
                            on: eventLoop
                        ).mapThrowing { maybeError in if let error = maybeError { throw error } }
                    },
                    "port": eventLoop.submit {
                        guard let _ = port else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                    "entities": eventLoop.submit {
                        guard let _ = entities else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                ]

                return self
                    .reduce(validators: validatorFutures, requestInfo: requestInfo)
                    .flatMapThrowing { errors in
                        guard errors.count == 0 else {
                            throw LGNC.E.DecodeError(errors.mapValues { [$0] })
                        }

                        return self.init(
                            type: type!,
                            name: name!,
                            port: port!,
                            entities: entities!
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

                let result: String? = try? self.extract(param: "result", from: dictionary)

                let validatorFutures: [String: Future<Void>] = [
                    "result": eventLoop.submit {
                        guard let _ = result else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                ]

                return self
                    .reduce(validators: validatorFutures, requestInfo: requestInfo)
                    .flatMapThrowing { errors in
                        guard errors.count == 0 else {
                            throw LGNC.E.DecodeError(errors.mapValues { [$0] })
                        }

                        return self.init(
                            result: result!
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

                let portal: String? = try? self.extract(param: "portal", from: dictionary)
                let email: String? = try? self.extract(param: "email", from: dictionary)
                let password: String? = try? self.extract(param: "password", from: dictionary)
                let recaptchaToken: String?? = try? self.extract(param: "recaptchaToken", from: dictionary, isOptional: true)

                let validatorFutures: [String: Future<Void>] = [
                    "portal": eventLoop.submit {
                        guard let _ = portal else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                    "email": eventLoop.submit {
                        guard let _ = email else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                    "password": eventLoop.submit {
                        guard let _ = password else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                    "recaptchaToken": eventLoop.submit {
                        let _: String? = try self.extract(param: "recaptchaToken", from: dictionary, isOptional: true)
                        guard let recaptchaToken = recaptchaToken else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                        if recaptchaToken == nil {
                            throw Validation.Error.SkipMissingOptionalValueValidators()
                        }
                    },
                ]

                return self
                    .reduce(validators: validatorFutures, requestInfo: requestInfo)
                    .flatMapThrowing { errors in
                        guard errors.count == 0 else {
                            throw LGNC.E.DecodeError(errors.mapValues { [$0] })
                        }

                        return self.init(
                            portal: portal!,
                            email: email!,
                            password: password!,
                            recaptchaToken: recaptchaToken!
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

                let token: String? = try? self.extract(param: "token", from: dictionary)
                let userID: String? = try? self.extract(param: "userID", from: dictionary)

                let validatorFutures: [String: Future<Void>] = [
                    "token": eventLoop.submit {
                        guard let _ = token else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                    "userID": eventLoop.submit {
                        guard let _ = userID else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                ]

                return self
                    .reduce(validators: validatorFutures, requestInfo: requestInfo)
                    .flatMapThrowing { errors in
                        guard errors.count == 0 else {
                            throw LGNC.E.DecodeError(errors.mapValues { [$0] })
                        }

                        return self.init(
                            token: token!,
                            userID: userID!
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
                "ID": "a",
                "username": "c",
                "accessLevel": "d",
            ]

            public let ID: String
            public let username: String
            public let accessLevel: String

            public init(
                ID: String,
                username: String,
                accessLevel: String
            ) {
                self.ID = ID
                self.username = username
                self.accessLevel = accessLevel
            }

            public static func initWithValidation(from dictionary: Entita.Dict, requestInfo: LGNCore.RequestInfo) -> Future<CommentUserInfo> {
                let eventLoop = requestInfo.eventLoop

                let ID: String? = try? self.extract(param: "ID", from: dictionary)
                let username: String? = try? self.extract(param: "username", from: dictionary)
                let accessLevel: String? = try? self.extract(param: "accessLevel", from: dictionary)

                let validatorFutures: [String: Future<Void>] = [
                    "ID": eventLoop.submit {
                        guard let _ = ID else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    }.flatMap {
                        if let error = Validation.UUID().validate(ID!, requestInfo.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                    "username": eventLoop.submit {
                        guard let _ = username else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                    "accessLevel": eventLoop.submit {
                        guard let _ = accessLevel else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    }.flatMap {
                        if let error = Validation.In(allowedValues: ["User", "Moderator", "Admin"]).validate(accessLevel!, requestInfo.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                ]

                return self
                    .reduce(validators: validatorFutures, requestInfo: requestInfo)
                    .flatMapThrowing { errors in
                        guard errors.count == 0 else {
                            throw LGNC.E.DecodeError(errors.mapValues { [$0] })
                        }

                        return self.init(
                            ID: ID!,
                            username: username!,
                            accessLevel: accessLevel!
                        )
                    }
            }

            public convenience init(from dictionary: Entita.Dict) throws {
                self.init(
                    ID: try CommentUserInfo.extract(param: "ID", from: dictionary),
                    username: try CommentUserInfo.extract(param: "username", from: dictionary),
                    accessLevel: try CommentUserInfo.extract(param: "accessLevel", from: dictionary)
                )
            }

            public func getDictionary() throws -> Entita.Dict {
                return [
                    self.getDictionaryKey("ID"): try self.encode(self.ID),
                    self.getDictionaryKey("username"): try self.encode(self.username),
                    self.getDictionaryKey("accessLevel"): try self.encode(self.accessLevel),
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
                let validatorFutures: [String: Future<Void>] = [
                    :
                ]

                return self
                    .reduce(validators: validatorFutures, requestInfo: requestInfo)
                    .flatMapThrowing { errors in
                        guard errors.count == 0 else {
                            throw LGNC.E.DecodeError(errors.mapValues { [$0] })
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

        public final class Comment: ContractEntity {
            public static let keyDictionary: [String: String] = [
                "ID": "a",
                "user": "c",
                "IDPost": "d",
                "IDReplyComment": "e",
                "isEditable": "f",
                "status": "g",
                "body": "h",
                "likes": "i",
                "dateCreated": "j",
                "dateUpdated": "k",
            ]

            public let ID: Int
            public let user: CommentUserInfo
            public let IDPost: Int
            public let IDReplyComment: Int?
            public let isEditable: Bool
            public let status: String
            public let body: String
            public let likes: Int
            public let dateCreated: String
            public let dateUpdated: String

            public init(
                ID: Int,
                user: CommentUserInfo,
                IDPost: Int,
                IDReplyComment: Int? = nil,
                isEditable: Bool,
                status: String,
                body: String,
                likes: Int,
                dateCreated: String,
                dateUpdated: String
            ) {
                self.ID = ID
                self.user = user
                self.IDPost = IDPost
                self.IDReplyComment = IDReplyComment
                self.isEditable = isEditable
                self.status = status
                self.body = body
                self.likes = likes
                self.dateCreated = dateCreated
                self.dateUpdated = dateUpdated
            }

            public static func await(
                ID: Int,
                user: CommentUserInfo,
                IDPost: Int,
                IDReplyComment: Int?,
                isEditable: Bool,
                status: String,
                body: String,
                likes likesFuture: Future<Int>,
                dateCreated: String,
                dateUpdated: String
            ) -> Future<Comment> {
                return likesFuture.eventLoop.makeSucceededFuture(()).flatMap { () in
                    likesFuture.map { likes in likes }
                }
                .map { likes in
                    Comment(
                        ID: ID,
                        user: user,
                        IDPost: IDPost,
                        IDReplyComment: IDReplyComment,
                        isEditable: isEditable,
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

                let ID: Int? = try? self.extract(param: "ID", from: dictionary)
                let user: CommentUserInfo? = try? self.extract(param: "user", from: dictionary)
                let IDPost: Int? = try? self.extract(param: "IDPost", from: dictionary)
                let IDReplyComment: Int?? = try? self.extract(param: "IDReplyComment", from: dictionary, isOptional: true)
                let isEditable: Bool? = try? self.extract(param: "isEditable", from: dictionary)
                let status: String? = try? self.extract(param: "status", from: dictionary)
                let body: String? = try? self.extract(param: "body", from: dictionary)
                let likes: Int? = try? self.extract(param: "likes", from: dictionary)
                let dateCreated: String? = try? self.extract(param: "dateCreated", from: dictionary)
                let dateUpdated: String? = try? self.extract(param: "dateUpdated", from: dictionary)

                let validatorFutures: [String: Future<Void>] = [
                    "ID": eventLoop.submit {
                        guard let _ = ID else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                    "user": eventLoop.submit {
                        guard let _ = user else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                    "IDPost": eventLoop.submit {
                        guard let _ = IDPost else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                    "IDReplyComment": eventLoop.submit {
                        let _: Int? = try self.extract(param: "IDReplyComment", from: dictionary, isOptional: true)
                        guard let IDReplyComment = IDReplyComment else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                        if IDReplyComment == nil {
                            throw Validation.Error.SkipMissingOptionalValueValidators()
                        }
                    },
                    "isEditable": eventLoop.submit {
                        guard let _ = isEditable else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                    "status": eventLoop.submit {
                        guard let _ = status else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    }.flatMap {
                        if let error = Validation.In(allowedValues: ["pending", "deleted", "hidden", "published"]).validate(status!, requestInfo.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                    "body": eventLoop.submit {
                        guard let _ = body else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                    "likes": eventLoop.submit {
                        guard let _ = likes else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                    "dateCreated": eventLoop.submit {
                        guard let _ = dateCreated else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    }.flatMap {
                        if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(dateCreated!, requestInfo.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                    "dateUpdated": eventLoop.submit {
                        guard let _ = dateUpdated else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    }.flatMap {
                        if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(dateUpdated!, requestInfo.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                ]

                return self
                    .reduce(validators: validatorFutures, requestInfo: requestInfo)
                    .flatMapThrowing { errors in
                        guard errors.count == 0 else {
                            throw LGNC.E.DecodeError(errors.mapValues { [$0] })
                        }

                        return self.init(
                            ID: ID!,
                            user: user!,
                            IDPost: IDPost!,
                            IDReplyComment: IDReplyComment!,
                            isEditable: isEditable!,
                            status: status!,
                            body: body!,
                            likes: likes!,
                            dateCreated: dateCreated!,
                            dateUpdated: dateUpdated!
                        )
                    }
            }

            public convenience init(from dictionary: Entita.Dict) throws {
                self.init(
                    ID: try Comment.extract(param: "ID", from: dictionary),
                    user: try Comment.extract(param: "user", from: dictionary),
                    IDPost: try Comment.extract(param: "IDPost", from: dictionary),
                    IDReplyComment: try Comment.extract(param: "IDReplyComment", from: dictionary, isOptional: true),
                    isEditable: try Comment.extract(param: "isEditable", from: dictionary),
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
                    self.getDictionaryKey("user"): try self.encode(self.user),
                    self.getDictionaryKey("IDPost"): try self.encode(self.IDPost),
                    self.getDictionaryKey("IDReplyComment"): try self.encode(self.IDReplyComment),
                    self.getDictionaryKey("isEditable"): try self.encode(self.isEditable),
                    self.getDictionaryKey("status"): try self.encode(self.status),
                    self.getDictionaryKey("body"): try self.encode(self.body),
                    self.getDictionaryKey("likes"): try self.encode(self.likes),
                    self.getDictionaryKey("dateCreated"): try self.encode(self.dateCreated),
                    self.getDictionaryKey("dateUpdated"): try self.encode(self.dateUpdated),
                ]
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

                let ID: String? = try? self.extract(param: "ID", from: dictionary)
                let username: String? = try? self.extract(param: "username", from: dictionary)
                let email: String? = try? self.extract(param: "email", from: dictionary)
                let password: String? = try? self.extract(param: "password", from: dictionary)
                let sex: String? = try? self.extract(param: "sex", from: dictionary)
                let isBanned: Bool? = try? self.extract(param: "isBanned", from: dictionary)
                let ip: String? = try? self.extract(param: "ip", from: dictionary)
                let country: String? = try? self.extract(param: "country", from: dictionary)
                let dateUnsuccessfulLogin: String? = try? self.extract(param: "dateUnsuccessfulLogin", from: dictionary)
                let dateSignup: String? = try? self.extract(param: "dateSignup", from: dictionary)
                let dateLogin: String? = try? self.extract(param: "dateLogin", from: dictionary)
                let authorName: String? = try? self.extract(param: "authorName", from: dictionary)
                let accessLevel: String? = try? self.extract(param: "accessLevel", from: dictionary)

                let validatorFutures: [String: Future<Void>] = [
                    "ID": eventLoop.submit {
                        guard let _ = ID else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    }.flatMap {
                        if let error = Validation.UUID().validate(ID!, requestInfo.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                    "username": eventLoop.submit {
                        guard let _ = username else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                    "email": eventLoop.submit {
                        guard let _ = email else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    }.flatMap {
                        if let error = Validation.Regexp(pattern: "^.+@.+\\..+$", message: "Invalid email format").validate(email!, requestInfo.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    }.flatMap {
                        if let error = Validation.Length.Min(length: 6).validate(email!, requestInfo.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                    "password": eventLoop.submit {
                        guard let _ = password else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                    "sex": eventLoop.submit {
                        guard let _ = sex else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    }.flatMap {
                        if let error = Validation.In(allowedValues: ["Male", "Female", "Attack helicopter"]).validate(sex!, requestInfo.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                    "isBanned": eventLoop.submit {
                        guard let _ = isBanned else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                    "ip": eventLoop.submit {
                        guard let _ = ip else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                    "country": eventLoop.submit {
                        guard let _ = country else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                    "dateUnsuccessfulLogin": eventLoop.submit {
                        guard let _ = dateUnsuccessfulLogin else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    }.flatMap {
                        if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(dateUnsuccessfulLogin!, requestInfo.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                    "dateSignup": eventLoop.submit {
                        guard let _ = dateSignup else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    }.flatMap {
                        if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(dateSignup!, requestInfo.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                    "dateLogin": eventLoop.submit {
                        guard let _ = dateLogin else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    }.flatMap {
                        if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(dateLogin!, requestInfo.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                    "authorName": eventLoop.submit {
                        guard let _ = authorName else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    },
                    "accessLevel": eventLoop.submit {
                        guard let _ = accessLevel else {
                            throw Validation.Error.MissingValue(requestInfo.locale)
                        }
                    }.flatMap {
                        if let error = Validation.In(allowedValues: ["User", "Moderator", "Admin"]).validate(accessLevel!, requestInfo.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                ]

                return self
                    .reduce(validators: validatorFutures, requestInfo: requestInfo)
                    .flatMapThrowing { errors in
                        guard errors.count == 0 else {
                            throw LGNC.E.DecodeError(errors.mapValues { [$0] })
                        }

                        return self.init(
                            ID: ID!,
                            username: username!,
                            email: email!,
                            password: password!,
                            sex: sex!,
                            isBanned: isBanned!,
                            ip: ip!,
                            country: country!,
                            dateUnsuccessfulLogin: dateUnsuccessfulLogin!,
                            dateSignup: dateSignup!,
                            dateLogin: dateLogin!,
                            authorName: authorName!,
                            accessLevel: accessLevel!
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
