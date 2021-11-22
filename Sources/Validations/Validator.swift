import Decoded

/// Able to validate a `Decoded<T>` value.
///
/// As the basic building block for Validations, ``Validator`` values can be composed with others to form arbitrarily complex validators.
public struct Validator<T> {
    typealias Validate = (Decoded<T>) -> KeyedFailuresRepresentable?

    let validate: Validate

    init(validate: @escaping Validate) {
        self.validate = validate
    }

    /// A ``Validator`` that always succeeds.
    public static var empty: Self {
        .init { (_: Decoded<T>) in nil }
    }
}

// MARK: - Initializers

// MARK: ValidatorBuilder

public extension Validator {
    /// Creates a new ``Validator`` using a result builder closure.
    init(@ValidatorBuilder<T> buildValidator: @escaping () -> Self) {
        self = buildValidator()
    }
}

// MARK: Combining Validators

public extension Validator {
    /// Creates a new ``Validator`` from others with the combined validation output.
    init<V>(_ validators: [V]) where V: ValidatorExpressible, V.T == T {
        self.init { decoded in
            validators.reduce(into: nil) { (partialResult: inout KeyedFailures?, validator) in
                partialResult.merge(validator(decoded))
            }
        }
    }

    /// Creates a new ``Validator`` from others with the combined validation output.
    init<V>(_ validators: V ...) where V: ValidatorExpressible, V.T == T {
        self.init(validators)
    }
}

// MARK: Top-level Validators
public extension Validator {
    /// Creates a new ``Validator`` for a successfully decoded value.
    init(validate: @escaping (KeyedSuccess<T>) -> ValidationFailure?) {
        self.init(pathToSuccess: \.keyedSuccess) { _, success in validate(success) }
    }

    /// Creates a new ``Validator`` for a successfully decoded value.
    init(validate: @escaping (T) -> ValidationFailure?) {
        self.init { success in
            validate(success.value)
        }
    }
}

// MARK: Single-field Validators
public extension Validator {
    /// Creates a new ``Validator`` for a successfully decoded field.
    init<U>(
        _ keyPath: KeyPath<T, Decoded<U>>,
        validate: @escaping (KeyedSuccess<U>) -> ValidationFailure?
    ) {
        self.init { decoded in
            decoded.flatMap(keyPath).keyedSuccess
        } validate: { _, success in
            validate(success)
        }
    }

    /// Creates a new ``Validator`` for a successfully decoded field.
    init<U>(
        _ keyPath: KeyPath<T, Decoded<U>>,
        validate: @escaping (U) -> ValidationFailure?
    ) {
        self.init(keyPath) { success in
            validate(success.value)
        }
    }
}

// MARK: Two-field Validators
public extension Validator {
    /// Creates a new ``Validator`` for two successfully decoded fields.
    init<U, V>(
        _ keyPath1: KeyPath<T, Decoded<U>>,
        _ keyPath2: KeyPath<T, Decoded<V>>,
        validate: @escaping (KeyedSuccess<U>, KeyedSuccess<V>) -> ValidationFailure?
    ) {
        self.init { decoded in
            decoded.keyedSuccess.flatMap { $0.value[keyPath: keyPath1].keyedSuccess }
        } validate: { decoded1, success1 -> ValidationFailure? in
            decoded1
                .flatMap(keyPath2)
                .keyedSuccess
                .flatMap { success2 in
                    validate(success1, success2)
                }
        }
    }

    /// Creates a new ``Validator`` for two successfully decoded fields.
    init<U, V>(
        _ keyPath1: KeyPath<T, Decoded<U>>,
        _ keyPath2: KeyPath<T, Decoded<V>>,
        validate: @escaping (U, V) -> ValidationFailure?
    ) {
        self.init(keyPath1, keyPath2) { success1, success2 in
            validate(success1.value, success2.value)
        }
    }
}

// MARK: Value inspecting Validators
public extension Validator {
    /// Creates a new ``Validator`` based on the value of a successfully decoded field.
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

    /// Creates a new ``Validator`` based on the value of a successfully decoded field.
    init<U>(
        withValueAt keyPath: KeyPath<T, Decoded<U>>,
        @ValidatorBuilder<T> buildValidator: @escaping (U) -> Self
    ) {
        self.init(withValueAt: keyPath, buildValidator: {
            buildValidator($0.value)
        })
    }
}

// MARK: Nested Validators
public extension Validator {
    /// Creates a new ``Validator`` nested at a field.
    init<U>(
        nestedAt keyPath: KeyPath<T, Decoded<U>>,
        validator: Validator<U>
    ) {
        self.init { (decoded: Decoded<T>) in
            let nested = decoded.flatMap(keyPath)

            guard nested.result.success != nil else { return nil }

            return validator(nested)
        }
    }

    /// Creates a new ``Validator`` nested at a field.
    init<U>(
        nestedAt keyPath: KeyPath<T, Decoded<U>>,
        @ValidatorBuilder<U> buildValidator: @escaping () -> Validator<U>
    ) {
        self.init(nestedAt: keyPath, validator: buildValidator())
    }

    /// Creates a new ``Validator`` nested at a field that always fails with the provided failure.
    init<U>(
        nestedAt keyPath: KeyPath<T, Decoded<U>>,
        failure: ValidationFailure
    ) {
        self.init(keyPath) { (_: KeyedSuccess<U>) in failure }
    }
}

// MARK: - ValidatorExpressible

extension Validator: ValidatorExpressible {
    public var validator: Self { self }
}

public extension ValidatorExpressible {
    /// Map any failure resulting from the validation to a new ``ValidationFailure``.
    ///
    /// - Parameter transform: Function that transforms a ``ValidationFailure``.
    /// - Returns: A new ``Validator``.
    func mapFailures(_ transform: @escaping (ValidationFailure) -> ValidationFailure) -> Validator<T> {
        .init { decoded in
            validator(decoded)?.keyedFailures?.mapFailures(transform)
        }
    }
}

// MARK: - Private

private extension Validator {
    init<U>(
        pathToSuccess: @escaping (Decoded<T>) -> KeyedSuccess<U>?,
        validate: @escaping (Decoded<T>, KeyedSuccess<U>) -> ValidationFailure?
    ) {
        self.init { decoded in
            pathToSuccess(decoded).flatMap { success in
                validate(decoded, success).map {
                    KeyedFailure(codingPath: success.codingPath, failure: $0)
                }
            }
        }
    }
}
