import Decoded
import Validations
import XCTest

final class ValidationsTests: ValidationsTestCase {
    /// Demonstrates how to validate a password reset scenario.
    func test_passwordReset() throws {
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

        // in a real-world scenario, this would be an async call
        let credentialFailure = verifyCredentials(for: payload.email.value, password: payload.password.value)

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
            let descriptions = failures.mapFailures(String.init(describing:))

            XCTAssertEqual(descriptions.value, [
                ["email"]: ["Invalid credentials."],
                ["newPassword"]: ["Is not contained in the expected range."]
            ])
        }
    }
}

fileprivate struct InvalidCredentials: CustomStringConvertible, ValidationFailure {
    let description = "Invalid credentials."
}

fileprivate func verifyCredentials(for email: String?, password: String?) -> ValidationFailure? {
    guard let _ = email, let _ = password else {
        return nil
    }

    // in a real implementation we'd look the credentials for the email and verify the password against the stored hash

    return InvalidCredentials()
}

extension InRange.Failure: CustomStringConvertible {
    public var description: String {
        "Is not contained in the expected range."
    }
}
