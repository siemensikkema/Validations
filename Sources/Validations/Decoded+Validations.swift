import Decoded

public extension Decoded {
    func validated() throws -> Validated<T> {
        try validated(mergingFailures: nil)
    }

    func validated<V>(by validators: V ...) throws -> Validated<T> where V: ValidatorExpressible, V.T == T {
        try validated(mergingFailures: Validator(validators)(self))
    }

    func validated(@ValidatorBuilder<T> buildValidator: () -> Validator<T>) throws -> Validated<T> {
        try validated(by: buildValidator())
    }
}
