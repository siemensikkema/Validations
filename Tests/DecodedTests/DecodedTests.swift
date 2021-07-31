import Common
import Decoded
import XCTest

final class DecodedTests: XCTestCase {
    func test_value() throws {
        let decoded: Decoded<Int> = try decode("1")
        XCTAssertEqual(decoded.codingPath, [])
        XCTAssertEqual(decoded.state, .value(1))
    }

    func test_nil() throws {
        let decoded: Decoded<Int> = try decode("null")
        XCTAssertEqual(decoded.codingPath, [])
        XCTAssertEqual(decoded.state, .nil)
    }

    func test_typeMismatch() throws {
        let decoded: Decoded<String> = try decode("1")
        XCTAssertEqual(decoded.codingPath, [])
        XCTAssertEqual(decoded.state, .typeMismatch(debugDescription: "Expected to decode String but found a number instead."))
    }

    func test_dataCorrupted() throws {
        let decoded: Decoded<Int> = try decode("1.1")
        XCTAssertEqual(decoded.codingPath, [])
        XCTAssertEqual(decoded.state, .dataCorrupted(debugDescription: "Parsed JSON number <1.1> does not fit in Int."))
    }

    func test_absent() throws {
        struct Gadget: Decodable, Equatable {
            let name: Decoded<String>
        }
        let decoded: Decoded<Gadget> = try decode("{}")
        XCTAssertEqual(decoded.codingPath, [])

        let decodedName = try decoded.state.value.name
        XCTAssertEqual(decodedName.codingPath, ["name"])
        XCTAssertEqual(decodedName.state, .absent)
    }
}
