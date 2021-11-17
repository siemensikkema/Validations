import Decoded
import XCTest
import Validations

final class KeyedFailuresTests: ValidationsTestCase {
    func test_annotatingFailuresWithErrorCodes() throws {
        do {
            let decoded: Decoded<Post> = try decode("""
            {
                "title": "My title",
                "body": "invalid"
            }
            """)

            // fail the validation on purpose
            _ = try decoded.validated {
                Validator(nestedAt: \.title, failure: Failure1())
                Validator(nestedAt: \.body, failure: Failure2())
            }
        } catch let failures as KeyedFailures {
            let errorOutput = failures.mapFailures(FailureWithCode.init)

            // encode mapped failures and decode as a dictionary so we can compare with the expected outcome
            let data = try JSONEncoder().encode(errorOutput)
            let dict = try JSONDecoder().decode([String: [FailureWithCode]].self, from: data)
            
            XCTAssertEqual(dict, [
                "title": [FailureWithCode(description: "failure1", code: 1)],
                "body": [FailureWithCode(description: "failure2", code: nil)]
            ])
        }
    }
}

fileprivate protocol CodedError {
    var errorCode: Int { get }
}

fileprivate struct FailureWithCode: Codable, Equatable {
    let description: String
    let code: Int?
}

extension FailureWithCode {
    init(failure: ValidationFailure) {
        self.code = (failure as? CodedError)?.errorCode
        self.description = String(describing: failure)
    }
}

fileprivate struct Failure1: ValidationFailure, CodedError, CustomStringConvertible {
    let description = "failure1"
    let errorCode = 1
}

fileprivate struct Failure2: ValidationFailure, CustomStringConvertible {
    let description = "failure2"
}

fileprivate struct Post: Decodable {
    let title: Decoded<String>
    let body: Decoded<String>
}
