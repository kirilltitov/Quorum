import Entita
import LGNC
import LGNP
import LGNS

public typealias RequestInfo = LGNS.RequestInfo

public struct Services {
    public typealias ContentType = LGNP.Message.ContentType

    public enum ServiceVisibility {
        case Public, Private
    }

    public static let registry: [String: (port: Int, contracts: [String: ServiceVisibility])] = [
        "Quorum": (
            port: Services.Quorum.port,
            contracts: [
                "Create": .Public,
            ]
        ),
        "Author": (
            port: Services.Author.port,
            contracts: [
                "Checkin": .Private,
                "Ping": .Private,
                "Signup": .Public,
                "Login": .Public,
                "InternalSignup": .Private,
                "InternalLogin": .Private,
                "Authenticate": .Public,
            ]
        ),
    ]

    public enum _Protocol {
        case LGNP, LGNPS, HTTP, HTTPS
    }

    public struct Shared {
        public final class FieldMapping: ContractEntity {
            public static let keyDictionary: [String: String] = [
                :
            ]

            public let map: [String: String]

            public required init(
                map: [String: String] = [String: String]()
            ) {
                self.map = map
            }

            public static func initWithValidation(from dictionary: Entita.Dict) throws -> FieldMapping {
                var errors: [String: [ValidatorError]] = [
                    "map": [],
                ]

                var _map: [String: String] = [String: String]()
                do {
                    _map = try FieldMapping.extract(param: "map", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["map"]?.append(Validation.Error.MissingValue())
                }

                let filteredErrors = errors.filter({ _, value in value.count > 0 })
                guard filteredErrors.count == 0 else {
                    throw LGNC.E.DecodeError(filteredErrors)
                }

                let instance = self.init(
                    map: _map
                )

                return instance
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

            public required init(
                Request: FieldMapping,
                Response: FieldMapping
            ) {
                self.Request = Request
                self.Response = Response
            }

            public static func initWithValidation(from dictionary: Entita.Dict) throws -> ServiceFieldMapping {
                var errors: [String: [ValidatorError]] = [
                    "Request": [],
                    "Response": [],
                ]

                var _Request: FieldMapping = FieldMapping()
                do {
                    _Request = try ServiceFieldMapping.extract(param: "Request", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["Request"]?.append(Validation.Error.MissingValue())
                }

                var _Response: FieldMapping = FieldMapping()
                do {
                    _Response = try ServiceFieldMapping.extract(param: "Response", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["Response"]?.append(Validation.Error.MissingValue())
                }

                let filteredErrors = errors.filter({ _, value in value.count > 0 })
                guard filteredErrors.count == 0 else {
                    throw LGNC.E.DecodeError(filteredErrors)
                }

                let instance = self.init(
                    Request: _Request,
                    Response: _Response
                )

                return instance
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

            public required init(
                map: [String: ServiceFieldMapping]
            ) {
                self.map = map
            }

            public static func initWithValidation(from dictionary: Entita.Dict) throws -> ServiceFieldMappings {
                var errors: [String: [ValidatorError]] = [
                    "map": [],
                ]

                var _map: [String: ServiceFieldMapping] = [String: ServiceFieldMapping]()
                do {
                    _map = try ServiceFieldMappings.extract(param: "map", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["map"]?.append(Validation.Error.MissingValue())
                }

                let filteredErrors = errors.filter({ _, value in value.count > 0 })
                guard filteredErrors.count == 0 else {
                    throw LGNC.E.DecodeError(filteredErrors)
                }

                let instance = self.init(
                    map: _map
                )

                return instance
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

            public required init(
                monad: String
            ) {
                self.monad = monad
            }

            public static func initWithValidation(from dictionary: Entita.Dict) throws -> CharacterInfo {
                var errors: [String: [ValidatorError]] = [
                    "monad": [],
                ]

                var _monad: String = String()
                do {
                    _monad = try CharacterInfo.extract(param: "monad", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["monad"]?.append(Validation.Error.MissingValue())
                }

                let filteredErrors = errors.filter({ _, value in value.count > 0 })
                guard filteredErrors.count == 0 else {
                    throw LGNC.E.DecodeError(filteredErrors)
                }

                let instance = self.init(
                    monad: _monad
                )

                return instance
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
            public enum CallbackValidatorEmailAllowedValues: String, ValidatorErrorRepresentable {
                case UserWithGivenEmailAlreadyExists = "User with given email already exists"

                public func getErrorTuple() -> (message: String, code: Int) {
                    switch self {
                    case .UserWithGivenEmailAlreadyExists:
                        return (message: self.rawValue, code: 10001)
                    }
                }
            }

            public static let keyDictionary: [String: String] = [
                "email": "b",
                "password1": "c",
                "password2": "d",
                "sex": "e",
            ]

            public let email: String
            public let password1: String
            public let password2: String
            public let sex: String

            private static var validatorEmailClosure: Validation.CallbackWithAllowedValues<CallbackValidatorEmailAllowedValues>.Callback?

            public required init(
                email: String,
                password1: String,
                password2: String,
                sex: String
            ) {
                self.email = email
                self.password1 = password1
                self.password2 = password2
                self.sex = sex
            }

            public static func initWithValidation(from dictionary: Entita.Dict) throws -> UserSignupRequest {
                var errors: [String: [ValidatorError]] = [
                    "email": [],
                    "password1": [],
                    "password2": [],
                    "sex": [],
                ]

                var _email: String = String()
                do {
                    _email = try UserSignupRequest.extract(param: "email", from: dictionary)

                    if let error = Validation.Regexp(pattern: "^.+@.+\\..+$", message: "Invalid email format").validate(input: _email) {
                        errors["email"]?.append(error)
                    }

                    if let validatorEmailClosure = self.validatorEmailClosure {
                        if let error = Validation.CallbackWithAllowedValues<CallbackValidatorEmailAllowedValues>(callback: validatorEmailClosure).validate(input: _email) {
                            errors["email"]?.append(error)
                        }
                    }
                } catch Entita.E.ExtractError {
                    errors["email"]?.append(Validation.Error.MissingValue())
                }

                var _password1: String = String()
                do {
                    _password1 = try UserSignupRequest.extract(param: "password1", from: dictionary)

                    if let error = Validation.Length.Min(length: 6).validate(input: _password1) {
                        errors["password1"]?.append(error)
                    }

                    if let error = Validation.Length.Max(length: 64, message: "Password must be less than 64 characters long").validate(input: _password1) {
                        errors["password1"]?.append(error)
                    }
                } catch Entita.E.ExtractError {
                    errors["password1"]?.append(Validation.Error.MissingValue())
                }

                var _password2: String = String()
                do {
                    _password2 = try UserSignupRequest.extract(param: "password2", from: dictionary)

                    if let error = Validation.Identical(right: _password1, message: "Passwords must match").validate(input: _password2) {
                        errors["password2"]?.append(error)
                    }
                } catch Entita.E.ExtractError {
                    errors["password2"]?.append(Validation.Error.MissingValue())
                }

                var _sex: String = String()
                do {
                    _sex = try UserSignupRequest.extract(param: "sex", from: dictionary)

                    if let error = Validation.In(allowedValues: ["Male", "Female", "Attack helicopter"]).validate(input: _sex) {
                        errors["sex"]?.append(error)
                    }
                } catch Entita.E.ExtractError {
                    errors["sex"]?.append(Validation.Error.MissingValue())
                }

                let filteredErrors = errors.filter({ _, value in value.count > 0 })
                guard filteredErrors.count == 0 else {
                    throw LGNC.E.DecodeError(filteredErrors)
                }

                let instance = self.init(
                    email: _email,
                    password1: _password1,
                    password2: _password2,
                    sex: _sex
                )

                return instance
            }

            public convenience init(from dictionary: Entita.Dict) throws {
                self.init(
                    email: try UserSignupRequest.extract(param: "email", from: dictionary),
                    password1: try UserSignupRequest.extract(param: "password1", from: dictionary),
                    password2: try UserSignupRequest.extract(param: "password2", from: dictionary),
                    sex: try UserSignupRequest.extract(param: "sex", from: dictionary)
                )
            }

            public func getDictionary() throws -> Entita.Dict {
                return [
                    self.getDictionaryKey("email"): try self.encode(self.email),
                    self.getDictionaryKey("password1"): try self.encode(self.password1),
                    self.getDictionaryKey("password2"): try self.encode(self.password2),
                    self.getDictionaryKey("sex"): try self.encode(self.sex),
                ]
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
                "email": "c",
                "sex": "d",
                "ip": "e",
                "country": "f",
                "dateSignup": "g",
                "dateLogin": "h",
                "currentCharacter": "i",
                "authorName": "j",
                "characters": "k",
                "token": "l",
            ]

            public let ID: String
            public let email: String
            public let sex: String
            public let ip: String
            public let country: String
            public let dateSignup: String
            public let dateLogin: String
            public let currentCharacter: String?
            public let authorName: String
            public let characters: [String: CharacterInfo]
            public let token: String

            public required init(
                ID: String,
                email: String,
                sex: String,
                ip: String,
                country: String,
                dateSignup: String,
                dateLogin: String,
                currentCharacter: String? = nil,
                authorName: String,
                characters: [String: CharacterInfo] = [String: CharacterInfo](),
                token: String
            ) {
                self.ID = ID
                self.email = email
                self.sex = sex
                self.ip = ip
                self.country = country
                self.dateSignup = dateSignup
                self.dateLogin = dateLogin
                self.currentCharacter = currentCharacter
                self.authorName = authorName
                self.characters = characters
                self.token = token
            }

            public static func initWithValidation(from dictionary: Entita.Dict) throws -> UserSignupResponse {
                var errors: [String: [ValidatorError]] = [
                    "ID": [],
                    "email": [],
                    "sex": [],
                    "ip": [],
                    "country": [],
                    "dateSignup": [],
                    "dateLogin": [],
                    "currentCharacter": [],
                    "authorName": [],
                    "characters": [],
                    "token": [],
                ]

                var _ID: String = String()
                do {
                    _ID = try UserSignupResponse.extract(param: "ID", from: dictionary)

                    if let error = Validation.UUID().validate(input: _ID) {
                        errors["ID"]?.append(error)
                    }
                } catch Entita.E.ExtractError {
                    errors["ID"]?.append(Validation.Error.MissingValue())
                }

                var _email: String = String()
                do {
                    _email = try UserSignupResponse.extract(param: "email", from: dictionary)

                    if let error = Validation.Regexp(pattern: "^.+@.+\\..+$", message: "Invalid email format").validate(input: _email) {
                        errors["email"]?.append(error)
                    }

                    if let error = Validation.Length.Min(length: 6).validate(input: _email) {
                        errors["email"]?.append(error)
                    }
                } catch Entita.E.ExtractError {
                    errors["email"]?.append(Validation.Error.MissingValue())
                }

                var _sex: String = String()
                do {
                    _sex = try UserSignupResponse.extract(param: "sex", from: dictionary)

                    if let error = Validation.In(allowedValues: ["Male", "Female", "Attack helicopter"]).validate(input: _sex) {
                        errors["sex"]?.append(error)
                    }
                } catch Entita.E.ExtractError {
                    errors["sex"]?.append(Validation.Error.MissingValue())
                }

                var _ip: String = String()
                do {
                    _ip = try UserSignupResponse.extract(param: "ip", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["ip"]?.append(Validation.Error.MissingValue())
                }

                var _country: String = String()
                do {
                    _country = try UserSignupResponse.extract(param: "country", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["country"]?.append(Validation.Error.MissingValue())
                }

                var _dateSignup: String = String()
                do {
                    _dateSignup = try UserSignupResponse.extract(param: "dateSignup", from: dictionary)

                    if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(input: _dateSignup) {
                        errors["dateSignup"]?.append(error)
                    }
                } catch Entita.E.ExtractError {
                    errors["dateSignup"]?.append(Validation.Error.MissingValue())
                }

                var _dateLogin: String = String()
                do {
                    _dateLogin = try UserSignupResponse.extract(param: "dateLogin", from: dictionary)

                    if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(input: _dateLogin) {
                        errors["dateLogin"]?.append(error)
                    }
                } catch Entita.E.ExtractError {
                    errors["dateLogin"]?.append(Validation.Error.MissingValue())
                }

                var _currentCharacter: String?
                do {
                    _currentCharacter = try UserSignupResponse.extract(param: "currentCharacter", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["currentCharacter"]?.append(Validation.Error.MissingValue())
                }

                var _authorName: String = String()
                do {
                    _authorName = try UserSignupResponse.extract(param: "authorName", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["authorName"]?.append(Validation.Error.MissingValue())
                }

                var _characters: [String: CharacterInfo] = [String: CharacterInfo]()
                do {
                    _characters = try UserSignupResponse.extract(param: "characters", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["characters"]?.append(Validation.Error.MissingValue())
                }

                var _token: String = String()
                do {
                    _token = try UserSignupResponse.extract(param: "token", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["token"]?.append(Validation.Error.MissingValue())
                }

                let filteredErrors = errors.filter({ _, value in value.count > 0 })
                guard filteredErrors.count == 0 else {
                    throw LGNC.E.DecodeError(filteredErrors)
                }

                let instance = self.init(
                    ID: _ID,
                    email: _email,
                    sex: _sex,
                    ip: _ip,
                    country: _country,
                    dateSignup: _dateSignup,
                    dateLogin: _dateLogin,
                    currentCharacter: _currentCharacter,
                    authorName: _authorName,
                    characters: _characters,
                    token: _token
                )

                return instance
            }

            public convenience init(from dictionary: Entita.Dict) throws {
                self.init(
                    ID: try UserSignupResponse.extract(param: "ID", from: dictionary),
                    email: try UserSignupResponse.extract(param: "email", from: dictionary),
                    sex: try UserSignupResponse.extract(param: "sex", from: dictionary),
                    ip: try UserSignupResponse.extract(param: "ip", from: dictionary),
                    country: try UserSignupResponse.extract(param: "country", from: dictionary),
                    dateSignup: try UserSignupResponse.extract(param: "dateSignup", from: dictionary),
                    dateLogin: try UserSignupResponse.extract(param: "dateLogin", from: dictionary),
                    currentCharacter: try UserSignupResponse.extract(param: "currentCharacter", from: dictionary, isOptional: true),
                    authorName: try UserSignupResponse.extract(param: "authorName", from: dictionary),
                    characters: try UserSignupResponse.extract(param: "characters", from: dictionary),
                    token: try UserSignupResponse.extract(param: "token", from: dictionary)
                )
            }

            public func getDictionary() throws -> Entita.Dict {
                return [
                    self.getDictionaryKey("ID"): try self.encode(self.ID),
                    self.getDictionaryKey("email"): try self.encode(self.email),
                    self.getDictionaryKey("sex"): try self.encode(self.sex),
                    self.getDictionaryKey("ip"): try self.encode(self.ip),
                    self.getDictionaryKey("country"): try self.encode(self.country),
                    self.getDictionaryKey("dateSignup"): try self.encode(self.dateSignup),
                    self.getDictionaryKey("dateLogin"): try self.encode(self.dateLogin),
                    self.getDictionaryKey("currentCharacter"): try self.encode(self.currentCharacter),
                    self.getDictionaryKey("authorName"): try self.encode(self.authorName),
                    self.getDictionaryKey("characters"): try self.encode(self.characters),
                    self.getDictionaryKey("token"): try self.encode(self.token),
                ]
            }
        }

        public final class NodeInfo: ContractEntity {
            public enum CallbackValidatorNameAllowedValues: String, ValidatorErrorRepresentable {
                case NodeWithGivenNameAlreadyCheckedIn = "Node with given name already checked in"

                public func getErrorTuple() -> (message: String, code: Int) {
                    switch self {
                    case .NodeWithGivenNameAlreadyCheckedIn:
                        return (message: self.rawValue, code: 409)
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

            public required init(
                type: String,
                name: String,
                port: Int
            ) {
                self.type = type
                self.name = name
                self.port = port
            }

            public static func initWithValidation(from dictionary: Entita.Dict) throws -> NodeInfo {
                var errors: [String: [ValidatorError]] = [
                    "type": [],
                    "name": [],
                    "port": [],
                ]

                var _type: String = String()
                do {
                    _type = try NodeInfo.extract(param: "type", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["type"]?.append(Validation.Error.MissingValue())
                }

                var _name: String = String()
                do {
                    _name = try NodeInfo.extract(param: "name", from: dictionary)

                    if let validatorNameClosure = self.validatorNameClosure {
                        if let error = Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>(callback: validatorNameClosure).validate(input: _name) {
                            errors["name"]?.append(error)
                        }
                    }
                } catch Entita.E.ExtractError {
                    errors["name"]?.append(Validation.Error.MissingValue())
                }

                var _port: Int = Int()
                do {
                    _port = try NodeInfo.extract(param: "port", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["port"]?.append(Validation.Error.MissingValue())
                }

                let filteredErrors = errors.filter({ _, value in value.count > 0 })
                guard filteredErrors.count == 0 else {
                    throw LGNC.E.DecodeError(filteredErrors)
                }

                let instance = self.init(
                    type: _type,
                    name: _name,
                    port: _port
                )

                return instance
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
            public enum CallbackValidatorNameAllowedValues: String, ValidatorErrorRepresentable {
                case NodeWithGivenNameIsNotCheckedIn = "Node with given name is not checked in"

                public func getErrorTuple() -> (message: String, code: Int) {
                    switch self {
                    case .NodeWithGivenNameIsNotCheckedIn:
                        return (message: self.rawValue, code: 404)
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

            public required init(
                name: String,
                entities: Int
            ) {
                self.name = name
                self.entities = entities
            }

            public static func initWithValidation(from dictionary: Entita.Dict) throws -> PingRequest {
                var errors: [String: [ValidatorError]] = [
                    "name": [],
                    "entities": [],
                ]

                var _name: String = String()
                do {
                    _name = try PingRequest.extract(param: "name", from: dictionary)

                    if let validatorNameClosure = self.validatorNameClosure {
                        if let error = Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>(callback: validatorNameClosure).validate(input: _name) {
                            errors["name"]?.append(error)
                        }
                    }
                } catch Entita.E.ExtractError {
                    errors["name"]?.append(Validation.Error.MissingValue())
                }

                var _entities: Int = Int()
                do {
                    _entities = try PingRequest.extract(param: "entities", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["entities"]?.append(Validation.Error.MissingValue())
                }

                let filteredErrors = errors.filter({ _, value in value.count > 0 })
                guard filteredErrors.count == 0 else {
                    throw LGNC.E.DecodeError(filteredErrors)
                }

                let instance = self.init(
                    name: _name,
                    entities: _entities
                )

                return instance
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

            public required init(
                result: String
            ) {
                self.result = result
            }

            public static func initWithValidation(from dictionary: Entita.Dict) throws -> PingResponse {
                var errors: [String: [ValidatorError]] = [
                    "result": [],
                ]

                var _result: String = String()
                do {
                    _result = try PingResponse.extract(param: "result", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["result"]?.append(Validation.Error.MissingValue())
                }

                let filteredErrors = errors.filter({ _, value in value.count > 0 })
                guard filteredErrors.count == 0 else {
                    throw LGNC.E.DecodeError(filteredErrors)
                }

                let instance = self.init(
                    result: _result
                )

                return instance
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
            public enum CallbackValidatorNameAllowedValues: String, ValidatorErrorRepresentable {
                case NodeWithGivenNameAlreadyCheckedIn = "Node with given name already checked in"

                public func getErrorTuple() -> (message: String, code: Int) {
                    switch self {
                    case .NodeWithGivenNameAlreadyCheckedIn:
                        return (message: self.rawValue, code: 409)
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

            public required init(
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

            public static func initWithValidation(from dictionary: Entita.Dict) throws -> CheckinRequest {
                var errors: [String: [ValidatorError]] = [
                    "type": [],
                    "name": [],
                    "port": [],
                    "entities": [],
                ]

                var _type: String = String()
                do {
                    _type = try CheckinRequest.extract(param: "type", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["type"]?.append(Validation.Error.MissingValue())
                }

                var _name: String = String()
                do {
                    _name = try CheckinRequest.extract(param: "name", from: dictionary)

                    if let validatorNameClosure = self.validatorNameClosure {
                        if let error = Validation.CallbackWithAllowedValues<CallbackValidatorNameAllowedValues>(callback: validatorNameClosure).validate(input: _name) {
                            errors["name"]?.append(error)
                        }
                    }
                } catch Entita.E.ExtractError {
                    errors["name"]?.append(Validation.Error.MissingValue())
                }

                var _port: Int = Int()
                do {
                    _port = try CheckinRequest.extract(param: "port", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["port"]?.append(Validation.Error.MissingValue())
                }

                var _entities: Int = Int()
                do {
                    _entities = try CheckinRequest.extract(param: "entities", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["entities"]?.append(Validation.Error.MissingValue())
                }

                let filteredErrors = errors.filter({ _, value in value.count > 0 })
                guard filteredErrors.count == 0 else {
                    throw LGNC.E.DecodeError(filteredErrors)
                }

                let instance = self.init(
                    type: _type,
                    name: _name,
                    port: _port,
                    entities: _entities
                )

                return instance
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

            public required init(
                result: String
            ) {
                self.result = result
            }

            public static func initWithValidation(from dictionary: Entita.Dict) throws -> CheckinResponse {
                var errors: [String: [ValidatorError]] = [
                    "result": [],
                ]

                var _result: String = String()
                do {
                    _result = try CheckinResponse.extract(param: "result", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["result"]?.append(Validation.Error.MissingValue())
                }

                let filteredErrors = errors.filter({ _, value in value.count > 0 })
                guard filteredErrors.count == 0 else {
                    throw LGNC.E.DecodeError(filteredErrors)
                }

                let instance = self.init(
                    result: _result
                )

                return instance
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

            public required init(
                portal: String,
                login: String,
                password: String
            ) {
                self.portal = portal
                self.login = login
                self.password = password
            }

            public static func initWithValidation(from dictionary: Entita.Dict) throws -> LoginRequest {
                var errors: [String: [ValidatorError]] = [
                    "portal": [],
                    "login": [],
                    "password": [],
                ]

                var _portal: String = String()
                do {
                    _portal = try LoginRequest.extract(param: "portal", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["portal"]?.append(Validation.Error.MissingValue())
                }

                var _login: String = String()
                do {
                    _login = try LoginRequest.extract(param: "login", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["login"]?.append(Validation.Error.MissingValue())
                }

                var _password: String = String()
                do {
                    _password = try LoginRequest.extract(param: "password", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["password"]?.append(Validation.Error.MissingValue())
                }

                let filteredErrors = errors.filter({ _, value in value.count > 0 })
                guard filteredErrors.count == 0 else {
                    throw LGNC.E.DecodeError(filteredErrors)
                }

                let instance = self.init(
                    portal: _portal,
                    login: _login,
                    password: _password
                )

                return instance
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

            public required init(
                token: String,
                userID: String
            ) {
                self.token = token
                self.userID = userID
            }

            public static func initWithValidation(from dictionary: Entita.Dict) throws -> LoginResponse {
                var errors: [String: [ValidatorError]] = [
                    "token": [],
                    "userID": [],
                ]

                var _token: String = String()
                do {
                    _token = try LoginResponse.extract(param: "token", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["token"]?.append(Validation.Error.MissingValue())
                }

                var _userID: String = String()
                do {
                    _userID = try LoginResponse.extract(param: "userID", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["userID"]?.append(Validation.Error.MissingValue())
                }

                let filteredErrors = errors.filter({ _, value in value.count > 0 })
                guard filteredErrors.count == 0 else {
                    throw LGNC.E.DecodeError(filteredErrors)
                }

                let instance = self.init(
                    token: _token,
                    userID: _userID
                )

                return instance
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

        public final class Comment: ContractEntity {
            public static let keyDictionary: [String: String] = [
                "ID": "a",
                "IDUser": "c",
                "IDPost": "d",
                "IDReplyComment": "e",
                "isDeleted": "f",
                "body": "g",
                "dateCreated": "h",
                "dateUpdated": "i",
            ]

            public let ID: String
            public let IDUser: String
            public let IDPost: Int
            public let IDReplyComment: String
            public let isDeleted: Bool
            public let body: String
            public let dateCreated: String
            public let dateUpdated: String

            public required init(
                ID: String,
                IDUser: String,
                IDPost: Int,
                IDReplyComment: String,
                isDeleted: Bool,
                body: String,
                dateCreated: String,
                dateUpdated: String
            ) {
                self.ID = ID
                self.IDUser = IDUser
                self.IDPost = IDPost
                self.IDReplyComment = IDReplyComment
                self.isDeleted = isDeleted
                self.body = body
                self.dateCreated = dateCreated
                self.dateUpdated = dateUpdated
            }

            public static func initWithValidation(from dictionary: Entita.Dict) throws -> Comment {
                var errors: [String: [ValidatorError]] = [
                    "ID": [],
                    "IDUser": [],
                    "IDPost": [],
                    "IDReplyComment": [],
                    "isDeleted": [],
                    "body": [],
                    "dateCreated": [],
                    "dateUpdated": [],
                ]

                var _ID: String = String()
                do {
                    _ID = try Comment.extract(param: "ID", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["ID"]?.append(Validation.Error.MissingValue())
                }

                var _IDUser: String = String()
                do {
                    _IDUser = try Comment.extract(param: "IDUser", from: dictionary)

                    if let error = Validation.UUID().validate(input: _IDUser) {
                        errors["IDUser"]?.append(error)
                    }
                } catch Entita.E.ExtractError {
                    errors["IDUser"]?.append(Validation.Error.MissingValue())
                }

                var _IDPost: Int = Int()
                do {
                    _IDPost = try Comment.extract(param: "IDPost", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["IDPost"]?.append(Validation.Error.MissingValue())
                }

                var _IDReplyComment: String = String()
                do {
                    _IDReplyComment = try Comment.extract(param: "IDReplyComment", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["IDReplyComment"]?.append(Validation.Error.MissingValue())
                }

                var _isDeleted: Bool = Bool()
                do {
                    _isDeleted = try Comment.extract(param: "isDeleted", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["isDeleted"]?.append(Validation.Error.MissingValue())
                }

                var _body: String = String()
                do {
                    _body = try Comment.extract(param: "body", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["body"]?.append(Validation.Error.MissingValue())
                }

                var _dateCreated: String = String()
                do {
                    _dateCreated = try Comment.extract(param: "dateCreated", from: dictionary)

                    if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(input: _dateCreated) {
                        errors["dateCreated"]?.append(error)
                    }
                } catch Entita.E.ExtractError {
                    errors["dateCreated"]?.append(Validation.Error.MissingValue())
                }

                var _dateUpdated: String = String()
                do {
                    _dateUpdated = try Comment.extract(param: "dateUpdated", from: dictionary)

                    if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(input: _dateUpdated) {
                        errors["dateUpdated"]?.append(error)
                    }
                } catch Entita.E.ExtractError {
                    errors["dateUpdated"]?.append(Validation.Error.MissingValue())
                }

                let filteredErrors = errors.filter({ _, value in value.count > 0 })
                guard filteredErrors.count == 0 else {
                    throw LGNC.E.DecodeError(filteredErrors)
                }

                let instance = self.init(
                    ID: _ID,
                    IDUser: _IDUser,
                    IDPost: _IDPost,
                    IDReplyComment: _IDReplyComment,
                    isDeleted: _isDeleted,
                    body: _body,
                    dateCreated: _dateCreated,
                    dateUpdated: _dateUpdated
                )

                return instance
            }

            public convenience init(from dictionary: Entita.Dict) throws {
                self.init(
                    ID: try Comment.extract(param: "ID", from: dictionary),
                    IDUser: try Comment.extract(param: "IDUser", from: dictionary),
                    IDPost: try Comment.extract(param: "IDPost", from: dictionary),
                    IDReplyComment: try Comment.extract(param: "IDReplyComment", from: dictionary),
                    isDeleted: try Comment.extract(param: "isDeleted", from: dictionary),
                    body: try Comment.extract(param: "body", from: dictionary),
                    dateCreated: try Comment.extract(param: "dateCreated", from: dictionary),
                    dateUpdated: try Comment.extract(param: "dateUpdated", from: dictionary)
                )
            }

            public func getDictionary() throws -> Entita.Dict {
                return [
                    self.getDictionaryKey("ID"): try self.encode(self.ID),
                    self.getDictionaryKey("IDUser"): try self.encode(self.IDUser),
                    self.getDictionaryKey("IDPost"): try self.encode(self.IDPost),
                    self.getDictionaryKey("IDReplyComment"): try self.encode(self.IDReplyComment),
                    self.getDictionaryKey("isDeleted"): try self.encode(self.isDeleted),
                    self.getDictionaryKey("body"): try self.encode(self.body),
                    self.getDictionaryKey("dateCreated"): try self.encode(self.dateCreated),
                    self.getDictionaryKey("dateUpdated"): try self.encode(self.dateUpdated),
                ]
            }
        }

        public final class Empty: ContractEntity {
            public static let keyDictionary: [String: String] = [
                :
            ]

            public required init(
            ) {
            }

            public static func initWithValidation(from _: Entita.Dict) throws -> Empty {
                var errors: [String: [ValidatorError]] = [
                    :
                ]

                let filteredErrors = errors.filter({ _, value in value.count > 0 })
                guard filteredErrors.count == 0 else {
                    throw LGNC.E.DecodeError(filteredErrors)
                }

                let instance = self.init()

                return instance
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
                "email": "c",
                "password": "d",
                "sex": "e",
                "isBanned": "f",
                "ip": "g",
                "country": "h",
                "dateUnsuccessfulLogin": "i",
                "dateSignup": "j",
                "dateLogin": "k",
                "currentCharacter": "l",
                "authorName": "m",
                "characters": "n",
            ]

            public var ID: String
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
            public var characters: [String: CharacterInfo]

            public required init(
                ID: String,
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
                characters: [String: CharacterInfo] = [String: CharacterInfo]()
            ) {
                self.ID = ID
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
                self.characters = characters
            }

            public static func initWithValidation(from dictionary: Entita.Dict) throws -> User {
                var errors: [String: [ValidatorError]] = [
                    "ID": [],
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
                    "characters": [],
                ]

                var _ID: String = String()
                do {
                    _ID = try User.extract(param: "ID", from: dictionary)

                    if let error = Validation.UUID().validate(input: _ID) {
                        errors["ID"]?.append(error)
                    }
                } catch Entita.E.ExtractError {
                    errors["ID"]?.append(Validation.Error.MissingValue())
                }

                var _email: String = String()
                do {
                    _email = try User.extract(param: "email", from: dictionary)

                    if let error = Validation.Regexp(pattern: "^.+@.+\\..+$", message: "Invalid email format").validate(input: _email) {
                        errors["email"]?.append(error)
                    }

                    if let error = Validation.Length.Min(length: 6).validate(input: _email) {
                        errors["email"]?.append(error)
                    }
                } catch Entita.E.ExtractError {
                    errors["email"]?.append(Validation.Error.MissingValue())
                }

                var _password: String = String()
                do {
                    _password = try User.extract(param: "password", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["password"]?.append(Validation.Error.MissingValue())
                }

                var _sex: String = String()
                do {
                    _sex = try User.extract(param: "sex", from: dictionary)

                    if let error = Validation.In(allowedValues: ["Male", "Female", "Attack helicopter"]).validate(input: _sex) {
                        errors["sex"]?.append(error)
                    }
                } catch Entita.E.ExtractError {
                    errors["sex"]?.append(Validation.Error.MissingValue())
                }

                var _isBanned: Bool = Bool()
                do {
                    _isBanned = try User.extract(param: "isBanned", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["isBanned"]?.append(Validation.Error.MissingValue())
                }

                var _ip: String = String()
                do {
                    _ip = try User.extract(param: "ip", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["ip"]?.append(Validation.Error.MissingValue())
                }

                var _country: String = String()
                do {
                    _country = try User.extract(param: "country", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["country"]?.append(Validation.Error.MissingValue())
                }

                var _dateUnsuccessfulLogin: String = String()
                do {
                    _dateUnsuccessfulLogin = try User.extract(param: "dateUnsuccessfulLogin", from: dictionary)

                    if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(input: _dateUnsuccessfulLogin) {
                        errors["dateUnsuccessfulLogin"]?.append(error)
                    }
                } catch Entita.E.ExtractError {
                    errors["dateUnsuccessfulLogin"]?.append(Validation.Error.MissingValue())
                }

                var _dateSignup: String = String()
                do {
                    _dateSignup = try User.extract(param: "dateSignup", from: dictionary)

                    if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(input: _dateSignup) {
                        errors["dateSignup"]?.append(error)
                    }
                } catch Entita.E.ExtractError {
                    errors["dateSignup"]?.append(Validation.Error.MissingValue())
                }

                var _dateLogin: String = String()
                do {
                    _dateLogin = try User.extract(param: "dateLogin", from: dictionary)

                    if let error = Validation.Date(format: "yyyy-MM-dd kk:mm:ss.SSSSxxx").validate(input: _dateLogin) {
                        errors["dateLogin"]?.append(error)
                    }
                } catch Entita.E.ExtractError {
                    errors["dateLogin"]?.append(Validation.Error.MissingValue())
                }

                var _currentCharacter: String?
                do {
                    _currentCharacter = try User.extract(param: "currentCharacter", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["currentCharacter"]?.append(Validation.Error.MissingValue())
                }

                var _authorName: String = String()
                do {
                    _authorName = try User.extract(param: "authorName", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["authorName"]?.append(Validation.Error.MissingValue())
                }

                var _characters: [String: CharacterInfo] = [String: CharacterInfo]()
                do {
                    _characters = try User.extract(param: "characters", from: dictionary)

                } catch Entita.E.ExtractError {
                    errors["characters"]?.append(Validation.Error.MissingValue())
                }

                let filteredErrors = errors.filter({ _, value in value.count > 0 })
                guard filteredErrors.count == 0 else {
                    throw LGNC.E.DecodeError(filteredErrors)
                }

                let instance = self.init(
                    ID: _ID,
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
                    characters: _characters
                )

                return instance
            }

            public convenience init(from dictionary: Entita.Dict) throws {
                self.init(
                    ID: try User.extract(param: "ID", from: dictionary),
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
                    characters: try User.extract(param: "characters", from: dictionary)
                )
            }

            public func getDictionary() throws -> Entita.Dict {
                return [
                    self.getDictionaryKey("ID"): try self.encode(self.ID),
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
                    self.getDictionaryKey("characters"): try self.encode(self.characters),
                ]
            }
        }
    }
}
