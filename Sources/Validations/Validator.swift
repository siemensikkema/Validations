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
        validate: @escaping (DecodingSuccess<U>) -> Error?
    ) {
        self.init { decoded in
            decoded
                .flatMap(keyPath)
                .success
                .flatMap(validate)
                .map {
                    KeyedError(codingPath: decoded.codingPath, error: $0)
                }
        }
    }

    init<U>(
        _ keyPath: KeyPath<T, Decoded<U>>,
        validate: @escaping (U) -> Error?
    ) {
        self.init(keyPath) { success in
            validate(success.value)
        }
    }

    init<U>(
        _ keyPath1: KeyPath<T, Decoded<U>>,
        _ keyPath2: KeyPath<T, Decoded<U>>,
        validate: @escaping (KeyedSuccess<U>, KeyedSuccess<U>) -> Error?
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
                    KeyedError(codingPath: lhs.codingPath, error: $0)
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
