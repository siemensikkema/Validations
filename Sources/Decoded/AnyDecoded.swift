public protocol AnyDecoded {
    var codingPath: CodingPath { get }
}

extension Decoded: AnyDecoded {}
