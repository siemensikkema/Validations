public enum DecodingResult<T> {
    case success(DecodingSuccess<T>)
    case failure(DecodingFailure)
}

public extension DecodingResult {
    var isAbsent: Bool {
        guard case .success(let success) = self, success.isAbsent else {
            return false
        }
        return true
    }

    var isNil: Bool {
        guard case .success(let success) = self, success.isNil else {
            return false
        }
        return true
    }

    var hasValue: Bool {
        guard case .success(let success) = self, success.hasValue else {
            return false
        }
        return true
    }
}

public extension DecodingResult {
    var value: T? {
        try? unwrapped
    }

    var unwrapped: T {
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

extension DecodingResult: Decodable where T: Decodable {
    public init(from decoder: Decoder) throws {
        do {
            self = try .success(DecodingSuccess<T>(from: decoder))
        } catch let error as DecodingError {
            self = try .failure(.init(decodingError: error))
        }
    }
}

extension DecodingResult: Equatable where T: Equatable {}
extension DecodingResult: Hashable where T: Hashable {}

public extension Sequence {
    func unwrapped<T>() throws -> [T] where Element == DecodingResult<T> {
        try map { try $0.unwrapped }
    }
}

public extension Dictionary {
    func unwrapped<T>() throws -> [Key: T] where Value == DecodingResult<T> {
        try mapValues { try $0.unwrapped }
    }
}
