public enum State<T> {
    case absent
    case `nil`
    case value(T)
    case typeMismatch(String)
}

public struct Decoded<T> {
    public let codingPath: [BasicCodingKey]
    public let state: State<T>
}
