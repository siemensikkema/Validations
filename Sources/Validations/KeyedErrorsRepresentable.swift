import Decoded

protocol KeyedErrorsRepresentable {
    var keyedErrors: KeyedErrors? { get }
}

extension KeyedErrorsRepresentable {
    func merging(_ other: KeyedErrorsRepresentable?) -> KeyedErrors? {
        var copy = keyedErrors
        copy?.merge(other)
        return copy ?? other.keyedErrors
    }
}

extension Optional: KeyedErrorsRepresentable where Wrapped: KeyedErrorsRepresentable {
    var keyedErrors: KeyedErrors? {
        self?.keyedErrors
    }
}

extension Decoded: KeyedErrorsRepresentable {
    var keyedErrors: KeyedErrors? {
        do {
            return try Mirror(reflecting: result.unwrapped).keyedErrors
        } catch {
            return .init(codingPath: codingPath, error: error)
        }
    }
}

extension Mirror {
    var keyedErrors: KeyedErrors? {
        children.reduce(into: nil) { keyedErrors, child in
            keyedErrors.merge(child.value as? KeyedErrorsRepresentable)
        }
    }
}

extension Optional where Wrapped == KeyedErrorsRepresentable {
    var keyedErrors: KeyedErrors? {
        flatMap(\.keyedErrors)
    }
}

