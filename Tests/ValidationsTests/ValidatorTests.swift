import Decoded
import Validations
import XCTest

final class ValidatorTests: ValidationsTestCase {
    func test_basic_validator_success() throws {
        let decoded: Decoded<Int> = try decode("0")
        let validator = Validator<Int> { (value: KeyedSuccess) in
            nil
        }
        XCTAssertNoThrow(try decoded.validated(by: validator))
    }

    func test_presentable_decoded_errors() throws {
        struct NonOptionalName: Decodable {
            let name: Decoded<String>
        }

        let decoded: Decoded<NonOptionalName> = try decode(#"{"name":null}"#)

        do {
            _ = try decoded.validated()
        } catch let failures as KeyedFailures {
            let descriptions = failures.mapFailures(String.init(describing:))

            #if os(Linux)
            XCTAssertEqual(descriptions.value, [["name"]: ["Type mismatch."]])
            #else
            XCTAssertEqual(descriptions.value, [["name"]: ["Value not found."]])
            #endif
        }
    }

    func test_validatorResultBuilder() throws {
        let decoder = JSONDecoder()
        let data = """
        {
            "name": "a@b.com",
            "email": "ab.com",
            "address": {
                "street": "a",
                "city": "b",
                "region": "c",
                "postcode": "1234"
            }
        }
        """.data(using: .utf8)!

        struct TestFailure: CustomStringConvertible, ValidationFailure {
            var description: String {
                "test"
            }
        }

        let decoded = try decoder.decode(Decoded<User>.self, from: data)
        let validator = Validator<User> {
            \.name == "asd"

            \.address.street == \.name

            ValidEmail(\.email)

            Validator {
                \.name != \.email
            }.or(Validator {
                \.name == "ab@b.com"
            })

            Validator(withValueAt: \.name) { name in
                \.email != name
            }

            Validator(nestedAt: \.address) {
                \.street == "a"
                \.line2 == nil
                IsNil(\.line2)
                \.city == "b"
                \.region == "c"
                \.postcode == "1234"
            }.mapFailures { _ in TestFailure() }
        }

        do {
            let validated = try decoded.validated(by: validator)
            let name: String = validated.name
            print(name)
        } catch let failures as KeyedFailures {
            let descriptions = failures.mapFailures(String.init(describing:))

            XCTAssertEqual(descriptions.value, [
                ["name"]: ["'a@b.com' does not equal 'asd'."],
                ["address", "street"]: ["'a' does not equal 'a@b.com'."],
                ["email"]: ["Is not a valid email address."],
                ["address", "line2"]: ["test"]
            ])
        }
    }
}

struct Address: Decodable {
    var street: Decoded<String>
    var line2: Decoded<String?>
    var city: Decoded<String>
    var region: Decoded<String>
    var postcode: Decoded<String>
}

struct User: Decodable {
    var email: Decoded<String>
    var name: Decoded<String>
    var address: Decoded<Address>
}

extension DecodingFailure: CustomStringConvertible {
    public var description: String {
        switch self.errorType {
        case .dataCorrupted:
            return "Data corrupted."
        case .keyNotFound:
            return "Key not found."
        case .typeMismatch:
            return "Type mismatch."
        case .valueNotFound:
            return "Value not found."
        }
    }
}

extension IsEqual.Failure: CustomStringConvertible {
    public var description: String {
        "'\(lhs)' does not equal '\(rhs)'."
    }
}

extension ValidEmail.Failure: CustomStringConvertible {
    public var description: String {
        "Is not a valid email address."
    }
}
