import Lifecycle

extension LifecycleHandler {
    public init(_ handler: @Sendable @escaping () async throws -> Void) {
        self = LifecycleHandler { callback in
            Task {
                do {
                    try await handler()
                    callback(nil)
                } catch {
                    callback(error)
                }
            }
        }
    }

    public static func asyncc(_ handler: @Sendable @escaping () async throws -> Void) -> LifecycleHandler {
        LifecycleHandler(handler)
    }
}
