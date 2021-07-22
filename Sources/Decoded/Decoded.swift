public struct Decoded<T> {
    public let codingPath: CodingPath
    public let state: State<T>
}

extension Decoded: Equatable where T: Equatable {}
