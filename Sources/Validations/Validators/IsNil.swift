import Decoded

public struct IsNil<T>: ValidatorExpressible {
    public enum Error: Swift.Error {
        case hasValue, isAbsent

        init?<U>(_ result: DecodingResult<U>) {
            switch result.success {
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
        self.validator = .init(keyPath) { Error($0.result) }
    }
}
