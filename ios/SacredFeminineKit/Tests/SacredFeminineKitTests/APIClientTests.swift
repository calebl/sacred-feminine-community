import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Testing
@testable import SacredFeminineKit

/// Records requests and answers each with the next queued response.
final class StubTransport: HTTPTransport, @unchecked Sendable {
    private let lock = NSLock()
    private var responses: [(Int, Data)]
    private(set) var requests: [URLRequest] = []

    init(_ responses: [(Int, String)]) {
        self.responses = responses.map { ($0.0, Data($0.1.utf8)) }
    }

    var lastRequest: URLRequest? { lock.withLock { requests.last } }

    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (status, data) = lock.withLock {
            requests.append(request)
            return responses.removeFirst()
        }
        let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!
        return (data, response)
    }
}

@Suite struct APIClientTests {
    let baseURL = URL(string: "https://community.example.com")!

    func example(_ name: String) throws -> String {
        try String(contentsOf: APIExamplesTests.examplesDirectory.appendingPathComponent(name), encoding: .utf8)
    }

    func client(_ transport: StubTransport, token: String? = "secret") -> (APIClient, InMemoryTokenStore) {
        let store = InMemoryTokenStore(token: token)
        return (APIClient(baseURL: baseURL, tokenStore: store, transport: transport), store)
    }

    @Test func signInPostsCredentialsAndStoresToken() async throws {
        let transport = StubTransport([(201, try example("session_create.json"))])
        let (client, store) = client(transport, token: nil)

        let session = try await client.signIn(email: "jane@example.com", password: "pw", deviceName: "Jane's iPhone")

        let request = try #require(transport.lastRequest)
        #expect(request.httpMethod == "POST")
        #expect(request.url?.absoluteString == "https://community.example.com/api/v1/session")
        #expect(request.value(forHTTPHeaderField: "Authorization") == nil)
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        let body = try JSONSerialization.jsonObject(with: try #require(request.httpBody)) as? [String: String]
        #expect(body == ["email": "jane@example.com", "password": "pw", "device_name": "Jane's iPhone"])
        #expect(session.token == "example-api-token")
        #expect(await store.token() == "example-api-token")
    }

    @Test func signInFailureMapsToUnauthorizedAndKeepsNoToken() async throws {
        let transport = StubTransport([(401, try example("error_unauthorized.json"))])
        let (client, store) = client(transport, token: nil)

        await #expect(throws: APIError.unauthorized(message: "Invalid email or password.")) {
            try await client.signIn(email: "jane@example.com", password: "wrong", deviceName: "Phone")
        }
        #expect(await store.token() == nil)
    }

    @Test func signOutDeletesSessionAndClearsToken() async throws {
        let transport = StubTransport([(204, "")])
        let (client, store) = client(transport)

        try await client.signOut()

        let request = try #require(transport.lastRequest)
        #expect(request.httpMethod == "DELETE")
        #expect(request.url?.path == "/api/v1/session")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer secret")
        #expect(await store.token() == nil)
    }

    @Test func signOutClearsTokenEvenWhenTheServerFails() async throws {
        let transport = StubTransport([(500, "")])
        let (client, store) = client(transport)

        await #expect(throws: APIError.unexpectedStatus(500, message: nil)) { try await client.signOut() }
        #expect(await store.token() == nil)
    }

    @Test func authenticatedRequestsSendBearerToken() async throws {
        let transport = StubTransport([(200, try example("me_show.json"))])
        let (client, _) = client(transport)

        let me = try await client.me()

        let request = try #require(transport.lastRequest)
        #expect(request.httpMethod == "GET")
        #expect(request.url?.absoluteString == "https://community.example.com/api/v1/me")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer secret")
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
        #expect(me.email == "jane@example.com")
    }

    @Test func listsAndRevokesDevices() async throws {
        let transport = StubTransport([(200, try example("devices_index.json")), (204, "")])
        let (client, _) = client(transport)

        let devices = try await client.devices()
        #expect(transport.lastRequest?.url?.path == "/api/v1/devices")
        #expect(devices.count == 2)

        try await client.revokeDevice(id: 1)
        #expect(transport.lastRequest?.httpMethod == "DELETE")
        #expect(transport.lastRequest?.url?.path == "/api/v1/devices/1")
    }

    @Test func feedPagingSendsCursorAndLimit() async throws {
        let transport = StubTransport([
            (200, #"{"posts": [], "next_cursor": 42}"#),
            (200, try example("feed_posts_index.json")),
        ])
        let (client, _) = client(transport)

        let first = try await client.feedPosts()
        #expect(transport.lastRequest?.url?.absoluteString == "https://community.example.com/api/v1/feed")
        #expect(first.nextCursor == 42)

        let second = try await client.feedPosts(before: 42, limit: 10)
        let components = URLComponents(url: try #require(transport.lastRequest?.url), resolvingAgainstBaseURL: false)
        #expect(components?.path == "/api/v1/feed")
        #expect(components?.queryItems == [URLQueryItem(name: "before", value: "42"), URLQueryItem(name: "limit", value: "10")])
        #expect(second.nextCursor == nil)
    }

    @Test func showsFeedPost() async throws {
        let transport = StubTransport([(200, try example("feed_post_show.json"))])
        let (client, _) = client(transport)

        let post = try await client.feedPost(id: 7)

        #expect(transport.lastRequest?.url?.path == "/api/v1/feed/7")
        #expect(post.comments?.count == 1)
    }

    @Test func notFoundMapsToTypedError() async throws {
        let transport = StubTransport([(404, try example("error_not_found.json"))])
        let (client, store) = client(transport)

        await #expect(throws: APIError.notFound(message: "Not found.")) { try await client.feedPost(id: 999) }
        #expect(await store.token() == "secret")
    }

    @Test func unauthorizedClearsStoredToken() async throws {
        let transport = StubTransport([(401, #"{"error": "Invalid or expired token."}"#)])
        let (client, store) = client(transport)

        await #expect(throws: APIError.unauthorized(message: "Invalid or expired token.")) { try await client.me() }
        #expect(await store.token() == nil)
    }

    @Test(arguments: [
        (400, APIError.badRequest(message: "m")),
        (403, APIError.forbidden(message: "m")),
        (422, APIError.validation(message: "m")),
        (429, APIError.rateLimited(message: "m")),
        (503, APIError.unexpectedStatus(503, message: "m")),
    ])
    func mapsStatusCodes(status: Int, expected: APIError) {
        #expect(APIClient.error(status: status, data: Data(#"{"error": "m"}"#.utf8)) == expected)
    }

    @Test func errorWithoutJSONBodyHasNoMessage() {
        #expect(APIClient.error(status: 422, data: Data("<html>".utf8)) == .validation(message: nil))
    }

    @Test func unexpectedBodyMapsToDecodingError() async throws {
        let transport = StubTransport([(200, #"{"nope": true}"#)])
        let (client, _) = client(transport)

        await #expect {
            try await client.me()
        } throws: { error in
            if case .decoding = error as? APIError { return true }
            return false
        }
    }

    @Test func resolvesServerRelativePaths() {
        let client = APIClient(baseURL: baseURL, tokenStore: InMemoryTokenStore())
        #expect(client.url(forPath: "/rails/active_storage/x.png")?.absoluteString == "https://community.example.com/rails/active_storage/x.png")
    }
}
