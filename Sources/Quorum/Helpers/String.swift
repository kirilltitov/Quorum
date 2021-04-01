import Foundation
import LGNCore
import _Concurrency

public extension String {
    @inlinable
    var bool: Bool {
        self == "yes" || self == "true" || self == "1" || self == "YES" || self == "TRUE"
    }

    @inlinable
    func tr(_ interpolations: [String: Any] = [:]) -> String {
        LGNCore.i18n.tr(self, Task.local(\.context).locale, interpolations)
    }
}
