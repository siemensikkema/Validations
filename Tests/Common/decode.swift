import Foundation

private let decoder = JSONDecoder()

public func decode<T: Decodable>(_ string: String, as _: T.Type = T.self) throws -> T {
    try decoder.decode(T.self, from: string.data(using: .utf8)!)
}
