import LGNCore
import Entita
import LGNS
import LGNC
import LGNP
import NIO

public enum Services {
    public enum Shared {}

    public static let list: [String: Service.Type] = [
        "Author": Author.self,
        "Quorum": Quorum.self,
    ]
}

public extension Services.Shared {
    final class FieldMapping: ContractEntity {
        public static let keyDictionary: [String: String] = [:]

        public let map: [String:String]

        public init(map: [String:String] = [String:String]()) {
            self.map = map
        }

        public static func initWithValidation(
            from dictionary: Entita.Dict, context: LGNCore.Context
        ) -> EventLoopFuture<FieldMapping> {
            let eventLoop = context.eventLoop

            if let error = self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "map",
                ]
            ) {
                return eventLoop.makeFailedFuture(error)
            }

            let map: [String:String]? = try? (self.extract(param: "map", from: dictionary) as [String:String])

            let validatorFutures: [String: EventLoopFuture<Void>] = [
                "map": eventLoop
                    .submit {
                        guard let _ = map else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
            ]

            return self
                .reduce(validators: validatorFutures, context: context)
                .flatMapThrowing {
                    guard $0.count == 0 else {
                        throw LGNC.E.DecodeError($0)
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
            [
                self.getDictionaryKey("map"): try self.encode(self.map),
            ]
        }

    }

    final class ServiceFieldMapping: ContractEntity {
        public static let keyDictionary: [String: String] = [:]

        public let Request: Services.Shared.FieldMapping
        public let Response: Services.Shared.FieldMapping

        public init(Request: Services.Shared.FieldMapping, Response: Services.Shared.FieldMapping) {
            self.Request = Request
            self.Response = Response
        }

        public static func initWithValidation(
            from dictionary: Entita.Dict, context: LGNCore.Context
        ) -> EventLoopFuture<ServiceFieldMapping> {
            let eventLoop = context.eventLoop

            if let error = self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "Request",
                    "Response",
                ]
            ) {
                return eventLoop.makeFailedFuture(error)
            }

            let Request: Services.Shared.FieldMapping? = try? (self.extract(param: "Request", from: dictionary) as Services.Shared.FieldMapping)
            let Response: Services.Shared.FieldMapping? = try? (self.extract(param: "Response", from: dictionary) as Services.Shared.FieldMapping)

            let validatorFutures: [String: EventLoopFuture<Void>] = [
                "Request": eventLoop
                    .submit {
                        guard let _ = Request else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
                "Response": eventLoop
                    .submit {
                        guard let _ = Response else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
            ]

            return self
                .reduce(validators: validatorFutures, context: context)
                .flatMapThrowing {
                    guard $0.count == 0 else {
                        throw LGNC.E.DecodeError($0)
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
            [
                self.getDictionaryKey("Request"): try self.encode(self.Request),
                self.getDictionaryKey("Response"): try self.encode(self.Response),
            ]
        }

    }

    final class ServiceFieldMappings: ContractEntity {
        public static let keyDictionary: [String: String] = [:]

        public let map: [String:Services.Shared.ServiceFieldMapping]

        public init(map: [String:Services.Shared.ServiceFieldMapping]) {
            self.map = map
        }

        public static func initWithValidation(
            from dictionary: Entita.Dict, context: LGNCore.Context
        ) -> EventLoopFuture<ServiceFieldMappings> {
            let eventLoop = context.eventLoop

            if let error = self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "map",
                ]
            ) {
                return eventLoop.makeFailedFuture(error)
            }

            let map: [String:Services.Shared.ServiceFieldMapping]? = try? (self.extract(param: "map", from: dictionary) as [String:Services.Shared.ServiceFieldMapping])

            let validatorFutures: [String: EventLoopFuture<Void>] = [
                "map": eventLoop
                    .submit {
                        guard let _ = map else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
            ]

            return self
                .reduce(validators: validatorFutures, context: context)
                .flatMapThrowing {
                    guard $0.count == 0 else {
                        throw LGNC.E.DecodeError($0)
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
            [
                self.getDictionaryKey("map"): try self.encode(self.map),
            ]
        }

    }

    final class CharacterInfo: ContractEntity {
        public static let keyDictionary: [String: String] = [:]

        public let monad: String

        public init(monad: String) {
            self.monad = monad
        }

        public static func initWithValidation(
            from dictionary: Entita.Dict, context: LGNCore.Context
        ) -> EventLoopFuture<CharacterInfo> {
            let eventLoop = context.eventLoop

            if let error = self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "monad",
                ]
            ) {
                return eventLoop.makeFailedFuture(error)
            }

            let monad: String? = try? (self.extract(param: "monad", from: dictionary) as String)

            let validatorFutures: [String: EventLoopFuture<Void>] = [
                "monad": eventLoop
                    .submit {
                        guard let _ = monad else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
            ]

            return self
                .reduce(validators: validatorFutures, context: context)
                .flatMapThrowing {
                    guard $0.count == 0 else {
                        throw LGNC.E.DecodeError($0)
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
            [
                self.getDictionaryKey("monad"): try self.encode(self.monad),
            ]
        }

    }

    final class EventRequest: ContractEntity {
        public static let keyDictionary: [String: String] = [:]

        public let event: String

        public init(event: String) {
            self.event = event
        }

        public static func initWithValidation(
            from dictionary: Entita.Dict, context: LGNCore.Context
        ) -> EventLoopFuture<EventRequest> {
            let eventLoop = context.eventLoop

            if let error = self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "event",
                ]
            ) {
                return eventLoop.makeFailedFuture(error)
            }

            let event: String? = try? (self.extract(param: "event", from: dictionary) as String)

            let validatorFutures: [String: EventLoopFuture<Void>] = [
                "event": eventLoop
                    .submit {
                        guard let _ = event else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
            ]

            return self
                .reduce(validators: validatorFutures, context: context)
                .flatMapThrowing {
                    guard $0.count == 0 else {
                        throw LGNC.E.DecodeError($0)
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
            [
                self.getDictionaryKey("event"): try self.encode(self.event),
            ]
        }

    }

    final class UserSignupRequest: ContractEntity {
        public static let keyDictionary: [String: String] = [:]

        private static var validatorUsernameClosure: Validation.CallbackWithAllowedValues<CallbackValidatorUsernameAllowedValues>.Callback? = nil
        private static var validatorEmailClosure: Validation.CallbackWithAllowedValues<CallbackValidatorEmailAllowedValues>.Callback? = nil

        public enum CallbackValidatorUsernameAllowedValues: String, CallbackWithAllowedValuesRepresentable, ValidatorErrorRepresentable {
            public typealias InputValue = String

            case UserWithGivenUsernameAlreadyExists = "User with given username already exists"

            public func getErrorTuple() -> ErrorTuple {
                switch self {
                    case .UserWithGivenUsernameAlreadyExists: return (code: 10001, message: self.rawValue)
                }
            }
        }

        public enum CallbackValidatorEmailAllowedValues: String, CallbackWithAllowedValuesRepresentable, ValidatorErrorRepresentable {
            public typealias InputValue = String

            case UserWithGivenEmailAlreadyExists = "User with given email already exists"

            public func getErrorTuple() -> ErrorTuple {
                switch self {
                    case .UserWithGivenEmailAlreadyExists: return (code: 10001, message: self.rawValue)
                }
            }
        }

        public let username: String
        public let email: String
        public let password1: String
        public let password2: String
        public let sex: String
        public let language: String
        public let recaptchaToken: String

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

        public static func initWithValidation(
            from dictionary: Entita.Dict, context: LGNCore.Context
        ) -> EventLoopFuture<UserSignupRequest> {
            let eventLoop = context.eventLoop

            if let error = self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "username",
                    "email",
                    "password1",
                    "password2",
                    "sex",
                    "language",
                    "recaptchaToken",
                ]
            ) {
                return eventLoop.makeFailedFuture(error)
            }

            let username: String? = try? (self.extract(param: "username", from: dictionary) as String)
            let email: String? = try? (self.extract(param: "email", from: dictionary) as String)
            let password1: String? = try? (self.extract(param: "password1", from: dictionary) as String)
            let password2: String? = try? (self.extract(param: "password2", from: dictionary) as String)
            let sex: String? = try? (self.extract(param: "sex", from: dictionary) as String)
            let language: String? = try? (self.extract(param: "language", from: dictionary) as String)
            let recaptchaToken: String? = try? (self.extract(param: "recaptchaToken", from: dictionary) as String)

            let validatorFutures: [String: EventLoopFuture<Void>] = [
                "username": eventLoop
                    .submit {
                        guard let _ = username else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    }.flatMap {
                        Validation.cumulative(
                            [
                                {
                                    if let error = Validation.Regexp(pattern: "^[\\p{L}\\d_\\- ]+$", message: "Username must only consist of letters, numbers and underscores").validate(username!, context.locale) {
                                        return eventLoop.makeFailedFuture(error)
                                    }
                                    return eventLoop.makeSucceededFuture()
                                }(),
                                {
                                    if let error = Validation.Length.Min(length: 3).validate(username!, context.locale) {
                                        return eventLoop.makeFailedFuture(error)
                                    }
                                    return eventLoop.makeSucceededFuture()
                                }(),
                                {
                                    if let error = Validation.Length.Max(length: 24).validate(username!, context.locale) {
                                        return eventLoop.makeFailedFuture(error)
                                    }
                                    return eventLoop.makeSucceededFuture()
                                }(),
                            ],
                            on: eventLoop
                        )
                    }
                    .flatMap {
                        guard let validator = self.validatorUsernameClosure else {
                            return eventLoop.makeSucceededFuture()
                        }
                        return Validation.CallbackWithAllowedValues<CallbackValidatorUsernameAllowedValues>(callback: validator).validate(
                            username!,
                            context.locale,
                            on: eventLoop
                        ).mapThrowing { maybeError in if let error = maybeError { throw error } }
                    },
                "email": eventLoop
                    .submit {
                        guard let _ = email else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    }.flatMap {
                        if let error = Validation.Regexp(pattern: "^.+@.+\\..+$", message: "Invalid email format").validate(email!, context.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    }
                    .flatMap {
                        guard let validator = self.validatorEmailClosure else {
                            return eventLoop.makeSucceededFuture()
                        }
                        return Validation.CallbackWithAllowedValues<CallbackValidatorEmailAllowedValues>(callback: validator).validate(
                            email!,
                            context.locale,
                            on: eventLoop
                        ).mapThrowing { maybeError in if let error = maybeError { throw error } }
                    },
                "password1": eventLoop
                    .submit {
                        guard let _ = password1 else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    }.flatMap {
                        if let error = Validation.Length.Min(length: 6, message: "Password must be at least 6 characters long").validate(password1!, context.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    }
                    .flatMap {
                        if let error = Validation.Length.Max(length: 64, message: "Password must be less than 64 characters long").validate(password1!, context.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                "password2": eventLoop
                    .submit {
                        guard let _ = password2 else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    }.flatMap {
                        if let error = Validation.Identical(right: password1!, message: "Passwords must match").validate(password2!, context.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                "sex": eventLoop
                    .submit {
                        guard let _ = sex else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    }.flatMap {
                        if let error = Validation.In(allowedValues: ["Male", "Female", "Attack helicopter"]).validate(sex!, context.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                "language": eventLoop
                    .submit {
                        guard let _ = language else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    }.flatMap {
                        if let error = Validation.In(allowedValues: ["en", "ru"]).validate(language!, context.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                "recaptchaToken": eventLoop
                    .submit {
                        guard let _ = recaptchaToken else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
            ]

            return self
                .reduce(validators: validatorFutures, context: context)
                .flatMapThrowing {
                    guard $0.count == 0 else {
                        throw LGNC.E.DecodeError($0)
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
            [
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

    final class NodeInfo: ContractEntity {
        public static let keyDictionary: [String: String] = [:]

        private static var validatorNameClosure: Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>.Callback? = nil

        public enum CallbackValidatorNameAllowedValues: String, CallbackWithAllowedValuesRepresentable, ValidatorErrorRepresentable {
            public typealias InputValue = String

            case NodeWithGivenNameAlreadyCheckedIn = "Node with given name already checked in"

            public func getErrorTuple() -> ErrorTuple {
                switch self {
                    case .NodeWithGivenNameAlreadyCheckedIn: return (code: 409, message: self.rawValue)
                }
            }
        }

        public let type: String
        public let id: String
        public let name: String
        public let port: Int

        public init(type: String, id: String, name: String, port: Int) {
            self.type = type
            self.id = id
            self.name = name
            self.port = port
        }

        public static func initWithValidation(
            from dictionary: Entita.Dict, context: LGNCore.Context
        ) -> EventLoopFuture<NodeInfo> {
            let eventLoop = context.eventLoop

            if let error = self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "type",
                    "id",
                    "name",
                    "port",
                ]
            ) {
                return eventLoop.makeFailedFuture(error)
            }

            let type: String? = try? (self.extract(param: "type", from: dictionary) as String)
            let id: String? = try? (self.extract(param: "id", from: dictionary) as String)
            let name: String? = try? (self.extract(param: "name", from: dictionary) as String)
            let port: Int? = try? (self.extract(param: "port", from: dictionary) as Int)

            let validatorFutures: [String: EventLoopFuture<Void>] = [
                "type": eventLoop
                    .submit {
                        guard let _ = type else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
                "id": eventLoop
                    .submit {
                        guard let _ = id else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
                "name": eventLoop
                    .submit {
                        guard let _ = name else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    }.flatMap {
                        guard let validator = self.validatorNameClosure else {
                            return eventLoop.makeSucceededFuture()
                        }
                        return Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>(callback: validator).validate(
                            name!,
                            context.locale,
                            on: eventLoop
                        ).mapThrowing { maybeError in if let error = maybeError { throw error } }
                    },
                "port": eventLoop
                    .submit {
                        guard let _ = port else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
            ]

            return self
                .reduce(validators: validatorFutures, context: context)
                .flatMapThrowing {
                    guard $0.count == 0 else {
                        throw LGNC.E.DecodeError($0)
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
            [
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

    final class PingRequest: ContractEntity {
        public static let keyDictionary: [String: String] = [:]

        private static var validatorNameClosure: Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>.Callback? = nil

        public enum CallbackValidatorNameAllowedValues: String, CallbackWithAllowedValuesRepresentable, ValidatorErrorRepresentable {
            public typealias InputValue = String

            case NodeWithGivenNameIsNotCheckedIn = "Node with given name is not checked in"

            public func getErrorTuple() -> ErrorTuple {
                switch self {
                    case .NodeWithGivenNameIsNotCheckedIn: return (code: 404, message: self.rawValue)
                }
            }
        }

        public let name: String
        public let entities: Int

        public init(name: String, entities: Int) {
            self.name = name
            self.entities = entities
        }

        public static func initWithValidation(
            from dictionary: Entita.Dict, context: LGNCore.Context
        ) -> EventLoopFuture<PingRequest> {
            let eventLoop = context.eventLoop

            if let error = self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "name",
                    "entities",
                ]
            ) {
                return eventLoop.makeFailedFuture(error)
            }

            let name: String? = try? (self.extract(param: "name", from: dictionary) as String)
            let entities: Int? = try? (self.extract(param: "entities", from: dictionary) as Int)

            let validatorFutures: [String: EventLoopFuture<Void>] = [
                "name": eventLoop
                    .submit {
                        guard let _ = name else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    }.flatMap {
                        guard let validator = self.validatorNameClosure else {
                            return eventLoop.makeSucceededFuture()
                        }
                        return Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>(callback: validator).validate(
                            name!,
                            context.locale,
                            on: eventLoop
                        ).mapThrowing { maybeError in if let error = maybeError { throw error } }
                    },
                "entities": eventLoop
                    .submit {
                        guard let _ = entities else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
            ]

            return self
                .reduce(validators: validatorFutures, context: context)
                .flatMapThrowing {
                    guard $0.count == 0 else {
                        throw LGNC.E.DecodeError($0)
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
            [
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

    final class PingResponse: ContractEntity {
        public static let keyDictionary: [String: String] = [:]

        public let result: String

        public init(result: String) {
            self.result = result
        }

        public static func initWithValidation(
            from dictionary: Entita.Dict, context: LGNCore.Context
        ) -> EventLoopFuture<PingResponse> {
            let eventLoop = context.eventLoop

            if let error = self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "result",
                ]
            ) {
                return eventLoop.makeFailedFuture(error)
            }

            let result: String? = try? (self.extract(param: "result", from: dictionary) as String)

            let validatorFutures: [String: EventLoopFuture<Void>] = [
                "result": eventLoop
                    .submit {
                        guard let _ = result else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
            ]

            return self
                .reduce(validators: validatorFutures, context: context)
                .flatMapThrowing {
                    guard $0.count == 0 else {
                        throw LGNC.E.DecodeError($0)
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
            [
                self.getDictionaryKey("result"): try self.encode(self.result),
            ]
        }

    }

    final class CheckinRequest: ContractEntity {
        public static let keyDictionary: [String: String] = [:]

        private static var validatorNameClosure: Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>.Callback? = nil

        public enum CallbackValidatorNameAllowedValues: String, CallbackWithAllowedValuesRepresentable, ValidatorErrorRepresentable {
            public typealias InputValue = String

            case NodeWithGivenNameAlreadyCheckedIn = "Node with given name already checked in"

            public func getErrorTuple() -> ErrorTuple {
                switch self {
                    case .NodeWithGivenNameAlreadyCheckedIn: return (code: 409, message: self.rawValue)
                }
            }
        }

        public let type: String
        public let name: String
        public let port: Int
        public let entities: Int

        public init(type: String, name: String, port: Int, entities: Int) {
            self.type = type
            self.name = name
            self.port = port
            self.entities = entities
        }

        public static func initWithValidation(
            from dictionary: Entita.Dict, context: LGNCore.Context
        ) -> EventLoopFuture<CheckinRequest> {
            let eventLoop = context.eventLoop

            if let error = self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "type",
                    "name",
                    "port",
                    "entities",
                ]
            ) {
                return eventLoop.makeFailedFuture(error)
            }

            let type: String? = try? (self.extract(param: "type", from: dictionary) as String)
            let name: String? = try? (self.extract(param: "name", from: dictionary) as String)
            let port: Int? = try? (self.extract(param: "port", from: dictionary) as Int)
            let entities: Int? = try? (self.extract(param: "entities", from: dictionary) as Int)

            let validatorFutures: [String: EventLoopFuture<Void>] = [
                "type": eventLoop
                    .submit {
                        guard let _ = type else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
                "name": eventLoop
                    .submit {
                        guard let _ = name else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    }.flatMap {
                        guard let validator = self.validatorNameClosure else {
                            return eventLoop.makeSucceededFuture()
                        }
                        return Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>(callback: validator).validate(
                            name!,
                            context.locale,
                            on: eventLoop
                        ).mapThrowing { maybeError in if let error = maybeError { throw error } }
                    },
                "port": eventLoop
                    .submit {
                        guard let _ = port else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
                "entities": eventLoop
                    .submit {
                        guard let _ = entities else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
            ]

            return self
                .reduce(validators: validatorFutures, context: context)
                .flatMapThrowing {
                    guard $0.count == 0 else {
                        throw LGNC.E.DecodeError($0)
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
            [
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

    final class CheckinResponse: ContractEntity {
        public static let keyDictionary: [String: String] = [:]

        public let result: String

        public init(result: String) {
            self.result = result
        }

        public static func initWithValidation(
            from dictionary: Entita.Dict, context: LGNCore.Context
        ) -> EventLoopFuture<CheckinResponse> {
            let eventLoop = context.eventLoop

            if let error = self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "result",
                ]
            ) {
                return eventLoop.makeFailedFuture(error)
            }

            let result: String? = try? (self.extract(param: "result", from: dictionary) as String)

            let validatorFutures: [String: EventLoopFuture<Void>] = [
                "result": eventLoop
                    .submit {
                        guard let _ = result else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
            ]

            return self
                .reduce(validators: validatorFutures, context: context)
                .flatMapThrowing {
                    guard $0.count == 0 else {
                        throw LGNC.E.DecodeError($0)
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
            [
                self.getDictionaryKey("result"): try self.encode(self.result),
            ]
        }

    }

    final class LoginRequest: ContractEntity {
        public static let keyDictionary: [String: String] = [:]

        public let email: String
        public let password: String
        public let portal: String
        public let recaptchaToken: String?

        public init(email: String, password: String, portal: String, recaptchaToken: String? = nil) {
            self.email = email
            self.password = password
            self.portal = portal
            self.recaptchaToken = recaptchaToken
        }

        public static func initWithValidation(
            from dictionary: Entita.Dict, context: LGNCore.Context
        ) -> EventLoopFuture<LoginRequest> {
            let eventLoop = context.eventLoop

            if let error = self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "email",
                    "password",
                    "portal",
                    "recaptchaToken",
                ]
            ) {
                return eventLoop.makeFailedFuture(error)
            }

            let email: String? = try? (self.extract(param: "email", from: dictionary) as String)
            let password: String? = try? (self.extract(param: "password", from: dictionary) as String)
            let portal: String? = try? (self.extract(param: "portal", from: dictionary) as String)
            let recaptchaToken: String?? = try? (self.extract(param: "recaptchaToken", from: dictionary, isOptional: true) as String?)

            let validatorFutures: [String: EventLoopFuture<Void>] = [
                "email": eventLoop
                    .submit {
                        guard let _ = email else {
                            throw Validation.Error.MissingValue(context.locale, message: "Please enter email")
                        }
                    },
                "password": eventLoop
                    .submit {
                        guard let _ = password else {
                            throw Validation.Error.MissingValue(context.locale, message: "Please enter password")
                        }
                    },
                "portal": eventLoop
                    .submit {
                        guard let _ = portal else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
                "recaptchaToken": eventLoop
                    .submit {
                        guard let recaptchaToken = recaptchaToken else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                        if recaptchaToken == nil {
                            throw Validation.Error.SkipMissingOptionalValueValidators()
                        }
                    },
            ]

            return self
                .reduce(validators: validatorFutures, context: context)
                .flatMapThrowing {
                    guard $0.count == 0 else {
                        throw LGNC.E.DecodeError($0)
                    }

                    return self.init(
                        email: email!,
                        password: password!,
                        portal: portal!,
                        recaptchaToken: recaptchaToken!
                    )
                }
        }

        public convenience init(from dictionary: Entita.Dict) throws {
            self.init(
                email: try LoginRequest.extract(param: "email", from: dictionary),
                password: try LoginRequest.extract(param: "password", from: dictionary),
                portal: try LoginRequest.extract(param: "portal", from: dictionary),
                recaptchaToken: try LoginRequest.extract(param: "recaptchaToken", from: dictionary, isOptional: true)
            )
        }

        public func getDictionary() throws -> Entita.Dict {
            [
                self.getDictionaryKey("email"): try self.encode(self.email),
                self.getDictionaryKey("password"): try self.encode(self.password),
                self.getDictionaryKey("portal"): try self.encode(self.portal),
                self.getDictionaryKey("recaptchaToken"): try self.encode(self.recaptchaToken),
            ]
        }

    }

    final class LoginResponse: ContractEntity {
        public static let keyDictionary: [String: String] = [:]

        public static let hasCookieFields: Bool = true

        public let session: LGNC.Entity.Cookie
        public let portal: LGNC.Entity.Cookie
        public let author: LGNC.Entity.Cookie
        public let IDUser: String

        public init(
            session: LGNC.Entity.Cookie,
            portal: LGNC.Entity.Cookie,
            author: LGNC.Entity.Cookie,
            IDUser: String
        ) {
            self.session = session
            self.portal = portal
            self.author = author
            self.IDUser = IDUser
        }

        public static func initWithValidation(
            from dictionary: Entita.Dict, context: LGNCore.Context
        ) -> EventLoopFuture<LoginResponse> {
            let eventLoop = context.eventLoop

            if let error = self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "session",
                    "portal",
                    "author",
                    "IDUser",
                ]
            ) {
                return eventLoop.makeFailedFuture(error)
            }

            let session: LGNC.Entity.Cookie?
            do {
                session = try self.extractCookie(param: "session", from: dictionary, context: context)
            } catch {
                return eventLoop.makeFailedFuture(error)
            }
            let portal: LGNC.Entity.Cookie?
            do {
                portal = try self.extractCookie(param: "portal", from: dictionary, context: context)
            } catch {
                return eventLoop.makeFailedFuture(error)
            }
            let author: LGNC.Entity.Cookie?
            do {
                author = try self.extractCookie(param: "author", from: dictionary, context: context)
            } catch {
                return eventLoop.makeFailedFuture(error)
            }
            let IDUser: String? = try? (self.extract(param: "IDUser", from: dictionary) as String)

            let validatorFutures: [String: EventLoopFuture<Void>] = [
                "session": eventLoop
                    .submit {
                        guard let _ = session else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
                "portal": eventLoop
                    .submit {
                        guard let _ = portal else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
                "author": eventLoop
                    .submit {
                        guard let _ = author else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
                "IDUser": eventLoop
                    .submit {
                        guard let _ = IDUser else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
            ]

            return self
                .reduce(validators: validatorFutures, context: context)
                .flatMapThrowing {
                    guard $0.count == 0 else {
                        throw LGNC.E.DecodeError($0)
                    }

                    return self.init(
                        session: session!,
                        portal: portal!,
                        author: author!,
                        IDUser: IDUser!
                    )
                }
        }

        public convenience init(from dictionary: Entita.Dict) throws {
            self.init(
                session: try LoginResponse.extract(param: "session", from: dictionary),
                portal: try LoginResponse.extract(param: "portal", from: dictionary),
                author: try LoginResponse.extract(param: "author", from: dictionary),
                IDUser: try LoginResponse.extract(param: "IDUser", from: dictionary)
            )
        }

        public func getDictionary() throws -> Entita.Dict {
            [
                self.getDictionaryKey("session"): try self.encode(self.session),
                self.getDictionaryKey("portal"): try self.encode(self.portal),
                self.getDictionaryKey("author"): try self.encode(self.author),
                self.getDictionaryKey("IDUser"): try self.encode(self.IDUser),
            ]
        }

    }

    final class CommentUserInfo: ContractEntity {
        public static let keyDictionary: [String: String] = [:]

        public let ID: String
        public let username: String
        public let accessLevel: String

        public init(ID: String, username: String, accessLevel: String) {
            self.ID = ID
            self.username = username
            self.accessLevel = accessLevel
        }

        public static func initWithValidation(
            from dictionary: Entita.Dict, context: LGNCore.Context
        ) -> EventLoopFuture<CommentUserInfo> {
            let eventLoop = context.eventLoop

            if let error = self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "ID",
                    "username",
                    "accessLevel",
                ]
            ) {
                return eventLoop.makeFailedFuture(error)
            }

            let ID: String? = try? (self.extract(param: "ID", from: dictionary) as String)
            let username: String? = try? (self.extract(param: "username", from: dictionary) as String)
            let accessLevel: String? = try? (self.extract(param: "accessLevel", from: dictionary) as String)

            let validatorFutures: [String: EventLoopFuture<Void>] = [
                "ID": eventLoop
                    .submit {
                        guard let _ = ID else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    }.flatMap {
                        if let error = Validation.UUID().validate(ID!, context.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                "username": eventLoop
                    .submit {
                        guard let _ = username else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
                "accessLevel": eventLoop
                    .submit {
                        guard let _ = accessLevel else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    }.flatMap {
                        if let error = Validation.In(allowedValues: ["User", "PowerUser", "Moderator", "Admin"]).validate(accessLevel!, context.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
            ]

            return self
                .reduce(validators: validatorFutures, context: context)
                .flatMapThrowing {
                    guard $0.count == 0 else {
                        throw LGNC.E.DecodeError($0)
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
            [
                self.getDictionaryKey("ID"): try self.encode(self.ID),
                self.getDictionaryKey("username"): try self.encode(self.username),
                self.getDictionaryKey("accessLevel"): try self.encode(self.accessLevel),
            ]
        }

    }

    final class Comment: ContractEntity {
        public static let keyDictionary: [String: String] = [:]

        public let ID: Int
        public let user: Services.Shared.CommentUserInfo
        public let IDPost: String
        public let IDReplyComment: Int?
        public let isEditable: Bool
        public let status: String
        public let body: String
        public let likes: Int
        public let dateCreated: String
        public let dateUpdated: String

        public init(
            ID: Int,
            user: Services.Shared.CommentUserInfo,
            IDPost: String,
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
            user: Services.Shared.CommentUserInfo,
            IDPost: String,
            IDReplyComment: Int? = nil,
            isEditable: Bool,
            status: String,
            body: String,
            likes likesFuture: EventLoopFuture<Int>,
            dateCreated: String,
            dateUpdated: String
        ) -> EventLoopFuture<Comment> {
            likesFuture.eventLoop.makeSucceededFuture(()).flatMap { () in
                likesFuture.map { likes in (likes) }
            }
            .map { (likes) in
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

        public static func initWithValidation(
            from dictionary: Entita.Dict, context: LGNCore.Context
        ) -> EventLoopFuture<Comment> {
            let eventLoop = context.eventLoop

            if let error = self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "ID",
                    "user",
                    "IDPost",
                    "IDReplyComment",
                    "isEditable",
                    "status",
                    "body",
                    "likes",
                    "dateCreated",
                    "dateUpdated",
                ]
            ) {
                return eventLoop.makeFailedFuture(error)
            }

            let ID: Int? = try? (self.extract(param: "ID", from: dictionary) as Int)
            let user: Services.Shared.CommentUserInfo? = try? (self.extract(param: "user", from: dictionary) as Services.Shared.CommentUserInfo)
            let IDPost: String? = try? (self.extract(param: "IDPost", from: dictionary) as String)
            let IDReplyComment: Int?? = try? (self.extract(param: "IDReplyComment", from: dictionary, isOptional: true) as Int?)
            let isEditable: Bool? = try? (self.extract(param: "isEditable", from: dictionary) as Bool)
            let status: String? = try? (self.extract(param: "status", from: dictionary) as String)
            let body: String? = try? (self.extract(param: "body", from: dictionary) as String)
            let likes: Int? = try? (self.extract(param: "likes", from: dictionary) as Int)
            let dateCreated: String? = try? (self.extract(param: "dateCreated", from: dictionary) as String)
            let dateUpdated: String? = try? (self.extract(param: "dateUpdated", from: dictionary) as String)

            let validatorFutures: [String: EventLoopFuture<Void>] = [
                "ID": eventLoop
                    .submit {
                        guard let _ = ID else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
                "user": eventLoop
                    .submit {
                        guard let _ = user else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
                "IDPost": eventLoop
                    .submit {
                        guard let _ = IDPost else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
                "IDReplyComment": eventLoop
                    .submit {
                        guard let IDReplyComment = IDReplyComment else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                        if IDReplyComment == nil {
                            throw Validation.Error.SkipMissingOptionalValueValidators()
                        }
                    },
                "isEditable": eventLoop
                    .submit {
                        guard let _ = isEditable else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
                "status": eventLoop
                    .submit {
                        guard let _ = status else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    }.flatMap {
                        if let error = Validation.In(allowedValues: ["pending", "deleted", "hidden", "published"]).validate(status!, context.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                "body": eventLoop
                    .submit {
                        guard let _ = body else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
                "likes": eventLoop
                    .submit {
                        guard let _ = likes else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
                "dateCreated": eventLoop
                    .submit {
                        guard let _ = dateCreated else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    }.flatMap {
                        if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(dateCreated!, context.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                "dateUpdated": eventLoop
                    .submit {
                        guard let _ = dateUpdated else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    }.flatMap {
                        if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(dateUpdated!, context.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
            ]

            return self
                .reduce(validators: validatorFutures, context: context)
                .flatMapThrowing {
                    guard $0.count == 0 else {
                        throw LGNC.E.DecodeError($0)
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
            [
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

    final class User: ContractEntity {
        public static let keyDictionary: [String: String] = [:]

        public let ID: String
        public let username: String
        public let email: String
        public let password: String
        public let sex: String
        public let isBanned: Bool
        public let ip: String
        public let country: String
        public let dateUnsuccessfulLogin: String
        public let dateSignup: String
        public let dateLogin: String
        public let authorName: String
        public let accessLevel: String

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

        public static func initWithValidation(
            from dictionary: Entita.Dict, context: LGNCore.Context
        ) -> EventLoopFuture<User> {
            let eventLoop = context.eventLoop

            if let error = self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "ID",
                    "username",
                    "email",
                    "password",
                    "sex",
                    "isBanned",
                    "ip",
                    "country",
                    "dateUnsuccessfulLogin",
                    "dateSignup",
                    "dateLogin",
                    "authorName",
                    "accessLevel",
                ]
            ) {
                return eventLoop.makeFailedFuture(error)
            }

            let ID: String? = try? (self.extract(param: "ID", from: dictionary) as String)
            let username: String? = try? (self.extract(param: "username", from: dictionary) as String)
            let email: String? = try? (self.extract(param: "email", from: dictionary) as String)
            let password: String? = try? (self.extract(param: "password", from: dictionary) as String)
            let sex: String? = try? (self.extract(param: "sex", from: dictionary) as String)
            let isBanned: Bool? = try? (self.extract(param: "isBanned", from: dictionary) as Bool)
            let ip: String? = try? (self.extract(param: "ip", from: dictionary) as String)
            let country: String? = try? (self.extract(param: "country", from: dictionary) as String)
            let dateUnsuccessfulLogin: String? = try? (self.extract(param: "dateUnsuccessfulLogin", from: dictionary) as String)
            let dateSignup: String? = try? (self.extract(param: "dateSignup", from: dictionary) as String)
            let dateLogin: String? = try? (self.extract(param: "dateLogin", from: dictionary) as String)
            let authorName: String? = try? (self.extract(param: "authorName", from: dictionary) as String)
            let accessLevel: String? = try? (self.extract(param: "accessLevel", from: dictionary) as String)

            let validatorFutures: [String: EventLoopFuture<Void>] = [
                "ID": eventLoop
                    .submit {
                        guard let _ = ID else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    }.flatMap {
                        if let error = Validation.UUID().validate(ID!, context.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                "username": eventLoop
                    .submit {
                        guard let _ = username else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
                "email": eventLoop
                    .submit {
                        guard let _ = email else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    }.flatMap {
                        if let error = Validation.Regexp(pattern: "^.+@.+\\..+$", message: "Invalid email format").validate(email!, context.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    }
                    .flatMap {
                        if let error = Validation.Length.Min(length: 6).validate(email!, context.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                "password": eventLoop
                    .submit {
                        guard let _ = password else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
                "sex": eventLoop
                    .submit {
                        guard let _ = sex else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    }.flatMap {
                        if let error = Validation.In(allowedValues: ["Male", "Female", "Attack helicopter"]).validate(sex!, context.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                "isBanned": eventLoop
                    .submit {
                        guard let _ = isBanned else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
                "ip": eventLoop
                    .submit {
                        guard let _ = ip else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
                "country": eventLoop
                    .submit {
                        guard let _ = country else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
                "dateUnsuccessfulLogin": eventLoop
                    .submit {
                        guard let _ = dateUnsuccessfulLogin else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    }.flatMap {
                        if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(dateUnsuccessfulLogin!, context.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                "dateSignup": eventLoop
                    .submit {
                        guard let _ = dateSignup else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    }.flatMap {
                        if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(dateSignup!, context.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                "dateLogin": eventLoop
                    .submit {
                        guard let _ = dateLogin else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    }.flatMap {
                        if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(dateLogin!, context.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
                "authorName": eventLoop
                    .submit {
                        guard let _ = authorName else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    },
                "accessLevel": eventLoop
                    .submit {
                        guard let _ = accessLevel else {
                            throw Validation.Error.MissingValue(context.locale)
                        }
                    }.flatMap {
                        if let error = Validation.In(allowedValues: ["User", "Admin"]).validate(accessLevel!, context.locale) {
                            return eventLoop.makeFailedFuture(error)
                        }
                        return eventLoop.makeSucceededFuture()
                    },
            ]

            return self
                .reduce(validators: validatorFutures, context: context)
                .flatMapThrowing {
                    guard $0.count == 0 else {
                        throw LGNC.E.DecodeError($0)
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
            [
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