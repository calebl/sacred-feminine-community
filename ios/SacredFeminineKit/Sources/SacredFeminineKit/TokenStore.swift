/// Where the client keeps the bearer token between requests. The app stores
/// it in the Keychain; tests and previews use `InMemoryTokenStore`.
public protocol TokenStore: Sendable {
    func token() async -> String?
    func setToken(_ token: String?) async
}

public actor InMemoryTokenStore: TokenStore {
    private var value: String?

    public init(token: String? = nil) {
        value = token
    }

    public func token() -> String? {
        value
    }

    public func setToken(_ token: String?) {
        value = token
    }
}
