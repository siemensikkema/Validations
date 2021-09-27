import Decoded

public struct ValidEmail<T>: ValidatorExpressible {
    public struct Failure: ValidationFailure {
        init?(email: String) {
            // FIXME: this is a proof of concept implementation
            guard email.contains("@") else {
                return nil
            }
        }
    }

    public let validator: Validator<T>

    public init(_ keyPath: KeyPath<T, Decoded<String>>) {
        self.validator = .init(keyPath, validate: Failure.init)
    }
}
