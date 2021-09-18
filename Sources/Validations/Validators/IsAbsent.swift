import Decoded

public struct IsAbsent<T>: ValidatorExpressible {
    struct Error: Swift.Error {}

    public let validator: Validator<T>

    public init<U>(_ keyPath: KeyPath<T, Decoded<U>>) {
        self.validator = .init(keyPath) { decoded in
            decoded.result.isAbsent ? nil : Error()
        }
    }
}
