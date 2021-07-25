extension Decoded: Decodable where T: Decodable {
    public init(from decoder: Decoder) throws {
        codingPath = decoder.codingPath.map(AnyCodingKey.init)
        wrappedValue = try .init(from: decoder)
    }
}

extension Decoded.State: Decodable where T: Decodable {
    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            self = try container.decodeNil() ? .nil : .value(container.decode(T.self))
        } catch let DecodingError.typeMismatch(_, context) {
            self = .typeMismatch(context.debugDescription)
        }
    }
}

public extension KeyedDecodingContainer {
    func decode<T: Decodable>(
        _ type: Decoded<T>.Type,
        forKey key: Key
    ) throws -> Decoded<T> {
        .init(
            codingPath: (codingPath + [key]).map(AnyCodingKey.init),
            wrappedValue: try decodeIfPresent(Decoded<T>.State.self, forKey: key) ?? (contains(key) ? .nil : .absent)
        )
    }
}
