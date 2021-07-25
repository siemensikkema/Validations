public extension Decoded {
    enum State {
        case absent
        case `nil`
        case value(T)
        case typeMismatch(String)
    }
}

extension Decoded.State: Equatable where T: Equatable {}

public extension Decoded.State {
    subscript<U>(dynamicMember keyPath: KeyPath<T, U>) -> U {
        get throws {
            try value[keyPath: keyPath]
        }
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>.State>) -> Decoded<U>.State {
        get throws {
            try value[keyPath: keyPath]
        }
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>.State>) -> U {
        get throws {
            try value[keyPath: keyPath].value
        }
    }

    var value: T {
        get throws {
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
}
