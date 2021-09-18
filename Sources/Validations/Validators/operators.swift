import Decoded

public func == <T, U: Equatable>(keyPath: KeyPath<T, Decoded<U>>, rhs: U) -> IsEqual<T> {
    .init(keyPath, rhs)
}

public func != <T, U: Equatable>(keyPath: KeyPath<T, Decoded<U>>, rhs: U) -> IsNotEqual<T> {
    .init(keyPath, rhs)
}

public func == <T, U: Equatable>(keyPath1: KeyPath<T, Decoded<U>>, keyPath2: KeyPath<T, Decoded<U>>) -> IsEqual<T> {
    .init(keyPath1, keyPath2)
}

public func != <T, U: Equatable>(keyPath1: KeyPath<T, Decoded<U>>, keyPath2: KeyPath<T, Decoded<U>>) -> IsNotEqual<T> {
    .init(keyPath1, keyPath2)
}
