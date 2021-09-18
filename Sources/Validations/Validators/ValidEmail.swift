import Decoded

public struct ValidEmail<T>: ValidatorExpressible {
    public struct Error: Swift.Error {
        init?(email: String) {
            guard email.contains("@") else {
                return nil
            }
        }
    }

    public let validator: Validator<T>

    public init(_ keyPath: KeyPath<T, Decoded<String>>) {
        self.validator = .init(keyPath, validate: Error.init)
    }
}
