public extension Decoded {
    enum State {
        case absent
        case `nil`
        case value(T)
        case dataCorrupted(debugDescription: String)
        case typeMismatch(debugDescription: String)
    }
}

public extension Decoded.State {
    var value: T {
        get throws {
            switch self {
            case .value(let value):
                return value
            case .absent:
                guard let value = _valueAsNil else {
                    throw Absent()
                }
                return value
            case .nil:
                guard let value = _valueAsNil else {
                    throw Nil()
                }
                return value
            case .dataCorrupted(let debugDescription):
                throw DataCorrupted(debugDescription: debugDescription)
            case .typeMismatch(let debugDescription):
                throw TypeMismatch(debugDescription: debugDescription)
            }
        }
    }

    private var _valueAsNil: T? {
        (T.self as? ExpressibleByNilLiteral.Type)?.init(nilLiteral: ()) as? T
    }
}

public extension Decoded.State {
    struct Nil: Error {}
    struct Absent: Error {}
    struct TypeMismatch: Error, CustomDebugStringConvertible {
        public let debugDescription: String
    }
    struct DataCorrupted: Error, CustomDebugStringConvertible {
        public let debugDescription: String
    }
}

extension Decoded.State: Decodable where T: Decodable {
    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            self = try container.decodeNil() ? .nil : .value(container.decode(T.self))
        } catch let DecodingError.dataCorrupted(context) {
            self = .dataCorrupted(debugDescription: context.debugDescription)
        } catch let DecodingError.typeMismatch(_, context) {
            self = .typeMismatch(debugDescription: context.debugDescription)
        }
    }
}

extension Decoded.State: Equatable where T: Equatable {}
extension Decoded.State: Hashable where T: Hashable {}

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

    subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>.State?>) -> Decoded<U>.State? {
        get throws {
            try value[keyPath: keyPath]
        }
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>.State?>) -> U? {
        get throws {
            try value[keyPath: keyPath]?.value
        }
    }
}

public extension Sequence {
    func unwrapped<T>() throws -> [T] where Element == Decoded<T>.State {
        try map { try $0.value }
    }
}

public extension Dictionary {
    func unwrapped<T>() throws -> [Key: T] where Value == Decoded<T>.State {
        try mapValues { try $0.value }
    }
}
