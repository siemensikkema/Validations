@propertyWrapper
public struct Decoded<T> {
    public init(codingPath: CodingPath = [], result: DecodingResult<T> = .success(.absent)) {
        self.codingPath = codingPath
        self.result = result
    }

    public var projectedValue: Self { self }
    public var wrappedValue: DecodingResult<T> { result }

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
    func map<U>(_ f: (T) -> U) -> U? {
        value.map(f)
    }

    func map<U>(_ keyPath: KeyPath<T, U>) -> U? {
        map { $0[keyPath: keyPath] }
    }

    func flatMap<U>(_ f: (T) -> Decoded<U>) -> U? {
        value.map(f).flatMap { decoded in
            decoded.success?.value
        }
    }

    func flatMap<U>(_ keyPath: KeyPath<T, Decoded<U>>) -> U? {
        flatMap { $0[keyPath: keyPath] }
    }

    func zip<U1, U2>(_ f1: (T) -> U1, _ f2: (T) -> U2) -> (U1, U2)? {
        map(f1).flatMap { u1 in
            map(f2).map { u2 in
                (u1, u2)
            }
        }
    }

    func zip<U1, U2>(_ keyPath1: KeyPath<T, U1>, _ keyPath2: KeyPath<T, U2>) -> (U1, U2)? {
        zip({ $0[keyPath: keyPath1] }, { $0[keyPath: keyPath2] })
    }

    func flatZip<U1, U2>(_ f1: (T) -> Decoded<U1>, _ f2: (T) -> Decoded<U2>) -> (U1, U2)? {
        flatMap(f1).flatMap { u1 in
            flatMap(f2).map { u2 in
                (u1, u2)
            }
        }
    }

    func flatZip<U1, U2>(_ keyPath1: KeyPath<T, Decoded<U1>>, _ keyPath2: KeyPath<T, Decoded<U2>>) -> (U1, U2)? {
        flatMap(keyPath1).flatMap { u1 in
            flatMap(keyPath2).map { u2 in
                (u1, u2)
            }
        }
    }
}
