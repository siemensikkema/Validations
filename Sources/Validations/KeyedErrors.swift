import Decoded

struct KeyedErrors {
    private(set) var value: [CodingPath: [Error]]

    private init(value: [CodingPath: [Error]]) {
        self.value = value
    }

    init(codingPath: CodingPath, error: Error) {
        self.value = [codingPath: [error]]
    }

    mutating func merge(_ other: KeyedErrorsRepresentable?) {
        guard let other = other?.keyedErrors else { return }
        value.merge(other.value, uniquingKeysWith: +)
    }

    func mapErrors(_ transform: (Error) -> Error) -> Self {
        .init(value: value.mapValuesEach(transform))
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

