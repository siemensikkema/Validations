public struct Decoded<T> {
    public let codingPath: [AnyCodingKey]
    public let state: State<T>
}

extension Decoded: Equatable where T: Equatable {}
