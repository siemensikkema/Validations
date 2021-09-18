import Decoded

public protocol KeyedErrorsRepresentable {
    var keyedErrors: KeyedErrors? { get }
}

public extension KeyedErrorsRepresentable {
    func merging(_ other: KeyedErrorsRepresentable?) -> KeyedErrors? {
        var copy = keyedErrors
        copy?.merge(other)
        return copy ?? other.keyedErrors
    }
}

extension Optional: KeyedErrorsRepresentable where Wrapped: KeyedErrorsRepresentable {
    public var keyedErrors: KeyedErrors? {
        self?.keyedErrors
    }
}

extension Decoded: KeyedErrorsRepresentable {
    public var keyedErrors: KeyedErrors? {
        do {
            return try Mirror(reflecting: result.unwrapped).keyedErrors
        } catch let error as ValidationError {
            return .init(codingPath: codingPath, error: error)
        } catch {
            return nil
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
    public var keyedErrors: KeyedErrors? {
        flatMap(\.keyedErrors)
    }
}

