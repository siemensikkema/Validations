import Decoded

public protocol ValidatorExpressible {
    associatedtype T
    var validator: Validator<T> { get }
}

extension ValidatorExpressible {
    func callAsFunction(_ decoded: Decoded<T>) -> KeyedErrorsRepresentable? {
        validator.validate(decoded)
    }
}

public extension ValidatorExpressible {
    func or(@ValidatorBuilder<T> buildValidator: @escaping () -> Validator<T>) -> Validator<T> {
        .init { decoded -> KeyedErrorsRepresentable? in
            guard
                let lhs = validator(decoded),
                let rhs = buildValidator()(decoded)
            else {
                return nil
            }
            return lhs.merging(rhs)
        }
    }
}

