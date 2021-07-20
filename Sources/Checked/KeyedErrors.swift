import Decoded

public typealias KeyedErrors = [[AnyCodingKey]: [Error]]

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
        Mirror(reflecting: try requireValue())
            .children
            .reduce(into: [:]) { keyedErrors, child in
                if let value = child.value as? KeyedErrorsProtocol {
                    keyedErrors.merge(value.keyedErrors()) { $1 }
                }
            }
    }
}
