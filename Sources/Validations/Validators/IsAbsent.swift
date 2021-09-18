import Decoded

public struct IsAbsent<T>: ValidatorExpressible {
    public enum Error: Swift.Error {
        case hasValue, isNil

        init?<U>(_ result: DecodingResult<U>) {
            switch result.success {
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
        self.validator = .init(keyPath) { Error($0.result) }
    }
}
