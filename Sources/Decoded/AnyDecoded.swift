public protocol AnyDecoded {
    var codingPath: [BasicCodingKey] { get }
}
extension Decoded: AnyDecoded {}
