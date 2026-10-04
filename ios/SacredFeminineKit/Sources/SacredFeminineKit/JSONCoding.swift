import Foundation

public enum APIJSON {
  /// A decoder for the API's snake_case keys and ISO 8601 timestamps, which
  /// Rails writes with milliseconds.
  public static func makeDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .custom { decoder in
      let container = try decoder.singleValueContainer()
      let string = try container.decode(String.self)
      let timeStart = string.firstIndex(of: "T") ?? string.endIndex
      let fractionStart =
        string[timeStart...].firstIndex(of: ".")
        .map { string.index(after: $0) } ?? string.endIndex
      let fractionEnd =
        string[fractionStart...].firstIndex { $0 == "Z" || $0 == "+" || $0 == "-" }
        ?? string.endIndex
      let fraction = string[fractionStart..<fractionEnd]

      guard !fraction.isEmpty,
        fraction.allSatisfy(\.isNumber),
        let date = try? Date(
          string, strategy: Date.ISO8601FormatStyle(includingFractionalSeconds: true))
      else {
        throw DecodingError.dataCorruptedError(
          in: container, debugDescription: "Invalid ISO 8601 date: \(string)")
      }
      return date
    }
    return decoder
  }

  public static func makeEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    encoder.dateEncodingStrategy = .iso8601
    return encoder
  }
}
