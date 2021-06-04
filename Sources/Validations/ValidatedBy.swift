import Checked
import Decoded

public struct ValidatedBy<V: ValidationSuite> {
    let checked: Checked<V.T>

    fileprivate init(validated: AnyValidated<V.T>) {
        self.checked = validated.checked
    }

    public func eraseToAnyValidated() -> AnyValidated<V.T> {
        .init(checked: checked)
    }
}

public extension Decoded {
    func validated<V: ValidationSuite>(by validationSuite: V) throws -> ValidatedBy<V> where V.T == T {
        var validations = self.validations()
        validationSuite.validations(&validations)
        return .init(validated: try validations.validated())
    }
}
