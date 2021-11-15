import Decoded
import Validations
import XCTest

/// Examples of real-world use-cases
final class ValidationsTests: ValidationsTestCase {
    /// Demonstrates how to validate a password reset scenario.
    @available(macOS 12.0.0, *)
    func test_passwordReset() async throws {
        struct ResetPasswordPayload: Decodable {
            let email: Decoded<String>
            let password: Decoded<String>
            let newPassword: Decoded<String>
            let confirmation: Decoded<String>
        }

        let data = """
        {
            "email": "a@b.com",
            "password": "secret1",
            "newPassword": "secret2",
            "confirmation": "secret2"
        }
        """
        let payload: Decoded<ResetPasswordPayload> = try decode(data)

        let credentialFailure = await verifyCredentials(for: payload.email.value, password: payload.password.value)

        do {
            let validated = try payload.validated {
                \.newPassword.count > 8
                \.confirmation == \.newPassword

                if let failure = credentialFailure {
                    Validator(nestedAt: \.email, failure: failure)
                }
            }
            XCTAssertEqual(validated.newPassword, "secret2")
        } catch let failures as KeyedFailures {
            let presentable = PresentableFailures(failures)
            XCTFail(presentable.description)
        }
    }
}

fileprivate struct InvalidCredentials: ValidationFailure {}

@available(macOS 12.0.0, *)
fileprivate func verifyCredentials(for email: String?, password: String?) async -> ValidationFailure? {
    guard let _ = email, let _ = password else {
        return nil
    }

    // in a real implementation we'd look the credentials for the email and verify the password against the stored hash

    return InvalidCredentials()
}
