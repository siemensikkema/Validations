@dynamicMemberLookup
public struct Decoded<T> {
    init(codingPath: CodingPath = [], result: DecodingResult<T>) {
        self.codingPath = codingPath
        self.result = result
    }

    public let codingPath: CodingPath
    public let result: DecodingResult<T>
}

extension Decoded: Decodable where T: Decodable {
    public init(from decoder: Decoder) throws {
        codingPath = decoder.codingPath.map(AnyCodingKey.init)
        result = try .init(from: decoder)
    }
}

extension Decoded: Hashable where T: Hashable {}
extension Decoded: Equatable where T: Equatable {}

public extension KeyedDecodingContainer {
    func decode<T: Decodable>(
        _ type: Decoded<T>.Type,
        forKey key: Key
    ) throws -> Decoded<T> {
        let codingPath = (codingPath + [key]).map(AnyCodingKey.init)
        let result: DecodingResult<T>

        do {
            result = try decode(DecodingResult<T>.self, forKey: key)
        } catch let error as DecodingError {
            switch (error, T.self is ExpressibleByNilLiteral.Type) {
            case (.valueNotFound, false), (.keyNotFound, false):
                result = try .failure(.init(decodingError: error))
            case (.valueNotFound, true):
                result = .success(.nil)
            case (.keyNotFound, true):
                result = .success(.absent)
            default:
                throw error
            }
        }

        return .init(codingPath: codingPath, result: result)
    }
}

public extension Decoded {
    subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>>) -> Decoded<U> {
        flatMap(keyPath)
    }
}

public extension Decoded {
    var failure: DecodingFailure? {
        result.failure
    }

    var success: DecodingSuccess<T>? {
        result.success
    }

    var value: T? {
        result.value
    }

    var unwrapped: T {
        get throws {
            try result.unwrapped
        }
    }
}

public extension Decoded {
    func flatMap<U>(_ keyPath: KeyPath<T, Decoded<U>>) -> Decoded<U> {
        switch result {
        case .failure(let failure):
            return .init(codingPath: codingPath, result: .failure(failure))
        case .success(let success):
            return success.value[keyPath: keyPath]
        }
    }
}
