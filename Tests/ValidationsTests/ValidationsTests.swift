import Validations
import Decoded
import XCTest

struct User: Decodable {
    @Decoded<String> var email
    @Decoded<String> var name
}

struct BasicValidationError: Error {
    let reason: String
}

struct Validator<T> {
    let validate: (Decoded<T>) -> KeyedErrors?

    func callAsFunction(_ decoded: Decoded<T>) -> KeyedErrors? {
        validate(decoded)
    }
}

//typealias Validator<T> = (Decoded<T>) -> KeyedErrors?

//protocol ValidationsSuite {
//    associatedtype T
//
//    func validator(_ decoded: Decoded<T>) -> Validator<T>
//}
//
//struct UserValidations: ValidationsSuite {
//    func validator(_ decoded: Decoded<T>) -> Validator<T> {
//
//    }
//
//    var validator: Validator<User> {
//        \.name == "a"
//        \.email == "b"
//    }
//}

@resultBuilder
struct ValidatorBuilder<T> {
    static func buildBlock(_ validators: Validator<T>...) -> Validator<T> {
        .init { decoded in
            validators.reduce(nil) { partialResult, validator in
                partialResult.merging(validator(decoded))
            }
        }
    }

    static func buildOptional(_ validator: Validator<T>?) -> Validator<T> {
        .init { decoded in
            validator?(decoded)
        }
    }

    static func buildEither(first validator: Validator<T>) -> Validator<T> {
        validator
    }

    static func buildEither(second validator: Validator<T>) -> Validator<T> {
        validator
    }

    static func buildExpression(_ validator: Validator<T>) -> Validator<T> {
        validator
    }

    static func buildLimitedAvailability(_ validator: Validator<T>) -> Validator<T> {
        validator
    }

    static func buildArray(_ validators: [Validator<T>]) -> Validator<T> {
        .init { decoded in
            validators.reduce(nil) { partialResult, validator in
                partialResult.merging(validator(decoded))
            }
        }
    }

    static func buildExpression(_ keyPath: KeyPath<T, Bool>) -> Validator<T> {
        .init { decoded in
            guard
                let decodedRootValue = try? decoded.result.value
            else {
                return nil
            }

            let decodedValue = decodedRootValue[keyPath: keyPath]
            guard decodedValue else {
                return KeyedErrors(codingPath: decoded.codingPath, error: BasicValidationError(reason: "not true"))
            }
            return nil
        }
    }

    static func buildExpression(_ error: Error) -> Validator<T> {
        .init { decoded in
            KeyedErrors(codingPath: decoded.codingPath, error: error)
        }
    }
}

func == <T, U: Equatable>(keyPath: KeyPath<T, Decoded<U>>, value: U) -> Validator<T> {
    .init { decoded in

        guard
            let decodedRootValue = try? decoded.result.value
        else {
            return nil
        }

        let decodedValue = decodedRootValue[keyPath: keyPath]

        guard
            (try? decodedValue.result.value) != value
        else {
            return nil
        }

        return KeyedErrors(codingPath: decodedValue.codingPath, error: BasicValidationError(reason: "not equal"))
    }
}

import Checked

extension Decoded {
    func validated(_ validator: Validator<T>) throws -> Checked<T> {
        try checked(mergingErrors: validator(self))
    }

    func validated(@ValidatorBuilder<T> makeValidator: () -> Validator<T>) throws -> Checked<T> {
        try validated(makeValidator())
    }

//    func validated<V>(by validationsSuite: V) throws -> Checked<T>
//        where V: ValidationsSuite, V.T == T
//    {
//        try checked(mergingErrors: validationsSuite.validator(self))
//    }
//
//    func validated() throws -> Checked<T>
//        where T: ValidationsSuite, T.T == T
//    {
//        try validated(by: self.result.value)
//    }

}

final class ValidationsTests: XCTestCase {
    func testValidations() throws {
        let decoder = JSONDecoder()
        let data = """
        {
            "name": "asd",
            "email": ""

        }
        """.data(using: .utf8)!


        let decoded = try decoder.decode(Decoded<User>.self, from: data)

        do {
            let validated = try decoded.validated {
                \.$name == "asd"
                nested(\.$email) {
                    \.isEmpty
                }
            }
            let name: String = validated.name

            print(name)
        } catch {
            print(error)
        }
    }
}

func nested<T, U>(_ keyPath: KeyPath<T, Decoded<U>>, @ValidatorBuilder<U> makeValidator: @escaping () -> Validator<U>) -> Validator<T> {
    .init { decoded in
        guard
            let decodedRootValue = try? decoded.result.value
        else {
            return nil
        }

        let decodedValue = decodedRootValue[keyPath: keyPath]

        return makeValidator()(decodedValue)
    }
}
