@resultBuilder
public struct ValidatorBuilder<T> {
    public static func buildBlock<V>(_ validators: V...) -> Validator<T>
        where V: ValidatorExpressible, V.T == T
    {
        .init(validators)
    }

    public static func buildOptional<V>(_ validator: V?) -> Validator<T>
        where V: ValidatorExpressible, V.T == T
    {
        .init { decoded in
            validator?(decoded)
        }
    }

    public static func buildEither<V>(first validator: V) -> Validator<T>
        where V: ValidatorExpressible, V.T == T
    {
        validator.validator
    }

    public static func buildEither<V>(second validator: V) -> Validator<T>
        where V: ValidatorExpressible, V.T == T
    {
        validator.validator
    }

    public static func buildExpression(_ validator: Validator<T>) -> Validator<T> {
        validator
    }

    public static func buildExpression<V>(_ validator: V) -> Validator<T>
        where V: ValidatorExpressible, V.T == T
    {
        validator.validator
    }

    public static func buildExpression(_ expression: KeyedError) -> Validator<T> {
        .init { _ in expression.keyedErrors }
    }

    public static func buildLimitedAvailability<V>(_ validator: V) -> Validator<T>
        where V: ValidatorExpressible, V.T == T
    {
        validator.validator
    }

    public static func buildArray<V>(_ validators: [V]) -> Validator<T>
        where V: ValidatorExpressible, V.T == T
    {
        .init(validators)
    }
}
