import Decoded

public struct Validator<T> {
    typealias Validate = (Decoded<T>) -> KeyedErrorsRepresentable?

    let validate: Validate

    init(validate: @escaping Validate) {
        self.validate = validate
    }
}

public extension Validator {
    init(@ValidatorBuilder<T> buildValidator: @escaping () -> Self) {
        self = buildValidator()
    }
}

public extension Validator {
    init<V>(_ validators: [V]) where V: ValidatorExpressible, V.T == T {
        self.init { decoded in
            validators.reduce(into: nil) { (partialResult: inout KeyedErrors?, validator) in
                partialResult.merge(validator(decoded))
            }
        }
    }
}

public extension ValidatorExpressible {
    func mapErrors(_ transform: @escaping (Error) -> Error) -> Validator<T> {
        .init { decoded in
            validator(decoded)?.keyedErrors?.mapErrors(transform)
        }
    }
}

public extension Validator {
    init<U>(
        _ keyPath: KeyPath<T, Decoded<U>>,
        validate: @escaping (Decoded<U>) -> Error?
    ) {
        self.init { decoded in
            decoded.map(keyPath).flatMap { decoded in
                validate(decoded).map {
                    KeyedError(codingPath: decoded.codingPath, error: $0)
                }
            }
        }
    }

    init<U>(
        _ keyPath: KeyPath<T, Decoded<U>>,
        validate: @escaping (U) -> Error?
    ) {
        self.init(keyPath) { decoded in
            decoded.map(validate).flatMap { $0 }
        }
    }

    init<U>(
        _ keyPath: KeyPath<T, Decoded<U>>,
        validate: @escaping (KeyedValue<U>) -> Error?
    ) {
        self.init(keyPath) { decoded in
            decoded.map(validate).flatMap { $0 }
        }
    }

    init<U>(
        _ keyPath: KeyPath<T, Decoded<U>>,
        value: @escaping @autoclosure () -> U,
        validate: @escaping (KeyedValue<U>, U) -> Error?
    ) {
        self.init(keyPath) { decoded in
            decoded.map { validate($0, value()) }.flatMap { $0 }
        }
    }

    init<U>(
        _ keyPath: KeyPath<T, Decoded<U>>,
        value: @escaping @autoclosure () -> U,
        validate: @escaping (U, U) -> Error?
    ) {
        self.init(keyPath) { decoded in
            decoded.map { validate($0, value()) }.flatMap { $0 }
        }
    }

    init<U>(
        _ keyPath1: KeyPath<T, Decoded<U>>,
        _ keyPath2: KeyPath<T, Decoded<U>>,
        validate: @escaping (U, U) -> Error?
    ) {
        self.init { decoded in
            decoded.flatZip(keyPath1, keyPath2).flatMap { lhs, rhs in
                validate(lhs.value, rhs.value).flatMap {
                    KeyedError(codingPath: lhs.codingPath, error: $0)
                }
            }
        }
    }

    init<U>(
        _ keyPath1: KeyPath<T, Decoded<U>>,
        _ keyPath2: KeyPath<T, Decoded<U>>,
        validate: @escaping (KeyedValue<U>, KeyedValue<U>) -> Error?
    ) {
        self.init { decoded in
            decoded.flatZip(keyPath1, keyPath2).flatMap { lhs, rhs in
                validate(lhs, rhs).flatMap {
                    KeyedError(codingPath: lhs.codingPath, error: $0)
                }
            }
        }
    }

    init<U>(
        withValueAt keyPath: KeyPath<T, Decoded<U>>,
        @ValidatorBuilder<T> buildValidator: @escaping (KeyedValue<U>) -> Self
    ) {
        self.init { decoded in
            decoded
                .flatMap(keyPath)
                .flatMap(buildValidator)?(decoded)
        }
    }

    init<U>(
        withValueAt keyPath: KeyPath<T, Decoded<U>>,
        @ValidatorBuilder<T> buildValidator: @escaping (U) -> Self
    ) {
        self.init { decoded in
            decoded
                .flatMap(keyPath)
                .flatMap {
                    buildValidator($0.value)(decoded)
                }
        }
    }

    init<U>(
        nestedAt keyPath: KeyPath<T, Decoded<U>>,
        @ValidatorBuilder<U> buildValidator: @escaping () -> Validator<U>
    ) {
        self.init { decoded in
            decoded
                .map(keyPath)
                .flatMap(buildValidator().validate)
        }
    }
}

extension Validator: ValidatorExpressible {
    public var validator: Self { self }
}
