import Decoded

public struct KeyedValue<T> {
    let codingPath: CodingPath
    let success: DecodingSuccess<T>
}

extension KeyedValue {
    var value: T {
        success.value
    }
}

extension Decoded {
    var keyedValue: KeyedValue<T>? {
        result.success.map { KeyedValue(codingPath: codingPath, success: $0) }
    }
}
