public protocol AnyDecoded {
    var codingPath: [AnyCodingKey] { get }
}

extension Decoded: AnyDecoded {}
