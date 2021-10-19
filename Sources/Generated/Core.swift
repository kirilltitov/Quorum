import LGNCore
import Entita
import LGNS
import LGNC
import LGNP

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

        public static func initWithValidation(from dictionary: Entita.Dict) async throws -> Self {
            try self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "map",
                ]
            )

            let value_map: [String:String]? = try? (self.extract(param: "map", from: dictionary) as [String:String])

            let validatorClosures: [String: ValidationClosure] = [
                "map": {
                    guard let _ = value_map else {
                        throw Validation.Error.MissingValue()
                    }

                },
            ]

            let validationErrors = await self.reduce(closures: validatorClosures)
            guard validationErrors.isEmpty else {
                throw LGNC.E.DecodeError(validationErrors)
            }

            return self.init(
                map: value_map!
            )
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

        public static func initWithValidation(from dictionary: Entita.Dict) async throws -> Self {
            try self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "Request",
                    "Response",
                ]
            )

            let value_Request: Services.Shared.FieldMapping? = try? (self.extract(param: "Request", from: dictionary) as Services.Shared.FieldMapping)
            let value_Response: Services.Shared.FieldMapping? = try? (self.extract(param: "Response", from: dictionary) as Services.Shared.FieldMapping)

            let validatorClosures: [String: ValidationClosure] = [
                "Request": {
                    guard let _ = value_Request else {
                        throw Validation.Error.MissingValue()
                    }

                },
                "Response": {
                    guard let _ = value_Response else {
                        throw Validation.Error.MissingValue()
                    }

                },
            ]

            let validationErrors = await self.reduce(closures: validatorClosures)
            guard validationErrors.isEmpty else {
                throw LGNC.E.DecodeError(validationErrors)
            }

            return self.init(
                Request: value_Request!,
                Response: value_Response!
            )
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

        public static func initWithValidation(from dictionary: Entita.Dict) async throws -> Self {
            try self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "map",
                ]
            )

            let value_map: [String:Services.Shared.ServiceFieldMapping]? = try? (self.extract(param: "map", from: dictionary) as [String:Services.Shared.ServiceFieldMapping])

            let validatorClosures: [String: ValidationClosure] = [
                "map": {
                    guard let _ = value_map else {
                        throw Validation.Error.MissingValue()
                    }

                },
            ]

            let validationErrors = await self.reduce(closures: validatorClosures)
            guard validationErrors.isEmpty else {
                throw LGNC.E.DecodeError(validationErrors)
            }

            return self.init(
                map: value_map!
            )
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

        public static func initWithValidation(from dictionary: Entita.Dict) async throws -> Self {
            try self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "monad",
                ]
            )

            let value_monad: String? = try? (self.extract(param: "monad", from: dictionary) as String)

            let validatorClosures: [String: ValidationClosure] = [
                "monad": {
                    guard let _ = value_monad else {
                        throw Validation.Error.MissingValue()
                    }

                },
            ]

            let validationErrors = await self.reduce(closures: validatorClosures)
            guard validationErrors.isEmpty else {
                throw LGNC.E.DecodeError(validationErrors)
            }

            return self.init(
                monad: value_monad!
            )
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

        public static func initWithValidation(from dictionary: Entita.Dict) async throws -> Self {
            try self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "event",
                ]
            )

            let value_event: String? = try? (self.extract(param: "event", from: dictionary) as String)

            let validatorClosures: [String: ValidationClosure] = [
                "event": {
                    guard let _ = value_event else {
                        throw Validation.Error.MissingValue()
                    }

                },
            ]

            let validationErrors = await self.reduce(closures: validatorClosures)
            guard validationErrors.isEmpty else {
                throw LGNC.E.DecodeError(validationErrors)
            }

            return self.init(
                event: value_event!
            )
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

        public static func initWithValidation(from dictionary: Entita.Dict) async throws -> Self {
            try self.ensureNecessaryItems(
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
            )

            let value_username: String? = try? (self.extract(param: "username", from: dictionary) as String)
            let value_email: String? = try? (self.extract(param: "email", from: dictionary) as String)
            let value_password1: String? = try? (self.extract(param: "password1", from: dictionary) as String)
            let value_password2: String? = try? (self.extract(param: "password2", from: dictionary) as String)
            let value_sex: String? = try? (self.extract(param: "sex", from: dictionary) as String)
            let value_language: String? = try? (self.extract(param: "language", from: dictionary) as String)
            let value_recaptchaToken: String? = try? (self.extract(param: "recaptchaToken", from: dictionary) as String)

            let validatorClosures: [String: ValidationClosure] = [
                "username": {
                    guard let _ = value_username else {
                        throw Validation.Error.MissingValue()
                    }
                    try await Validation.cumulative([
                        {
                            try await Validation.Regexp(pattern: "^[\\p{L}\\d_\\- ]+$", message: "Username must only consist of letters, numbers and underscores").validate(value_username!)
                        },
                        {
                            try await Validation.Length.Min(length: 3).validate(value_username!)
                        },
                        {
                            try await Validation.Length.Max(length: 24).validate(value_username!)
                        },
                    ])
                    if let validator = self.validatorUsernameClosure {
                        try await Validation.CallbackWithAllowedValues<CallbackValidatorUsernameAllowedValues>(callback: validator).validate(value_username!)
                    }
                },
                "email": {
                    guard let _ = value_email else {
                        throw Validation.Error.MissingValue()
                    }
                    try await Validation.Regexp(pattern: "^.+@.+\\..+$", message: "Invalid email format").validate(value_email!)
                    if let validator = self.validatorEmailClosure {
                        try await Validation.CallbackWithAllowedValues<CallbackValidatorEmailAllowedValues>(callback: validator).validate(value_email!)
                    }
                },
                "password1": {
                    guard let _ = value_password1 else {
                        throw Validation.Error.MissingValue()
                    }
                    try await Validation.Length.Min(length: 6, message: "Password must be at least 6 characters long").validate(value_password1!)
                try await Validation.Length.Max(length: 64, message: "Password must be less than 64 characters long").validate(value_password1!)
                },
                "password2": {
                    guard let _ = value_password2 else {
                        throw Validation.Error.MissingValue()
                    }
                    try await Validation.Identical(right: value_password1!, message: "Passwords must match").validate(value_password2!)
                },
                "sex": {
                    guard let _ = value_sex else {
                        throw Validation.Error.MissingValue()
                    }
                    try await Validation.In(allowedValues: ["Male", "Female", "Attack helicopter"]).validate(value_sex!)
                },
                "language": {
                    guard let _ = value_language else {
                        throw Validation.Error.MissingValue()
                    }
                    try await Validation.In(allowedValues: ["en", "ru"]).validate(value_language!)
                },
                "recaptchaToken": {
                    guard let _ = value_recaptchaToken else {
                        throw Validation.Error.MissingValue()
                    }

                },
            ]

            let validationErrors = await self.reduce(closures: validatorClosures)
            guard validationErrors.isEmpty else {
                throw LGNC.E.DecodeError(validationErrors)
            }

            return self.init(
                username: value_username!,
                email: value_email!,
                password1: value_password1!,
                password2: value_password2!,
                sex: value_sex!,
                language: value_language!,
                recaptchaToken: value_recaptchaToken!
            )
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

        public static func initWithValidation(from dictionary: Entita.Dict) async throws -> Self {
            try self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "type",
                    "id",
                    "name",
                    "port",
                ]
            )

            let value_type: String? = try? (self.extract(param: "type", from: dictionary) as String)
            let value_id: String? = try? (self.extract(param: "id", from: dictionary) as String)
            let value_name: String? = try? (self.extract(param: "name", from: dictionary) as String)
            let value_port: Int? = try? (self.extract(param: "port", from: dictionary) as Int)

            let validatorClosures: [String: ValidationClosure] = [
                "type": {
                    guard let _ = value_type else {
                        throw Validation.Error.MissingValue()
                    }

                },
                "id": {
                    guard let _ = value_id else {
                        throw Validation.Error.MissingValue()
                    }

                },
                "name": {
                    guard let _ = value_name else {
                        throw Validation.Error.MissingValue()
                    }
                        if let validator = self.validatorNameClosure {
                        try await Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>(callback: validator).validate(value_name!)
                    }
                },
                "port": {
                    guard let _ = value_port else {
                        throw Validation.Error.MissingValue()
                    }

                },
            ]

            let validationErrors = await self.reduce(closures: validatorClosures)
            guard validationErrors.isEmpty else {
                throw LGNC.E.DecodeError(validationErrors)
            }

            return self.init(
                type: value_type!,
                id: value_id!,
                name: value_name!,
                port: value_port!
            )
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

        public static func initWithValidation(from dictionary: Entita.Dict) async throws -> Self {
            try self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "name",
                    "entities",
                ]
            )

            let value_name: String? = try? (self.extract(param: "name", from: dictionary) as String)
            let value_entities: Int? = try? (self.extract(param: "entities", from: dictionary) as Int)

            let validatorClosures: [String: ValidationClosure] = [
                "name": {
                    guard let _ = value_name else {
                        throw Validation.Error.MissingValue()
                    }
                        if let validator = self.validatorNameClosure {
                        try await Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>(callback: validator).validate(value_name!)
                    }
                },
                "entities": {
                    guard let _ = value_entities else {
                        throw Validation.Error.MissingValue()
                    }

                },
            ]

            let validationErrors = await self.reduce(closures: validatorClosures)
            guard validationErrors.isEmpty else {
                throw LGNC.E.DecodeError(validationErrors)
            }

            return self.init(
                name: value_name!,
                entities: value_entities!
            )
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

        public static func initWithValidation(from dictionary: Entita.Dict) async throws -> Self {
            try self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "result",
                ]
            )

            let value_result: String? = try? (self.extract(param: "result", from: dictionary) as String)

            let validatorClosures: [String: ValidationClosure] = [
                "result": {
                    guard let _ = value_result else {
                        throw Validation.Error.MissingValue()
                    }

                },
            ]

            let validationErrors = await self.reduce(closures: validatorClosures)
            guard validationErrors.isEmpty else {
                throw LGNC.E.DecodeError(validationErrors)
            }

            return self.init(
                result: value_result!
            )
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

        public static func initWithValidation(from dictionary: Entita.Dict) async throws -> Self {
            try self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "type",
                    "name",
                    "port",
                    "entities",
                ]
            )

            let value_type: String? = try? (self.extract(param: "type", from: dictionary) as String)
            let value_name: String? = try? (self.extract(param: "name", from: dictionary) as String)
            let value_port: Int? = try? (self.extract(param: "port", from: dictionary) as Int)
            let value_entities: Int? = try? (self.extract(param: "entities", from: dictionary) as Int)

            let validatorClosures: [String: ValidationClosure] = [
                "type": {
                    guard let _ = value_type else {
                        throw Validation.Error.MissingValue()
                    }

                },
                "name": {
                    guard let _ = value_name else {
                        throw Validation.Error.MissingValue()
                    }
                        if let validator = self.validatorNameClosure {
                        try await Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>(callback: validator).validate(value_name!)
                    }
                },
                "port": {
                    guard let _ = value_port else {
                        throw Validation.Error.MissingValue()
                    }

                },
                "entities": {
                    guard let _ = value_entities else {
                        throw Validation.Error.MissingValue()
                    }

                },
            ]

            let validationErrors = await self.reduce(closures: validatorClosures)
            guard validationErrors.isEmpty else {
                throw LGNC.E.DecodeError(validationErrors)
            }

            return self.init(
                type: value_type!,
                name: value_name!,
                port: value_port!,
                entities: value_entities!
            )
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

        public static func initWithValidation(from dictionary: Entita.Dict) async throws -> Self {
            try self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "result",
                ]
            )

            let value_result: String? = try? (self.extract(param: "result", from: dictionary) as String)

            let validatorClosures: [String: ValidationClosure] = [
                "result": {
                    guard let _ = value_result else {
                        throw Validation.Error.MissingValue()
                    }

                },
            ]

            let validationErrors = await self.reduce(closures: validatorClosures)
            guard validationErrors.isEmpty else {
                throw LGNC.E.DecodeError(validationErrors)
            }

            return self.init(
                result: value_result!
            )
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

        public static func initWithValidation(from dictionary: Entita.Dict) async throws -> Self {
            try self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "email",
                    "password",
                    "portal",
                    "recaptchaToken",
                ]
            )

            let value_email: String? = try? (self.extract(param: "email", from: dictionary) as String)
            let value_password: String? = try? (self.extract(param: "password", from: dictionary) as String)
            let value_portal: String? = try? (self.extract(param: "portal", from: dictionary) as String)
            let value_recaptchaToken: String?? = try? (self.extract(param: "recaptchaToken", from: dictionary, isOptional: true) as String?)

            let validatorClosures: [String: ValidationClosure] = [
                "email": {
                    guard let _ = value_email else {
                        throw Validation.Error.MissingValue(message: "Please enter email")
                    }

                },
                "password": {
                    guard let _ = value_password else {
                        throw Validation.Error.MissingValue(message: "Please enter password")
                    }

                },
                "portal": {
                    guard let _ = value_portal else {
                        throw Validation.Error.MissingValue()
                    }

                },
                "recaptchaToken": {
                    guard let value = value_recaptchaToken else {
                        throw Validation.Error.MissingValue()
                    }
                    if value == nil {
                        throw Validation.Error.SkipMissingOptionalValueValidators()
                    }

                },
            ]

            let validationErrors = await self.reduce(closures: validatorClosures)
            guard validationErrors.isEmpty else {
                throw LGNC.E.DecodeError(validationErrors)
            }

            return self.init(
                email: value_email!,
                password: value_password!,
                portal: value_portal!,
                recaptchaToken: value_recaptchaToken!
            )
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

        public static func initWithValidation(from dictionary: Entita.Dict) async throws -> Self {
            try self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "session",
                    "portal",
                    "author",
                    "IDUser",
                ]
            )

            let value_session: LGNC.Entity.Cookie? = try await self.extractCookie(param: "session", from: dictionary)
            let value_portal: LGNC.Entity.Cookie? = try await self.extractCookie(param: "portal", from: dictionary)
            let value_author: LGNC.Entity.Cookie? = try await self.extractCookie(param: "author", from: dictionary)
            let value_IDUser: String? = try? (self.extract(param: "IDUser", from: dictionary) as String)

            let validatorClosures: [String: ValidationClosure] = [
                "session": {
                    guard let _ = value_session else {
                        throw Validation.Error.MissingValue()
                    }

                },
                "portal": {
                    guard let _ = value_portal else {
                        throw Validation.Error.MissingValue()
                    }

                },
                "author": {
                    guard let _ = value_author else {
                        throw Validation.Error.MissingValue()
                    }

                },
                "IDUser": {
                    guard let _ = value_IDUser else {
                        throw Validation.Error.MissingValue()
                    }

                },
            ]

            let validationErrors = await self.reduce(closures: validatorClosures)
            guard validationErrors.isEmpty else {
                throw LGNC.E.DecodeError(validationErrors)
            }

            return self.init(
                session: value_session!,
                portal: value_portal!,
                author: value_author!,
                IDUser: value_IDUser!
            )
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

        public static func initWithValidation(from dictionary: Entita.Dict) async throws -> Self {
            try self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "ID",
                    "username",
                    "accessLevel",
                ]
            )

            let value_ID: String? = try? (self.extract(param: "ID", from: dictionary) as String)
            let value_username: String? = try? (self.extract(param: "username", from: dictionary) as String)
            let value_accessLevel: String? = try? (self.extract(param: "accessLevel", from: dictionary) as String)

            let validatorClosures: [String: ValidationClosure] = [
                "ID": {
                    guard let _ = value_ID else {
                        throw Validation.Error.MissingValue()
                    }
                    try await Validation.UUID().validate(value_ID!)
                },
                "username": {
                    guard let _ = value_username else {
                        throw Validation.Error.MissingValue()
                    }

                },
                "accessLevel": {
                    guard let _ = value_accessLevel else {
                        throw Validation.Error.MissingValue()
                    }
                    try await Validation.In(allowedValues: ["User", "PowerUser", "Moderator", "Admin"]).validate(value_accessLevel!)
                },
            ]

            let validationErrors = await self.reduce(closures: validatorClosures)
            guard validationErrors.isEmpty else {
                throw LGNC.E.DecodeError(validationErrors)
            }

            return self.init(
                ID: value_ID!,
                username: value_username!,
                accessLevel: value_accessLevel!
            )
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

    final class ChatMessage: ContractEntity {
        public static let keyDictionary: [String: String] = [:]

        public let ID: String
        public let Sender: String
        public let Date: String
        public let Body: String

        public init(ID: String, Sender: String, Date: String, Body: String) {
            self.ID = ID
            self.Sender = Sender
            self.Date = Date
            self.Body = Body
        }

        public static func initWithValidation(from dictionary: Entita.Dict) async throws -> Self {
            try self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "ID",
                    "Sender",
                    "Date",
                    "Body",
                ]
            )

            let value_ID: String? = try? (self.extract(param: "ID", from: dictionary) as String)
            let value_Sender: String? = try? (self.extract(param: "Sender", from: dictionary) as String)
            let value_Date: String? = try? (self.extract(param: "Date", from: dictionary) as String)
            let value_Body: String? = try? (self.extract(param: "Body", from: dictionary) as String)

            let validatorClosures: [String: ValidationClosure] = [
                "ID": {
                    guard let _ = value_ID else {
                        throw Validation.Error.MissingValue()
                    }
                    try await Validation.UUID().validate(value_ID!)
                },
                "Sender": {
                    guard let _ = value_Sender else {
                        throw Validation.Error.MissingValue()
                    }
                    try await Validation.UUID().validate(value_Sender!)
                },
                "Date": {
                    guard let _ = value_Date else {
                        throw Validation.Error.MissingValue()
                    }

                },
                "Body": {
                    guard let _ = value_Body else {
                        throw Validation.Error.MissingValue()
                    }

                },
            ]

            let validationErrors = await self.reduce(closures: validatorClosures)
            guard validationErrors.isEmpty else {
                throw LGNC.E.DecodeError(validationErrors)
            }

            return self.init(
                ID: value_ID!,
                Sender: value_Sender!,
                Date: value_Date!,
                Body: value_Body!
            )
        }

        public convenience init(from dictionary: Entita.Dict) throws {
            self.init(
                ID: try ChatMessage.extract(param: "ID", from: dictionary),
                Sender: try ChatMessage.extract(param: "Sender", from: dictionary),
                Date: try ChatMessage.extract(param: "Date", from: dictionary),
                Body: try ChatMessage.extract(param: "Body", from: dictionary)
            )
        }

        public func getDictionary() throws -> Entita.Dict {
            [
                self.getDictionaryKey("ID"): try self.encode(self.ID),
                self.getDictionaryKey("Sender"): try self.encode(self.Sender),
                self.getDictionaryKey("Date"): try self.encode(self.Date),
                self.getDictionaryKey("Body"): try self.encode(self.Body),
            ]
        }

    }

    final class ChatUser: ContractEntity {
        public static let keyDictionary: [String: String] = [:]

        public let ID: String
        public let username: String
        public let accessLevel: String

        public init(ID: String, username: String, accessLevel: String) {
            self.ID = ID
            self.username = username
            self.accessLevel = accessLevel
        }

        public static func initWithValidation(from dictionary: Entita.Dict) async throws -> Self {
            try self.ensureNecessaryItems(
                in: dictionary,
                necessaryItems: [
                    "ID",
                    "username",
                    "accessLevel",
                ]
            )

            let value_ID: String? = try? (self.extract(param: "ID", from: dictionary) as String)
            let value_username: String? = try? (self.extract(param: "username", from: dictionary) as String)
            let value_accessLevel: String? = try? (self.extract(param: "accessLevel", from: dictionary) as String)

            let validatorClosures: [String: ValidationClosure] = [
                "ID": {
                    guard let _ = value_ID else {
                        throw Validation.Error.MissingValue()
                    }

                },
                "username": {
                    guard let _ = value_username else {
                        throw Validation.Error.MissingValue()
                    }

                },
                "accessLevel": {
                    guard let _ = value_accessLevel else {
                        throw Validation.Error.MissingValue()
                    }

                },
            ]

            let validationErrors = await self.reduce(closures: validatorClosures)
            guard validationErrors.isEmpty else {
                throw LGNC.E.DecodeError(validationErrors)
            }

            return self.init(
                ID: value_ID!,
                username: value_username!,
                accessLevel: value_accessLevel!
            )
        }

        public convenience init(from dictionary: Entita.Dict) throws {
            self.init(
                ID: try ChatUser.extract(param: "ID", from: dictionary),
                username: try ChatUser.extract(param: "username", from: dictionary),
                accessLevel: try ChatUser.extract(param: "accessLevel", from: dictionary)
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

        public static func initWithValidation(from dictionary: Entita.Dict) async throws -> Self {
            try self.ensureNecessaryItems(
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
            )

            let value_ID: Int? = try? (self.extract(param: "ID", from: dictionary) as Int)
            let value_user: Services.Shared.CommentUserInfo? = try? (self.extract(param: "user", from: dictionary) as Services.Shared.CommentUserInfo)
            let value_IDPost: String? = try? (self.extract(param: "IDPost", from: dictionary) as String)
            let value_IDReplyComment: Int?? = try? (self.extract(param: "IDReplyComment", from: dictionary, isOptional: true) as Int?)
            let value_isEditable: Bool? = try? (self.extract(param: "isEditable", from: dictionary) as Bool)
            let value_status: String? = try? (self.extract(param: "status", from: dictionary) as String)
            let value_body: String? = try? (self.extract(param: "body", from: dictionary) as String)
            let value_likes: Int? = try? (self.extract(param: "likes", from: dictionary) as Int)
            let value_dateCreated: String? = try? (self.extract(param: "dateCreated", from: dictionary) as String)
            let value_dateUpdated: String? = try? (self.extract(param: "dateUpdated", from: dictionary) as String)

            let validatorClosures: [String: ValidationClosure] = [
                "ID": {
                    guard let _ = value_ID else {
                        throw Validation.Error.MissingValue()
                    }

                },
                "user": {
                    guard let _ = value_user else {
                        throw Validation.Error.MissingValue()
                    }

                },
                "IDPost": {
                    guard let _ = value_IDPost else {
                        throw Validation.Error.MissingValue()
                    }

                },
                "IDReplyComment": {
                    guard let value = value_IDReplyComment else {
                        throw Validation.Error.MissingValue()
                    }
                    if value == nil {
                        throw Validation.Error.SkipMissingOptionalValueValidators()
                    }

                },
                "isEditable": {
                    guard let _ = value_isEditable else {
                        throw Validation.Error.MissingValue()
                    }

                },
                "status": {
                    guard let _ = value_status else {
                        throw Validation.Error.MissingValue()
                    }
                    try await Validation.In(allowedValues: ["pending", "deleted", "hidden", "published"]).validate(value_status!)
                },
                "body": {
                    guard let _ = value_body else {
                        throw Validation.Error.MissingValue()
                    }

                },
                "likes": {
                    guard let _ = value_likes else {
                        throw Validation.Error.MissingValue()
                    }

                },
                "dateCreated": {
                    guard let _ = value_dateCreated else {
                        throw Validation.Error.MissingValue()
                    }
                    try await Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(value_dateCreated!)
                },
                "dateUpdated": {
                    guard let _ = value_dateUpdated else {
                        throw Validation.Error.MissingValue()
                    }
                    try await Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(value_dateUpdated!)
                },
            ]

            let validationErrors = await self.reduce(closures: validatorClosures)
            guard validationErrors.isEmpty else {
                throw LGNC.E.DecodeError(validationErrors)
            }

            return self.init(
                ID: value_ID!,
                user: value_user!,
                IDPost: value_IDPost!,
                IDReplyComment: value_IDReplyComment!,
                isEditable: value_isEditable!,
                status: value_status!,
                body: value_body!,
                likes: value_likes!,
                dateCreated: value_dateCreated!,
                dateUpdated: value_dateUpdated!
            )
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

        public static func initWithValidation(from dictionary: Entita.Dict) async throws -> Self {
            try self.ensureNecessaryItems(
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
            )

            let value_ID: String? = try? (self.extract(param: "ID", from: dictionary) as String)
            let value_username: String? = try? (self.extract(param: "username", from: dictionary) as String)
            let value_email: String? = try? (self.extract(param: "email", from: dictionary) as String)
            let value_password: String? = try? (self.extract(param: "password", from: dictionary) as String)
            let value_sex: String? = try? (self.extract(param: "sex", from: dictionary) as String)
            let value_isBanned: Bool? = try? (self.extract(param: "isBanned", from: dictionary) as Bool)
            let value_ip: String? = try? (self.extract(param: "ip", from: dictionary) as String)
            let value_country: String? = try? (self.extract(param: "country", from: dictionary) as String)
            let value_dateUnsuccessfulLogin: String? = try? (self.extract(param: "dateUnsuccessfulLogin", from: dictionary) as String)
            let value_dateSignup: String? = try? (self.extract(param: "dateSignup", from: dictionary) as String)
            let value_dateLogin: String? = try? (self.extract(param: "dateLogin", from: dictionary) as String)
            let value_authorName: String? = try? (self.extract(param: "authorName", from: dictionary) as String)
            let value_accessLevel: String? = try? (self.extract(param: "accessLevel", from: dictionary) as String)

            let validatorClosures: [String: ValidationClosure] = [
                "ID": {
                    guard let _ = value_ID else {
                        throw Validation.Error.MissingValue()
                    }
                    try await Validation.UUID().validate(value_ID!)
                },
                "username": {
                    guard let _ = value_username else {
                        throw Validation.Error.MissingValue()
                    }

                },
                "email": {
                    guard let _ = value_email else {
                        throw Validation.Error.MissingValue()
                    }
                    try await Validation.Regexp(pattern: "^.+@.+\\..+$", message: "Invalid email format").validate(value_email!)
                try await Validation.Length.Min(length: 6).validate(value_email!)
                },
                "password": {
                    guard let _ = value_password else {
                        throw Validation.Error.MissingValue()
                    }

                },
                "sex": {
                    guard let _ = value_sex else {
                        throw Validation.Error.MissingValue()
                    }
                    try await Validation.In(allowedValues: ["Male", "Female", "Attack helicopter"]).validate(value_sex!)
                },
                "isBanned": {
                    guard let _ = value_isBanned else {
                        throw Validation.Error.MissingValue()
                    }

                },
                "ip": {
                    guard let _ = value_ip else {
                        throw Validation.Error.MissingValue()
                    }

                },
                "country": {
                    guard let _ = value_country else {
                        throw Validation.Error.MissingValue()
                    }

                },
                "dateUnsuccessfulLogin": {
                    guard let _ = value_dateUnsuccessfulLogin else {
                        throw Validation.Error.MissingValue()
                    }
                    try await Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(value_dateUnsuccessfulLogin!)
                },
                "dateSignup": {
                    guard let _ = value_dateSignup else {
                        throw Validation.Error.MissingValue()
                    }
                    try await Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(value_dateSignup!)
                },
                "dateLogin": {
                    guard let _ = value_dateLogin else {
                        throw Validation.Error.MissingValue()
                    }
                    try await Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(value_dateLogin!)
                },
                "authorName": {
                    guard let _ = value_authorName else {
                        throw Validation.Error.MissingValue()
                    }

                },
                "accessLevel": {
                    guard let _ = value_accessLevel else {
                        throw Validation.Error.MissingValue()
                    }
                    try await Validation.In(allowedValues: ["User", "Admin"]).validate(value_accessLevel!)
                },
            ]

            let validationErrors = await self.reduce(closures: validatorClosures)
            guard validationErrors.isEmpty else {
                throw LGNC.E.DecodeError(validationErrors)
            }

            return self.init(
                ID: value_ID!,
                username: value_username!,
                email: value_email!,
                password: value_password!,
                sex: value_sex!,
                isBanned: value_isBanned!,
                ip: value_ip!,
                country: value_country!,
                dateUnsuccessfulLogin: value_dateUnsuccessfulLogin!,
                dateSignup: value_dateSignup!,
                dateLogin: value_dateLogin!,
                authorName: value_authorName!,
                accessLevel: value_accessLevel!
            )
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