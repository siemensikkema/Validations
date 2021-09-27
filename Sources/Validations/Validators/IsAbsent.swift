import Decoded

public struct IsAbsent<T>: ValidatorExpressible {
    public enum Failure: ValidationFailure {
        case hasValue, isNil

        init?<U>(_ success: DecodingSuccess<U>) {
            switch success {
            case .nil:
                self = .isNil
            case .value:
                self = .hasValue
            default:
                return nil
            }
        }
    }

    public let validator: Validator<T>

    public init<U>(_ keyPath: KeyPath<T, Decoded<U>>) {
        self.validator = .init(keyPath, validate: Failure.init)
    }
}
