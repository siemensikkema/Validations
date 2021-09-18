import Validations
import Decoded
import XCTest

struct Address: Decodable {
    @Decoded<String> var street
    @Decoded<String?> var line2
    @Decoded<String> var city
    @Decoded<String> var region
    @Decoded<String> var postcode
}

struct User: Decodable {
    @Decoded<String> var email
    @Decoded<String> var name
    @Decoded<Address> var address
}

final class ValidationsTests: XCTestCase {
    func testValidations() throws {
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

        let decoded = try decoder.decode(Decoded<User>.self, from: data)
        let validator = Validator<User> {
            \.$name == "asd"

            ValidEmail(\.$email)

            Validator {
                \.$name != \.$email
            }.or {
                \.$name == "ab@b.com"
            }

            Validator(withValueAt: \.$name) { name in
                \.$email != name
            }

            Validator(nestedAt: \.$address) {
                \.$street == "a"
                \.$line2 == nil
                IsNil(\.$line2)
                \.$city == "b"
                \.$region == "c"
                \.$postcode == "1234"
            }
        }

        do {
            let validated = try decoded.validated(by: validator)
            let name: String = validated.name
            print(name)
        } catch let error as ValidationErrors {
            let presentable = PresentableErrors(error)
            print(presentable)
            XCTFail(presentable.description)
        }
    }
}

/// A basic example of processing validation errors to make them presentable to an end-user.
///
/// More advanced approaches could involve scanning for errors conforming to some protocol to output:
/// - error codes or translation keys (possibly including dynamic data) for client side translation
/// - server-side translated errors based on a language code in the request's `Accept` header.
struct PresentableErrors {
    let value: [CodingPath: [String]]

    init(_ validationErrors: ValidationErrors) {
        self.value = validationErrors.value.mapValues { errors in
            errors.map { error in
                guard let presentableError = error as? PresentableError else {
                    return "\(error)"
                }
                return presentableError.presentableDescription
            }
        }
    }
}

extension PresentableErrors: CustomStringConvertible {
    var description: String {
        value.flatMap { codingPath, errors in
            ["\(codingPath.dotPath):"] + errors.map { " - \($0)" }
        }.joined(separator: "\n")
    }
}

protocol PresentableError {
    var presentableDescription: String { get }
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
