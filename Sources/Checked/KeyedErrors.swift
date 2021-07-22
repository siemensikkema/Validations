import Decoded

public struct KeyedErrors: Error {
    var _value: [CodingPath: [Error]]

    public var value: [CodingPath: [Error]] { _value }

    public init(error: Error, codingPath: CodingPath) {
        self._value = [codingPath: [error]]
    }

    public mutating func merge(_ other: KeyedErrors?) {
        guard let other = other else { return }
        _value.merge(other._value, uniquingKeysWith: +)
    }

    public func mapErrors<T>(_ closure: (Error) -> T) -> [CodingPath: [T]] {
        _value.mapValues { errors in
            errors.map(closure)
        }
    }
}

extension Optional where Wrapped == KeyedErrors {
    public func merging(_ other: KeyedErrors?) -> Self {
        var copy = self
        copy.merge(other)
        return copy
    }

    public mutating func merge(_ other: KeyedErrors?) {
        guard var keyedErrors = self else {
            self = other
            return
        }
        keyedErrors.merge(other)
        self = keyedErrors
    }

    mutating func merge(_ other: KeyedErrorsProtocol?) {
        merge(other?.keyedErrors())
    }
}

protocol KeyedErrorsProtocol {
    func keyedErrors() -> KeyedErrors?
}

extension Decoded: KeyedErrorsProtocol {
    func keyedErrors() -> KeyedErrors? {
        do {
            return try state.keyedErrors()
        } catch {
            return .init(error: error, codingPath: codingPath)
        }
    }
}

extension State {
    func keyedErrors() throws -> KeyedErrors? {
        Mirror(reflecting: try value)
            .children
            .reduce(into: nil) { keyedErrors, child in
                keyedErrors.merge(child.value as? KeyedErrorsProtocol)
            }
    }
}
