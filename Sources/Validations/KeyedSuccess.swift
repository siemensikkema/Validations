import Decoded

/// The result of a successful decoding attempt together with its `CodingPath`.
public struct KeyedSuccess<T> {
    public let codingPath: CodingPath
    public let success: DecodingSuccess<T>
}

extension KeyedSuccess {
    var value: T {
        success.value
    }
}

extension Decoded {
    var keyedSuccess: KeyedSuccess<T>? {
        success.map { KeyedSuccess(codingPath: codingPath, success: $0) }
    }
}
