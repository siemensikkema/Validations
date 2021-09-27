import Decoded

public struct IsNil<T>: ValidatorExpressible {
    public enum Error: Swift.Error {
        case hasValue, isAbsent

        init?<U>(_ success: DecodingSuccess<U>) {
            switch success {
            case .absent:
                self = .isAbsent
            case .value:
                self = .hasValue
            default:
                return nil
            }
        }
    }

    public let validator: Validator<T>

    public init<U>(_ keyPath: KeyPath<T, Decoded<U>>) {
        self.validator = .init(keyPath, validate: Error.init)
    }
}
