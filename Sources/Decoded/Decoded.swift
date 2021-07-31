@propertyWrapper
public struct Decoded<T> {
    public init(codingPath: CodingPath = [], state: State = .absent) {
        self.codingPath = codingPath
        self.state = state
    }

    public var projectedValue: Self { self }
    public var wrappedValue: State { state }

    public let codingPath: CodingPath
    public let state: State
}

extension Decoded: Hashable where T: Hashable {}
extension Decoded: Equatable where T: Equatable {}

extension Decoded: Decodable where T: Decodable {
    public init(from decoder: Decoder) throws {
        codingPath = decoder.codingPath.map(AnyCodingKey.init)
        state = try .init(from: decoder)
    }
}

public extension KeyedDecodingContainer {
    func decode<T: Decodable>(
        _ type: Decoded<T>.Type,
        forKey key: Key
    ) throws -> Decoded<T> {
        .init(
            codingPath: (codingPath + [key]).map(AnyCodingKey.init),
            state: try decodeIfPresent(Decoded<T>.State.self, forKey: key) ?? (contains(key) ? .nil : .absent)
        )
    }
}
