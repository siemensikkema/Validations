import Decoded
import XCTest

final class DecodedTests: XCTestCase {
    func test_singleValue() throws {
        let decoded = try decode("1", as: Int.self)
        XCTAssertEqual(decoded.codingPath, [])
        XCTAssertEqual(decoded.state, .value(1))
    }

    func test_nilValue() throws {
        let decoded = try decode("null", as: Int.self)
        XCTAssertEqual(decoded.codingPath, [])
        XCTAssertEqual(decoded.state, .nil)
    }

    func test_typeMismatch() throws {
        let decoded = try decode("1", as: String.self)
        XCTAssertEqual(decoded.codingPath, [])
        XCTAssertEqual(decoded.state, .typeMismatch("Expected to decode String but found a number instead."))
    }

    func test_absent() throws {
        struct Gadget: Decodable, Equatable {
            let name: Decoded<String>
        }
        let decoded = try decode("{}", as: Gadget.self)
        XCTAssertEqual(decoded.codingPath, [])

        let decodedName = try decoded.state.requireValue().name
        XCTAssertEqual(decodedName.codingPath, [.init(stringValue: "name")])
        XCTAssertEqual(decodedName.state, .absent)
    }
}
