import Validations
import Decoded
import XCTest

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

final class ValidatorTests: XCTestCase {
    func testValidatorResultBuilder() throws {
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
            XCTFail(presentable.description)
        }
    }
}

/**
 Current Vapor validations to support:
 - [x] And - obsolete: use multiple validations
 - [x] Case - obsolete: rely on Decoded
 - [ ] CharacterSet ? alt:
 - [ ] Count ? alt: \.count == X
 - [ ] Email ? alt: don't include due to conflicting definitions
 - [ ] Empty ? alt: isEmpty
 - [ ] In
 - [ ] Nil ? alt:
 - [x] NilIgnoring - obsolete: use nil or ...
 - [ ] Not ? alt? use negated operators
 - [x] Or ?
 - [ ] Range ?
 - [ ] URL !
 - [x] Valid - obsolete: covered by Decoded

 Additional:
 - [x] Group
 - [x] Generic closure based validator  ("variadic" - Unwrap / Zip)
 - [x] Is Nil (for non-comparable)
 - [x] Is Absent
*/
