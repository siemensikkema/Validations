import Decoded

public typealias KeyedErrors = KeyedValues<Error>

public struct KeyedValues<T> {
    public private(set) var value: [CodingPath: [T]]

    private init(_ value: [CodingPath: [T]]) {
        self.value = value
    }
}

extension KeyedErrors: Error {}

extension KeyedErrors {
    init(codingPath: CodingPath, error: T) {
        self.value = [codingPath: [error]]
    }

    mutating func merge(_ other: KeyedErrorsRepresentable?) {
        guard let other = other?.keyedErrors else { return }
        value.merge(other.value, uniquingKeysWith: +)
    }

    public func mapErrors<U>(_ transform: (T) -> U) -> KeyedValues<U> {
        .init(value.mapValuesEach(transform))
    }
}

extension Dictionary where Value: Collection {
    func mapValuesEach<T>(_ transform: (Value.Element) -> T) -> [Key: [T]] {
        mapValues { value in
            value.map(transform)
        }
    }
}

extension Optional where Wrapped == KeyedErrors {
    mutating func merge(_ other: KeyedErrorsRepresentable?) {
        self = self.merging(other)
    }
}

extension KeyedErrors {
    init(_ keyedError: KeyedError) {
        self.init(codingPath: keyedError.codingPath, error: keyedError.error)
    }
}

extension KeyedErrors: KeyedErrorsRepresentable {
    var keyedErrors: KeyedErrors? {
        .init(self)
    }
}

