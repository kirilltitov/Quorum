import Foundation
import LGNCore

public extension String {
    @inlinable var bool: Bool {
        return self == "yes" || self == "true" || self == "1" || self == "YES" || self == "TRUE"
    }

    @inlinable func tr(_ locale: LGNCore.i18n.Locale, _ interpolations: [String: Any] = [:]) -> String {
        return LGNCore.i18n.tr(self, locale, interpolations)
    }
}
