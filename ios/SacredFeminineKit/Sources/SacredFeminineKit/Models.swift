import Foundation

/// A member as any other member may see them. Removed members keep their id
/// and name, and every other field is nil.
public struct User: Codable, Equatable, Sendable, Identifiable {
  public let id: Int
  public let name: String
  public let role: Role?
  public let bio: String?
  public let location: String?
  /// Relative to the server; resolve it with `APIClient.url(forPath:)`.
  public let avatarPath: String?
  public let removed: Bool
}

public enum Role: Codable, Equatable, Sendable {
  case attendee
  case admin
  case unknown(String)

  public init(from decoder: Decoder) throws {
    let value = try decoder.singleValueContainer().decode(String.self)
    switch value {
    case "attendee": self = .attendee
    case "admin": self = .admin
    default: self = .unknown(value)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .attendee: try container.encode("attendee")
    case .admin: try container.encode("admin")
    case .unknown(let value): try container.encode(value)
    }
  }
}

/// The signed-in member: the public profile plus private settings and counts.
public struct CurrentUser: Codable, Equatable, Sendable {
  public let profile: User
  public let email: String
  public let city: String?
  public let state: String?
  public let country: String?
  public let showOnMap: Bool
  public let dmPrivacy: String
  public let mentionPrivacy: String
  public let cohortGenderPrivacy: String
  public let unreadNotificationCount: Int

  private enum CodingKeys: String, CodingKey {
    case email, city, state, country, showOnMap, dmPrivacy, mentionPrivacy, cohortGenderPrivacy,
      unreadNotificationCount
  }

  public init(from decoder: Decoder) throws {
    profile = try User(from: decoder)
    let container = try decoder.container(keyedBy: CodingKeys.self)
    email = try container.decode(String.self, forKey: .email)
    city = try container.decodeIfPresent(String.self, forKey: .city)
    state = try container.decodeIfPresent(String.self, forKey: .state)
    country = try container.decodeIfPresent(String.self, forKey: .country)
    showOnMap = try container.decode(Bool.self, forKey: .showOnMap)
    dmPrivacy = try container.decode(String.self, forKey: .dmPrivacy)
    mentionPrivacy = try container.decode(String.self, forKey: .mentionPrivacy)
    cohortGenderPrivacy = try container.decode(String.self, forKey: .cohortGenderPrivacy)
    unreadNotificationCount = try container.decode(Int.self, forKey: .unreadNotificationCount)
  }

  public func encode(to encoder: Encoder) throws {
    try profile.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(email, forKey: .email)
    try container.encode(city, forKey: .city)
    try container.encode(state, forKey: .state)
    try container.encode(country, forKey: .country)
    try container.encode(showOnMap, forKey: .showOnMap)
    try container.encode(dmPrivacy, forKey: .dmPrivacy)
    try container.encode(mentionPrivacy, forKey: .mentionPrivacy)
    try container.encode(cohortGenderPrivacy, forKey: .cohortGenderPrivacy)
    try container.encode(unreadNotificationCount, forKey: .unreadNotificationCount)
  }
}

/// A device signed in to the member's account.
public struct Device: Codable, Equatable, Sendable, Identifiable {
  public let id: Int
  public let name: String
  /// True for the device making the request.
  public let current: Bool
  public let lastUsedAt: Date?
  public let createdAt: Date
}

/// The result of signing in. The token is returned only this once.
public struct Session: Codable, Equatable, Sendable {
  public let token: String
  public let device: Device
  public let user: CurrentUser
}

public struct Mention: Codable, Equatable, Sendable {
  public let userId: Int
  public let name: String
}

public struct Reaction: Codable, Equatable, Sendable {
  public let emoji: String
  public let count: Int
  public let reactedByMe: Bool
}

public struct Photo: Codable, Equatable, Sendable, Identifiable {
  public let id: Int
  public let contentType: String
  /// Relative to the server; resolve it with `APIClient.url(forPath:)`.
  public let path: String
}

public enum PostKind: Codable, Equatable, Sendable {
  case feed
  case unknown(String)

  public init(from decoder: Decoder) throws {
    let value = try decoder.singleValueContainer().decode(String.self)
    self = value == "feed" ? .feed : .unknown(value)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .feed: try container.encode("feed")
    case .unknown(let value): try container.encode(value)
    }
  }
}

public struct Post: Codable, Equatable, Sendable, Identifiable {
  public let id: Int
  public let kind: PostKind
  public let body: String
  public let mentions: [Mention]
  public let author: User
  public let pinned: Bool
  public let commentCount: Int
  public let photos: [Photo]
  public let reactions: [Reaction]
  public let canEdit: Bool
  public let canDelete: Bool
  public let createdAt: Date
  public let updatedAt: Date
  /// Top-level comments with their replies. Present only on a single post, nil in lists.
  public let comments: [Comment]?
}

public struct Comment: Codable, Equatable, Sendable, Identifiable {
  public let id: Int
  public let postId: Int
  public let parentId: Int?
  public let body: String
  public let mentions: [Mention]
  public let author: User
  public let reactions: [Reaction]
  public let canDelete: Bool
  public let createdAt: Date
  public let updatedAt: Date
  public let replies: [Comment]
}

/// One page of the feed. Pass `nextCursor` as `before` to load the next page;
/// it is nil on the last page.
public struct FeedPage: Codable, Equatable, Sendable {
  public let posts: [Post]
  public let nextCursor: Int?
}

/// The body of every error response.
public struct ErrorResponse: Codable, Equatable, Sendable {
  public let error: String
}

public struct PostResponse: Codable, Equatable, Sendable {
  public let post: Post
}

public struct UserResponse: Codable, Equatable, Sendable {
  public let user: CurrentUser
}

public struct DevicesResponse: Codable, Equatable, Sendable {
  public let devices: [Device]
}
