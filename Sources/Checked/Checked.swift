import Decoded

@dynamicMemberLookup
public struct Checked<T> {
    let state: Decoded<T>.State

    fileprivate init(state: Decoded<T>.State) {
        self.state = state
    }
}

public extension Checked {
    subscript<U>(dynamicMember keyPath: KeyPath<T, U>) -> U {
        try! state[dynamicMember: keyPath]
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>.State>) -> Checked<U> {
        try! .init(state: state[dynamicMember: keyPath])
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>.State>) -> U {
        try! state[dynamicMember: keyPath]
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>.State?>) -> Checked<U>? {
        try! state[dynamicMember: keyPath].map(Checked<U>.init)
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>.State?>) -> U? {
        try! state[dynamicMember: keyPath]
    }
}

public extension Checked where T: Sequence {
    func unwrapped<U>() -> [U] where T.Element == Decoded<U>.State {
        try! state.value.unwrapped()
    }
}

public extension Checked {
    func unwrapped<Key, Value>() -> [Key: Value] where T == [Key: Decoded<Value>.State] {
        try! state.value.unwrapped()
    }
}

extension Decoded {
    public func checked(mergingErrors additional: KeyedErrors? = nil) throws -> Checked<T> {
        if let keyedErrors = keyedErrors().merging(additional) {
            throw keyedErrors
        }

        return .init(state: state)
    }
}

extension Checked: Decodable where T: Decodable {
    public init(from decoder: Decoder) throws {
        self = try Decoded<T>(from: decoder).checked()
    }
}
