public struct Decoded<T> {
    public let codingPath: CodingPath
    public let state: State<T>

    public subscript<U>(dynamicMember keyPath: KeyPath<T, U>) -> U {
        get throws {
            try state.value[keyPath: keyPath]
        }
    }

    public subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>>) -> Decoded<U> {
        get throws {
            try state.value[keyPath: keyPath]
        }
    }

    public subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>>) -> U {
        get throws {
            try state.value[keyPath: keyPath].state.value
        }
    }
}

extension Decoded: Equatable where T: Equatable {}
