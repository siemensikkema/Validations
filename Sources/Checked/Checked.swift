import Decoded

@dynamicMemberLookup
public struct Checked<T> {
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

public extension Checked {
    private var value: T {
        decodingSuccess.value
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, U>) -> U {
        value[keyPath: keyPath]
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, DecodingResult<U>>) -> Checked<U> {
        try! .init(value[keyPath: keyPath])
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, DecodingResult<U>>) -> U {
        try! value[keyPath: keyPath].value
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, DecodingResult<U>?>) -> Checked<U>? {
        try! value[keyPath: keyPath].map(Checked<U>.init)
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, DecodingResult<U>?>) -> U? {
        try! value[keyPath: keyPath]?.value
    }
}

public extension Checked where T: Sequence {
    func unwrapped<U>() -> [U] where T.Element == DecodingResult<U> {
        try! value.unwrapped()
    }
}

public extension Checked {
    func unwrapped<Key, Value>() -> [Key: Value] where T == [Key: DecodingResult<Value>] {
        try! value.unwrapped()
    }
}

extension Decoded {
    public func checked(mergingErrors additional: KeyedErrors? = nil) throws -> Checked<T> {
        if let keyedErrors = keyedErrors().merging(additional) {
            throw keyedErrors
        }

        return try .init(result)
    }
}

extension Checked: Decodable where T: Decodable {
    public init(from decoder: Decoder) throws {
        self = try Decoded<T>(from: decoder).checked()
    }
}
