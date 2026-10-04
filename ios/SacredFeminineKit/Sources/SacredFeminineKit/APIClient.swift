import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Client for the native app API at `/api/v1`. Every call except `signIn`
/// sends the stored token as `Authorization: Bearer <token>`.
public struct APIClient: Sendable {
    public let baseURL: URL
    public let tokenStore: TokenStore
    private let transport: HTTPTransport

    public init(baseURL: URL, tokenStore: TokenStore, transport: HTTPTransport = URLSessionTransport()) {
        self.baseURL = baseURL
        self.tokenStore = tokenStore
        self.transport = transport
    }

    // MARK: Session

    /// Signs in and stores the returned token.
    @discardableResult
    public func signIn(email: String, password: String, deviceName: String) async throws -> Session {
        let body = SignInRequest(email: email, password: password, deviceName: deviceName)
        let session: Session = try await send("POST", "session", body: body, authenticated: false)
        await tokenStore.setToken(session.token)
        return session
    }

    /// Signs this device out on the server and forgets the token, even if the
    /// server call fails.
    public func signOut() async throws {
        do {
            try await sendWithoutResponse("DELETE", "session")
        } catch {
            await tokenStore.setToken(nil)
            throw error
        }
        await tokenStore.setToken(nil)
    }

    // MARK: Devices

    public func devices() async throws -> [Device] {
        let response: DevicesResponse = try await send("GET", "devices")
        return response.devices
    }

    /// Signs the device out on its next request.
    public func revokeDevice(id: Int) async throws {
        try await sendWithoutResponse("DELETE", "devices/\(id)")
    }

    // MARK: Me

    public func me() async throws -> CurrentUser {
        let response: UserResponse = try await send("GET", "me")
        return response.user
    }

    // MARK: Feed

    /// One page of the feed, newest first. Pass the previous page's
    /// `nextCursor` as `before` to load the next page.
    public func feedPosts(before: Int? = nil, limit: Int? = nil) async throws -> FeedPage {
        var query: [URLQueryItem] = []
        if let before { query.append(URLQueryItem(name: "before", value: String(before))) }
        if let limit { query.append(URLQueryItem(name: "limit", value: String(limit))) }
        return try await send("GET", "feed", query: query)
    }

    /// One feed post with its comments and replies.
    public func feedPost(id: Int) async throws -> Post {
        let response: PostResponse = try await send("GET", "feed/\(id)")
        return response.post
    }

    // MARK: Paths

    /// Resolves a server-relative path, such as `User.avatarPath` or `Photo.path`.
    public func url(forPath path: String) -> URL? {
        URL(string: path, relativeTo: baseURL)?.absoluteURL
    }

    // MARK: Requests

    private struct SignInRequest: Encodable {
        let email: String
        let password: String
        let deviceName: String
    }

    private struct Empty: Encodable {}

    private func send<Response: Decodable>(
        _ method: String, _ path: String, query: [URLQueryItem] = [], authenticated: Bool = true
    ) async throws -> Response {
        try await send(method, path, query: query, body: Empty?.none, authenticated: authenticated)
    }

    private func send<Response: Decodable, Body: Encodable>(
        _ method: String, _ path: String, query: [URLQueryItem] = [], body: Body?, authenticated: Bool = true
    ) async throws -> Response {
        let data = try await perform(method, path, query: query, body: body, authenticated: authenticated)
        do {
            return try APIJSON.makeDecoder().decode(Response.self, from: data)
        } catch {
            throw APIError.decoding(String(describing: error))
        }
    }

    private func sendWithoutResponse(_ method: String, _ path: String) async throws {
        _ = try await perform(method, path, query: [], body: Empty?.none, authenticated: true)
    }

    private func perform<Body: Encodable>(
        _ method: String, _ path: String, query: [URLQueryItem], body: Body?, authenticated: Bool
    ) async throws -> Data {
        var request = try makeRequest(method, path, query: query)
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try APIJSON.makeEncoder().encode(body)
        }
        if authenticated, let token = await tokenStore.token() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await transport.send(request)
        guard (200..<300).contains(response.statusCode) else {
            let error = Self.error(status: response.statusCode, data: data)
            if authenticated, case .unauthorized = error {
                await tokenStore.setToken(nil)
            }
            throw error
        }
        return data
    }

    private func makeRequest(_ method: String, _ path: String, query: [URLQueryItem]) throws -> URLRequest {
        let url = baseURL.appendingPathComponent("api/v1").appendingPathComponent(path)
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidResponse
        }
        if !query.isEmpty { components.queryItems = query }
        guard let finalURL = components.url else { throw APIError.invalidResponse }

        var request = URLRequest(url: finalURL)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    static func error(status: Int, data: Data) -> APIError {
        let message = try? APIJSON.makeDecoder().decode(ErrorResponse.self, from: data).error
        switch status {
        case 400: return .badRequest(message: message)
        case 401: return .unauthorized(message: message)
        case 403: return .forbidden(message: message)
        case 404: return .notFound(message: message)
        case 422: return .validation(message: message)
        case 429: return .rateLimited(message: message)
        default: return .unexpectedStatus(status, message: message)
        }
    }
}
