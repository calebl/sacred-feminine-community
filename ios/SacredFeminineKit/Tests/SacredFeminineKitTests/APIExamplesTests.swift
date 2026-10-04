import Foundation
import Testing
@testable import SacredFeminineKit

/// Decodes the example responses the Rails request tests write to
/// test/api_examples/v1, read straight from the repository so an API shape
/// change fails here.
@Suite struct APIExamplesTests {
    static let examplesDirectory = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent() // SacredFeminineKitTests
        .deletingLastPathComponent() // Tests
        .deletingLastPathComponent() // SacredFeminineKit
        .deletingLastPathComponent() // ios
        .deletingLastPathComponent() // repository root
        .appendingPathComponent("test/api_examples/v1")

    /// Every example file and the type it decodes as. A new example file must
    /// be added here.
    static let decoders: [String: @Sendable (Data) throws -> Any] = [
        "devices_index.json": { try decode(DevicesResponse.self, $0) },
        "error_not_found.json": { try decode(ErrorResponse.self, $0) },
        "error_unauthorized.json": { try decode(ErrorResponse.self, $0) },
        "feed_post_show.json": { try decode(PostResponse.self, $0) },
        "feed_post_show_removed_authors.json": { try decode(PostResponse.self, $0) },
        "feed_post_show_with_photo.json": { try decode(PostResponse.self, $0) },
        "feed_posts_index.json": { try decode(FeedPage.self, $0) },
        "me_show.json": { try decode(UserResponse.self, $0) },
        "session_create.json": { try decode(Session.self, $0) },
    ]

    static func decode<T: Decodable>(_ type: T.Type, _ data: Data) throws -> T {
        try APIJSON.makeDecoder().decode(type, from: data)
    }

    static func example<T: Decodable>(_ name: String, as type: T.Type) throws -> T {
        try decode(type, Data(contentsOf: examplesDirectory.appendingPathComponent(name)))
    }

    static func unknownEnums(in value: Any) -> [String] {
        if case .unknown(let raw)? = value as? Role {
            return ["Role.unknown(\(raw))"]
        }
        if case .unknown(let raw)? = value as? PostKind {
            return ["PostKind.unknown(\(raw))"]
        }
        return Mirror(reflecting: value).children.flatMap { unknownEnums(in: $0.value) }
    }

    static let fixedDate = Date(timeIntervalSince1970: 1_767_268_800) // 2026-01-01T12:00:00Z

    @Test func everyExampleFileDecodes() throws {
        let files = try FileManager.default.contentsOfDirectory(atPath: Self.examplesDirectory.path)
            .filter { $0.hasSuffix(".json") }
            .sorted()
        #expect(!files.isEmpty)
        for file in files {
            let decoder = try #require(Self.decoders[file], "No decoder for \(file); add it to APIExamplesTests.decoders")
            let data = try Data(contentsOf: Self.examplesDirectory.appendingPathComponent(file))
            let decoded = try decoder(data)
            #expect(Self.unknownEnums(in: decoded).isEmpty, "\(file) contains an unknown enum value")
        }
        #expect(Set(files) == Set(Self.decoders.keys), "Decoders listed for missing files")
    }

    @Test func datesRequireFractionalSeconds() throws {
        let fractional = Data(#""2026-01-01T12:00:00.000Z""#.utf8)
        let wholeSeconds = Data(#""2026-01-01T12:00:00Z""#.utf8)

        #expect(throws: Never.self) { _ = try Self.decode(Date.self, fractional) }
        #expect(throws: (any Error).self) { _ = try Self.decode(Date.self, wholeSeconds) }
    }

    @Test func session() throws {
        let session = try Self.example("session_create.json", as: Session.self)
        #expect(session.token == "example-api-token")
        #expect(session.device.current)
        #expect(session.device.lastUsedAt == nil)
        #expect(session.device.createdAt == Self.fixedDate)
        #expect(session.user.profile.name == "Jane Attendee")
        #expect(session.user.email == "jane@example.com")
    }

    @Test func me() throws {
        let user = try Self.example("me_show.json", as: UserResponse.self).user
        #expect(user.profile.role == .attendee)
        #expect(user.profile.removed == false)
        #expect(user.state == nil)
        #expect(user.country == "France")
        #expect(user.showOnMap)
        #expect(user.dmPrivacy == "cohort_members")
        #expect(user.unreadNotificationCount == 0)
    }

    @Test func devices() throws {
        let devices = try Self.example("devices_index.json", as: DevicesResponse.self).devices
        #expect(devices.map(\.name) == ["Jane's iPad", "Jane's iPhone"])
        #expect(devices.map(\.current) == [false, true])
        #expect(devices[1].lastUsedAt == Self.fixedDate)
    }

    @Test func feedPage() throws {
        let page = try Self.example("feed_posts_index.json", as: FeedPage.self)
        #expect(page.posts.count == 4)
        #expect(page.nextCursor == nil)
        #expect(page.posts.allSatisfy { $0.kind == .feed && $0.comments == nil })
        #expect(page.posts[2].pinned)
        #expect(page.posts[3].reactions == [Reaction(emoji: "🔥", count: 1, reactedByMe: false)])
    }

    @Test func postWithNestedComments() throws {
        let post = try Self.example("feed_post_show.json", as: PostResponse.self).post
        #expect(post.author.role == .admin)
        let comments = try #require(post.comments)
        #expect(comments.count == 1)
        let reply = try #require(comments[0].replies.first)
        #expect(reply.parentId == comments[0].id)
        #expect(reply.canDelete)
        #expect(reply.replies.first?.body == "You're welcome!")
    }

    @Test func postWithPhoto() throws {
        let post = try Self.example("feed_post_show_with_photo.json", as: PostResponse.self).post
        #expect(post.photos.first?.contentType == "image/png")
        #expect(post.photos.first?.path == "/rails/active_storage/blobs/redirect/example-signed-id/photo.png")
    }

    @Test func removedAuthors() throws {
        let post = try Self.example("feed_post_show_removed_authors.json", as: PostResponse.self).post
        #expect(post.author.removed)
        #expect(post.author.role == nil)
        #expect(post.author.location == nil)
        #expect(post.comments?.first?.author.removed == true)
    }

    @Test func errors() throws {
        #expect(try Self.example("error_not_found.json", as: ErrorResponse.self).error == "Not found.")
        #expect(try Self.example("error_unauthorized.json", as: ErrorResponse.self).error == "Invalid email or password.")
    }
}
