import Decoded

@dynamicMemberLookup
public struct Checked<T> {
    let state: Decoded<T>.State

    fileprivate init(state: Decoded<T>.State) {
        self.state = state
    }

    public subscript<U>(dynamicMember keyPath: KeyPath<T, U>) -> U {
        try! state[dynamicMember: keyPath]
    }

    public subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>.State>) -> Checked<U> {
        try! .init(state: state[dynamicMember: keyPath])
    }

    public subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>.State>) -> U {
        try! state[dynamicMember: keyPath]
    }
}

extension Decoded {
    public func checked(mergingErrors additional: KeyedErrors? = nil) throws -> Checked<T> {
        if let keyedErrors = keyedErrors().merging(additional) {
            throw keyedErrors
        }

        return .init(state: wrappedValue)
    }
}
