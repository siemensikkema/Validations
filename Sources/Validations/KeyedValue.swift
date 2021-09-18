import Decoded

public typealias KeyedValue<T> = (codingPath: CodingPath, value: T)

extension Decoded {
    var keyedValue: KeyedValue<T>? {
        value.map { KeyedValue(codingPath: codingPath, value: $0) }
    }
}
