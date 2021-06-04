import Decoded

public typealias KeyedErrors = [[BasicCodingKey]: [Error]]

protocol KeyedErrorsProtocol {
    func keyedErrors() -> KeyedErrors
}

extension Decoded: KeyedErrorsProtocol {
    func keyedErrors() -> KeyedErrors {
        do {
            return try state.keyedErrors()
        } catch {
            return [codingPath: [error]]
        }
    }
}

extension State {
    func keyedErrors() throws -> KeyedErrors {
        Mirror(reflecting: try getValue())
            .children
            .reduce(into: [:]) { keyedErrors, child in
                if let value = child.value as? KeyedErrorsProtocol {
                    keyedErrors.merge(value.keyedErrors()) { $1 }
                }
            }
    }

    func getValue() throws -> T {
        func valueAsNil() -> T? {
            (T.self as? ExpressibleByNilLiteral.Type)?.init(nilLiteral: ()) as? T
        }

        switch self {
        case .value(let value):
            return value
        case .absent:
            guard let value = valueAsNil() else {
                throw Absent()
            }
            return value
        case .nil:
            guard let value = valueAsNil() else {
                throw Nil()
            }
            return value
        case .typeMismatch(let description):
            throw TypeMismatch(description: description)
        }
    }
}
