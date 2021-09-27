import Decoded

public struct Validator<T> {
    typealias Validate = (Decoded<T>) -> KeyedFailuresRepresentable?

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
            validators.reduce(into: nil) { (partialResult: inout KeyedFailures?, validator) in
                partialResult.merge(validator(decoded))
            }
        }
    }
}

public extension ValidatorExpressible {
    func mapFailures(_ transform: @escaping (ValidationFailure) -> ValidationFailure) -> Validator<T> {
        .init { decoded in
            validator(decoded)?.keyedFailures?.mapFailures(transform)
        }
    }
}

public extension Validator {
    init<U>(
        _ keyPath: KeyPath<T, Decoded<U>>,
        validate: @escaping (KeyedSuccess<U>) -> ValidationFailure?
    ) {
        self.init { decoded in
            decoded
                .flatMap(keyPath)
                .keyedSuccess
                .flatMap { success in
                    validate(success).map {
                        KeyedFailure(codingPath: success.codingPath, failure: $0)
                    }
                }
        }
    }

    init<U>(
        _ keyPath: KeyPath<T, Decoded<U>>,
        validate: @escaping (U) -> ValidationFailure?
    ) {
        self.init(keyPath) { success in
            validate(success.value)
        }
    }

    init<U>(
        _ keyPath1: KeyPath<T, Decoded<U>>,
        _ keyPath2: KeyPath<T, Decoded<U>>,
        validate: @escaping (KeyedSuccess<U>, KeyedSuccess<U>) -> ValidationFailure?
    ) {
        self.init { decoded in
            decoded.value.flatMap {
                guard
                    let lhs = $0[keyPath: keyPath1].keyedSuccess,
                    let rhs = $0[keyPath: keyPath2].keyedSuccess
                else {
                    return nil
                }
                return validate(lhs, rhs).flatMap {
                    KeyedFailure(codingPath: lhs.codingPath, failure: $0)
                }
            }
        }
    }

    init<U>(
        withValueAt keyPath: KeyPath<T, Decoded<U>>,
        @ValidatorBuilder<T> buildValidator: @escaping (KeyedSuccess<U>) -> Self
    ) {
        self.init { decoded in
            decoded
                .flatMap(keyPath)
                .keyedSuccess
                .flatMap(buildValidator)?(decoded)
        }
    }

    init<U>(
        withValueAt keyPath: KeyPath<T, Decoded<U>>,
        @ValidatorBuilder<T> buildValidator: @escaping (U) -> Self
    ) {
        self.init(withValueAt: keyPath, buildValidator: {
            buildValidator($0.value)
        })
    }

    init<U>(
        nestedAt keyPath: KeyPath<T, Decoded<U>>,
        @ValidatorBuilder<U> buildValidator: @escaping () -> Validator<U>
    ) {
        self.init { decoded in
            let nested = decoded.flatMap(keyPath)

            guard nested.success != nil else { return nil }

            return buildValidator().validate(nested)
        }
    }
}

extension Validator: ValidatorExpressible {
    public var validator: Self { self }
}
