public enum DecodingSuccess<T> {
    case absent
    case `nil`
    case value(T)
}

public extension DecodingSuccess {
    var isAbsent: Bool {
        guard case .absent = self else {
            return false
        }
        return true
    }

    var isNil: Bool {
        guard case .nil = self else {
            return false
        }
        return true
    }

    var hasValue: Bool {
        guard case .value = self else {
            return false
        }
        return true
    }
}

public extension DecodingSuccess {
    var value: T {
        switch self {
        case .absent, .nil:
            return _valueAsNil!
        case .value(let value):
            return value
        }
    }

    private var _valueAsNil: T? {
        (T.self as? ExpressibleByNilLiteral.Type)?.init(nilLiteral: ()) as? T
    }
}

extension DecodingSuccess: Decodable where T: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil(), T.self is ExpressibleByNilLiteral.Type {
            self = .nil
        } else {
            self = .value(try container.decode(T.self))
        }
    }
}

extension DecodingSuccess: Equatable where T: Equatable {}
extension DecodingSuccess: Hashable where T: Hashable {}
