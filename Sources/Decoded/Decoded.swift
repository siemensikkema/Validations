@propertyWrapper
public struct Decoded<T> {
    public init(codingPath: CodingPath = [], wrappedValue: State = .absent) {
        self.codingPath = codingPath
        self.wrappedValue = wrappedValue
    }

    public let codingPath: CodingPath
    public let wrappedValue: State

    public var projectedValue: Self { self }
    public var state: State { wrappedValue }
}

extension Decoded: Equatable where T: Equatable {}
