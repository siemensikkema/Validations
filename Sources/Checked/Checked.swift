import Decoded

@dynamicMemberLookup
public struct Checked<T> {
    let unchecked: Unchecked<T>

    public subscript<U>(dynamicMember keyPath: KeyPath<T, U>) -> U {
        unchecked[dynamicMember: keyPath]!
    }

    public subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>>) -> Checked<U> {
        .init(unchecked: unchecked[dynamicMember: keyPath]!)
    }

    public subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>>) -> U {
        unchecked[dynamicMember: keyPath]!
    }
}

extension Decoded {
    public func checked() throws -> Checked<T> {
        try unchecked().checked()
    }
}
