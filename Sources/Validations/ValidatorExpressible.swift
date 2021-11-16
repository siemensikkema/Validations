import Decoded

/// Types that are able to provide  a ``Validator``.
///
/// By conforming to this protocol you can define your own custom validators.
public protocol ValidatorExpressible {
    associatedtype T
    /// The ``Validator`` that the conforming type exposes.
    var validator: Validator<T> { get }
}

extension ValidatorExpressible {
    func callAsFunction(_ decoded: Decoded<T>) -> KeyedFailuresRepresentable? {
        validator.validate(decoded)
    }
}

public extension ValidatorExpressible {
    /// Produces a new ``Validator`` by combining `self` with another validator using "and" logic.
    ///
    /// The resulting validator fails if either of the validators fail. Failures from both validators are combined.
    /// - Parameter other: A ``Validator`` to combine with `self`.
    /// - Returns: A new ``Validator``.
    func and<V>(_ other: V) -> Validator<T> where V: ValidatorExpressible, V.T == T {
        .init(self.validator, other.validator)
    }

    /// Produces a new ``Validator`` by combining `self` with another validator using "or" logic.
    ///
    /// The resulting validator only fails if **both** validators fail. Failures from both validators are combined.
    /// - Parameter other: A ``Validator`` to combine with `self`.
    /// - Returns: A new ``Validator``.
    func or<V>(_ other: V) -> Validator<T> where V: ValidatorExpressible, V.T == T {
        .init { decoded -> KeyedFailuresRepresentable? in
            guard
                let lhs = validator(decoded),
                let rhs = other.validator(decoded)
            else {
                return nil
            }
            return lhs.merging(rhs)
        }
    }
}
