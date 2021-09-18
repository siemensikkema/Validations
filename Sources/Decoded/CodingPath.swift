public typealias CodingPath = [AnyCodingKey]

public extension Array where Element == AnyCodingKey {
    var dotPath: String {
        map(\.description).joined(separator: ".")
    }
}
