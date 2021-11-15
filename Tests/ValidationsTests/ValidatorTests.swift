import Decoded
import Validations
import XCTest

final class ValidatorTests: ValidationsTestCase {
    func test_basic_validator_success() throws {
        let decoded: Decoded<DecodedValueWrapper<Int>> = try decode("0")
        let validator = Validator<DecodedValueWrapper<Int>>(\.value) { (value: KeyedSuccess) in
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
            let presentable = PresentableFailures(failures)
            print(presentable)
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

        struct TestFailure: ValidationFailure, PresentableFailure {
            var presentableDescription: String {
                "customized!"
            }
        }

        let decoded = try decoder.decode(Decoded<User>.self, from: data)
        let validator = Validator<User> {
            \.name == "asd"

            \.address.street == \.name

            ValidEmail(\.email)

            Validator {
                \.name != \.email
            }.or {
                \.name == "ab@b.com"
            }

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
            let presentable = PresentableFailures(failures)
            print(presentable)
            XCTAssertEqual(presentable.value.count, 3)
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

