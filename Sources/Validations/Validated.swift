import Decoded

@dynamicMemberLookup
public struct Validated<T> {
    let decodingSuccess: DecodingSuccess<T>

    fileprivate init(_ result: DecodingResult<T>) throws {
        switch result {
        case .success(let success):
            self.decodingSuccess = success
        case .failure(let failure):
            throw failure
        }
    }
}

public extension Validated {
    private var value: T {
        decodingSuccess.value
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, U>) -> U {
        value[keyPath: keyPath]
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, DecodingResult<U>>) -> Validated<U> {
        try! .init(value[keyPath: keyPath])
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, DecodingResult<U>>) -> U {
        value[keyPath: keyPath].value!
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, DecodingResult<U>?>) -> Validated<U>? {
        try! value[keyPath: keyPath].map(Validated<U>.init)
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, DecodingResult<U>?>) -> U? {
        value[keyPath: keyPath]?.value!
    }
}

public extension Validated where T: Sequence {
    func unwrapped<U>() -> [U] where T.Element == DecodingResult<U> {
        try! value.unwrapped()
    }
}

public extension Validated {
    func unwrapped<Key, Value>() -> [Key: Value] where T == [Key: DecodingResult<Value>] {
        try! value.unwrapped()
    }
}

public extension Decoded {
    func validated(mergingErrors additional: KeyedErrorsRepresentable? = nil) throws -> Validated<T> {
        if let keyedErrors = keyedErrors.merging(additional?.keyedErrors) {
            throw keyedErrors
        }

        return try .init(result)
    }
}

extension Validated: Decodable where T: Decodable {
    public init(from decoder: Decoder) throws {
        self = try Decoded<T>(from: decoder).validated()
    }
}
