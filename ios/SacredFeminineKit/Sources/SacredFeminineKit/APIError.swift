/// A failed API call. Messages come from the server's `{"error": ...}` body
/// when it has one.
public enum APIError: Error, Equatable, Sendable {
  /// 401: the email or password was wrong, or the token is missing, expired
  /// or revoked. The client clears its stored token on this error.
  case unauthorized(message: String?)
  /// 403
  case forbidden(message: String?)
  /// 404
  case notFound(message: String?)
  /// 422: the request was understood but its values were rejected.
  case validation(message: String?)
  /// 400
  case badRequest(message: String?)
  /// 429
  case rateLimited(message: String?)
  /// Any other non-2xx status.
  case unexpectedStatus(Int, message: String?)
  /// A 2xx response whose body did not match the expected shape.
  case decoding(String)
  case invalidResponse
}
