import Decoded

protocol KeyedFailuresRepresentable {
    var keyedFailures: KeyedFailures? { get }
}

extension KeyedFailuresRepresentable {
    func merging(_ other: KeyedFailuresRepresentable?) -> KeyedFailures? {
        var copy = keyedFailures
        copy?.merge(other)
        return copy ?? other.keyedFailures
    }
}

extension Optional: KeyedFailuresRepresentable where Wrapped: KeyedFailuresRepresentable {
    var keyedFailures: KeyedFailures? {
        self?.keyedFailures
    }
}

extension Decoded: KeyedFailuresRepresentable {
    var keyedFailures: KeyedFailures? {
        switch result {
        case .success(let success):
            return Mirror(reflecting: success.value).keyedFailures
        case .failure(let failure):
            return .init(codingPath: codingPath, failure: failure)
        }
    }
}

extension Mirror {
    var keyedFailures: KeyedFailures? {
        children.reduce(into: nil) { keyedFailures, child in
            keyedFailures.merge(child.value as? KeyedFailuresRepresentable)
        }
    }
}

extension Optional where Wrapped == KeyedFailuresRepresentable {
    var keyedFailures: KeyedFailures? {
        flatMap(\.keyedFailures)
    }
}
