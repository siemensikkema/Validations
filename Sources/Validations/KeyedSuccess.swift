import Decoded

public struct KeyedSuccess<T> {
    let codingPath: CodingPath
    let success: DecodingSuccess<T>
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
