import Decoded

/// A wrapper for using non-object-like values such as primitives and collections in a `Validated` context.
public struct DecodedValueWrapper<T> {
    public var value: Decoded<T>
}

extension DecodedValueWrapper: Decodable where T: Decodable {
    public init(from decoder: Decoder) throws {
        self.init(value: try Decoded<T>(from: decoder))
    }
}
