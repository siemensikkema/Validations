import Decoded

public extension Decoded {
    func validated(by validator: Validator<T>) throws -> Validated<T> {
        try validated(mergingFailures: validator(self))
    }

    func validated(@ValidatorBuilder<T> buildValidator: () -> Validator<T>) throws -> Validated<T> {
        try validated(by: buildValidator())
    }
}
