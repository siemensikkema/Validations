import Decoded

public struct ValidEmail<T>: ValidatorExpressible {
    public let validator: Validator<T>

    public init(_ keyPath: KeyPath<T, Decoded<String>>) {
        self.validator = .init(keyPath) { email in
            email.contains("@") ? nil : ValidationErrors.InvalidEmail()
        }
    }
}

extension ValidationErrors {
    struct InvalidEmail: ValidationError {}
}
