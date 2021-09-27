import Decoded

public typealias KeyedFailures = KeyedValues<ValidationFailure>

public struct KeyedValues<T> {
    public private(set) var value: [CodingPath: [T]]

    private init(_ value: [CodingPath: [T]]) {
        self.value = value
    }
}

extension KeyedFailures: Error {}

extension KeyedFailures {
    init(codingPath: CodingPath, failure: T) {
        self.value = [codingPath: [failure]]
    }

    mutating func merge(_ other: KeyedFailuresRepresentable?) {
        guard let other = other?.keyedFailures else { return }
        value.merge(other.value, uniquingKeysWith: +)
    }

    public func mapFailures<U>(_ transform: (T) -> U) -> KeyedValues<U> {
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

extension Optional where Wrapped == KeyedFailures {
    mutating func merge(_ other: KeyedFailuresRepresentable?) {
        self = self.merging(other)
    }
}

extension KeyedFailures {
    init(_ keyedFailure: KeyedFailure) {
        self.init(codingPath: keyedFailure.codingPath, failure: keyedFailure.failure)
    }
}

extension KeyedFailures: KeyedFailuresRepresentable {
    var keyedFailures: KeyedFailures? {
        .init(self)
    }
}

