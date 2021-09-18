import Decoded

public struct KeyedErrors: Error {
    public private(set) var value: [CodingPath: [ValidationError]]

    public init(codingPath: CodingPath, error: ValidationError) {
        self.value = [codingPath: [error]]
    }

    public mutating func merge(_ other: KeyedErrorsRepresentable?) {
        guard let other = other?.keyedErrors else { return }
        value.merge(other.value, uniquingKeysWith: +)
    }
}

public extension Optional where Wrapped == KeyedErrors {
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

