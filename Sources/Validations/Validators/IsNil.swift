import Decoded

public struct IsNil<T>: ValidatorExpressible {
    struct Error: ValidationError {}

    public let validator: Validator<T>

    public init<U>(_ keyPath: KeyPath<T, Decoded<U>>) {
        self.validator = .init(keyPath) { decoded in
            decoded.result.isNil ? nil : Error()
        }
    }
}
