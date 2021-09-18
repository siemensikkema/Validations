import Decoded
enum ValidationErrors {
    struct NotEqual<U: Equatable>: ValidationError {
        let lhs, rhs: U
    }

    struct Equal<U: Equatable>: ValidationError {
        let value: U
    }
}

public protocol ValidationError: Error {}

extension DecodingFailure: ValidationError {}
