import Decoded

struct KeyedErrors {
    private(set) var value: [CodingPath: [Error]]

    public init(codingPath: CodingPath, error: Error) {
        self.value = [codingPath: [error]]
    }

    public mutating func merge(_ other: KeyedErrorsRepresentable?) {
        guard let other = other?.keyedErrors else { return }
        value.merge(other.value, uniquingKeysWith: +)
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
    public var keyedErrors: KeyedErrors? {
        .init(self)
    }
}

