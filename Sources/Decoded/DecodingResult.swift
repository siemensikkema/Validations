public enum DecodingResult<T> {
    case success(DecodingSuccess<T>)
    case failure(DecodingFailure)
}

public enum DecodingSuccess<T> {
    case absent
    case `nil`
    case value(T)
}

public struct DecodingFailure: CustomDebugStringConvertible, Equatable, Error, Hashable {
    public enum DecodingErrorType: Equatable, Hashable {
        case typeMismatch
        case valueNotFound
        case keyNotFound
        case dataCorrupted
    }

    public let debugDescription: String
    public let errorType: DecodingErrorType
}

extension DecodingFailure {
    init(decodingError error: DecodingError) throws {
        switch error {
        case .typeMismatch(_, let context):
            self.init(debugDescription: context.debugDescription, errorType: .typeMismatch)
        case .valueNotFound(_, let context):
            self.init(debugDescription: context.debugDescription, errorType: .valueNotFound)
        case .keyNotFound(_, let context):
            self.init(debugDescription: context.debugDescription, errorType: .keyNotFound)
        case .dataCorrupted(let context):
            self.init(debugDescription: context.debugDescription, errorType: .dataCorrupted)
        @unknown default:
            throw error
        }
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

public extension DecodingResult {
    var value: T {
        get throws {
            switch self {
            case .success(let success):
                return success.value
            case .failure(let failure):
                throw failure
            }
        }
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

extension DecodingResult: Decodable where T: Decodable {
    public init(from decoder: Decoder) throws {
        do {
            self = try .success(DecodingSuccess<T>(from: decoder))
        } catch let error as DecodingError {
            self = try .failure(.init(decodingError: error))
        }
    }
}

extension DecodingSuccess: Equatable where T: Equatable {}
extension DecodingSuccess: Hashable where T: Hashable {}
extension DecodingResult: Equatable where T: Equatable {}
extension DecodingResult: Hashable where T: Hashable {}

public extension Sequence {
    func unwrapped<T>() throws -> [T] where Element == DecodingResult<T> {
        try map { try $0.value }
    }
}

public extension Dictionary {
    func unwrapped<T>() throws -> [Key: T] where Value == DecodingResult<T> {
        try mapValues { try $0.value }
    }
}
