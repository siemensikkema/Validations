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

public func ~= <T, R: RangeExpression>(keyPath1: KeyPath<T, Decoded<R.Bound>>, range: R) -> InRange<T> {
    .init(keyPath1, range)
}

public func < <T, U: Comparable & AdditiveArithmetic>(keyPath1: KeyPath<T, Decoded<U>>, upperBound: U) -> InRange<T> {
    keyPath1 ~= ..<upperBound
}

public func > <T, U: Comparable & AdditiveArithmetic>(keyPath1: KeyPath<T, Decoded<U>>, lowerBound: U) -> InRange<T> {
    keyPath1 ~= PartialRangeAfter(lowerBound)
}

public func <= <T, U: Comparable & AdditiveArithmetic>(keyPath1: KeyPath<T, Decoded<U>>, upperBound: U) -> InRange<T> {
    keyPath1 ~= ...upperBound
}

public func >= <T, U: Comparable & AdditiveArithmetic>(keyPath1: KeyPath<T, Decoded<U>>, lowerBound: U) -> InRange<T> {
    keyPath1 ~= lowerBound...
}
