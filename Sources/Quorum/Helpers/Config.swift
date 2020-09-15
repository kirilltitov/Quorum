import Foundation
import LGNConfig

public enum ConfigKeys: String, AnyConfigKey {
    /// Salt used for all encryptions
    case SALT

    /// AES encryption key
    case KEY

    /// Portal ID (used for separation FDB paths within one cluster)
    case REALM

    /// Website address
    case WEBSITE_DOMAIN

    case AUTHOR_LGNS_PORT
    case LOG_LEVEL
    case LGNS_PORT
    case HTTP_PORT
    case PRIVATE_IP
    case REGISTER_TO_CONSUL
    case HASHIDS_SALT
    case HASHIDS_MIN_LENGTH
}
