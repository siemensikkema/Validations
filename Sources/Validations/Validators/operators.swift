import Decoded

public func == <T, U: Equatable>(keyPath: KeyPath<T, Decoded<U>>, rhs: U) -> Validator<T> {
    .init(keyPath) { $0 == rhs ? nil : ValidationErrors.NotEqual(lhs: $0, rhs: rhs) }
}

public func != <T, U: Equatable>(keyPath: KeyPath<T, Decoded<U>>, rhs: U) -> Validator<T> {
    .init(keyPath) { $0 != rhs ? nil : ValidationErrors.Equal(value: $0) }
}

public func == <T, U: Equatable>(keyPath1: KeyPath<T, Decoded<U>>, keyPath2: KeyPath<T, Decoded<U>>) -> Validator<T> {
    .init(keyPath1, keyPath2) { $0 == $1 ? nil : ValidationErrors.NotEqual(lhs: $0, rhs: $1) }
}

public func != <T, U: Equatable>(keyPath1: KeyPath<T, Decoded<U>>, keyPath2: KeyPath<T, Decoded<U>>) -> Validator<T> {
    .init(keyPath1, keyPath2) { $0 != $1 ? nil : ValidationErrors.Equal(value: $0) }
}
