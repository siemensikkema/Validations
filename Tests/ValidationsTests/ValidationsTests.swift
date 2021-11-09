import Decoded
import Validations
import XCTest

/// Examples of real-world use-cases
final class ValidationsTests: ValidationsTestCase {
    /// Demonstrates how to validate a password reset scenario.
    func test_passwordReset() throws {
        struct ResetPasswordPayload: Decodable {
            let email: Decoded<String>
            let currentPassword: Decoded<String>
            let newPassword: Decoded<String>
            let confirmation: Decoded<String>
        }

        let data = """
        {
            "email": "a@b.com",
            "currentPassword": "secret1",
            "newPassword": "secret2",
            "confirmation": "secret2"
        }
        """
        let payload: Decoded<ResetPasswordPayload> = try decode(data)

        let validator = Validator<ResetPasswordPayload> {
            ValidEmail(\.email)
            \.newPassword == \.confirmation
        }

        struct PasswordMismatch: ValidationFailure {}

        let passwordMismatchFailure: PasswordMismatch? = nil

//        if
//            let email = payload.email.value,
//            let currentPassword = payload.currentPassword.value
//        {
//            // 1. Look up user by email
//            // 2. Validate password
//            passwordMismatchFailure = nil
//        } else {
//            passwordMismatchFailure = nil
//        }

        let currentPasswordValidator = Validator<ResetPasswordPayload>(\.currentPassword) { (_: KeyedSuccess<String>) in
            passwordMismatchFailure
        }

        do {
            let validated = try payload.validated(by: validator, currentPasswordValidator)
            XCTAssertEqual(validated.newPassword, "secret2")
            // assign password to user ...
        } catch let failures as KeyedFailures {
            let presentable = PresentableFailures(failures)
            XCTFail(presentable.description)
        }
    }
}
