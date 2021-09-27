import Decoded
import XCTest

final class TopLevelValueDecodingTests: XCTestCase {
    func test_value() throws {
        let decoded: Decoded<Int> = try decode("1")
        XCTAssertEqual(decoded.codingPath, [])
        XCTAssertEqual(decoded.result, .success(.value(1)))
        XCTAssertEqual(decoded.value, 1)
    }

    func test_expected_nil() throws {
        let decoded: Decoded<Int?> = try decode("null")
        XCTAssertEqual(decoded.codingPath, [])
        XCTAssertEqual(decoded.result, .success(.nil))
        XCTAssertNil(try decoded.unwrapped)
    }

    func test_unexpected_nil() throws {
        let decoded: Decoded<Int> = try decode("null")
        XCTAssertEqual(decoded.codingPath, [])

        guard case .failure(let failure) = decoded.result else {
            XCTFail("")
            return
        }
        XCTAssertEqual(failure.errorType, .valueNotFound)
        XCTAssertEqual(failure.debugDescription, "Expected Int but found null value instead.")
        XCTAssertThrowsError(try decoded.unwrapped)
    }
}

final class PropertyDecodingTests: XCTestCase {
    struct OptionalName: Decodable {
        let name: Decoded<String?>
    }

    func test_value() throws {
        let decoded: Decoded<OptionalName> = try decode(#"{"name": "asd"}"#)
        XCTAssertEqual(decoded.codingPath, [])

        let decodedName = try decoded.unwrapped.name
        XCTAssertEqual(decodedName.codingPath, ["name"])
        XCTAssertEqual(decodedName.result, .success(.value("asd")))
        XCTAssertEqual(decodedName.value, "asd")
    }

    func test_expected_nil() throws {
        let decoded: Decoded<OptionalName> = try decode(#"{"name": null}"#)
        XCTAssertEqual(decoded.codingPath, [])

        let decodedName = try decoded.unwrapped.name
        XCTAssertEqual(decodedName.codingPath, ["name"])
        XCTAssertEqual(decodedName.result, .success(.nil))
        XCTAssertNil(try decodedName.unwrapped)
    }

    func test_expected_absent() throws {
        let decoded: Decoded<OptionalName> = try decode("{}")
        XCTAssertEqual(decoded.codingPath, [])

        let decodedName = try decoded.unwrapped.name
        XCTAssertEqual(decodedName.codingPath, ["name"])
        XCTAssertEqual(decodedName.result, .success(.absent))
        XCTAssertNil(try decodedName.unwrapped)
    }

    struct NonOptionalName: Decodable {
        let name: Decoded<String>
    }

    func test_unexpected_nil() throws {
        let decoded: Decoded<NonOptionalName> = try decode(#"{"name": null}"#)
        XCTAssertEqual(decoded.codingPath, [])

        let decodedName = try decoded.unwrapped.name
        XCTAssertEqual(decodedName.codingPath, ["name"])

        guard case .failure(let failure) = decodedName.result else {
            XCTFail("")
            return
        }
        XCTAssertEqual(failure.errorType, .valueNotFound)
        XCTAssertEqual(failure.debugDescription, "Expected String but found null value instead.")
        XCTAssertThrowsError(try decodedName.unwrapped)
    }

    func test_unexpected_absent() throws {
        let decoded: Decoded<NonOptionalName> = try decode("{}")
        XCTAssertEqual(decoded.codingPath, [])

        let decodedName = try decoded.unwrapped.name
        XCTAssertEqual(decodedName.codingPath, ["name"])

        guard case .failure(let failure) = decodedName.result else {
            XCTFail("")
            return
        }
        XCTAssertEqual(failure.errorType, .keyNotFound)
        XCTAssertEqual(failure.debugDescription, #"No value associated with key CodingKeys(stringValue: "name", intValue: nil) ("name")."#)
        XCTAssertThrowsError(try decodedName.unwrapped)
    }
}
