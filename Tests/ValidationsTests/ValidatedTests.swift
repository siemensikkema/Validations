import Decoded
import Validations
import XCTest

final class ValidatedTests: ValidationsTestCase {
    func test_singleValue() throws {
        let decoded: Decoded<Int> = try decode("0")
        let validated = try decoded.validated()
        XCTAssertEqual(validated.unwrapped, 0)
    }

    func test_directPropertyAccess() throws {
        struct Gadget: Decodable {
            var name: Decoded<String>
        }

        let decoded: Decoded<Gadget> = try decode(#"{"name":"arduino"}"#)
        let validated = try decoded.validated()
        XCTAssertEqual(validated.name, "arduino")
    }

    func test_directPropertyAccess_nested() throws {
        struct CarRequest: Decodable {
            struct Engine: Decodable {
                var cylinderVolume: Decoded<Double>
            }
            var engine: Decoded<Engine>
        }

        let decoded: Decoded<CarRequest> = try decode(#"{"engine":{"cylinderVolume": 0.9}}"#)
        let validated = try decoded.validated()
        XCTAssertEqual(validated.engine.cylinderVolume, 0.9)
    }

    func test_checkingFailedDecodingThrowsError() throws {
        let decoded: Decoded<String> = try decode("0")

        XCTAssertThrowsError(try decoded.validated()) { error in
            guard let failures = error as? KeyedFailures else {
                XCTFail("expected error of type `KeyedFailures`")
                return
            }
            XCTAssertTrue(failures.value.values.first?.first is DecodingFailure)
        }
    }

    /// Tests a workaround for the edge case of a payload with `unwrapped` as a key which conflicts with ``Validated.unwrapped``.
    func test_nameConflictWithUnwrapped() throws {
        struct Package: Decodable {
            enum CodingKeys: String, CodingKey {
                case _unwrapped = "unwrapped"
            }
            var _unwrapped: Decoded<String>
        }
        let decoded: Decoded<Package> = try decode(#"{"unwrapped":"NY"}"#)
        let validated = try decoded.validated()
        XCTAssertEqual(validated._unwrapped, "NY")
        XCTAssertEqual(validated._unwrapped.codingPath, ["unwrapped"])
    }

    func test_directDecoding() throws {
        let decoded: Validated<Int> = try decode("1")
        XCTAssertEqual(decoded.unwrapped, 1)
    }

    func test_array() throws {
        let validated: Validated<[Decoded<Int>]> = try decode("[1,2,3]")
        XCTAssertEqual(validated.count, 3)
        XCTAssertEqual(validated[0], 1)
        XCTAssertEqual(validated.first, 1)
        XCTAssertEqual(validated.first?.value, 1)

        XCTAssertEqual(validated.unwrapped, [1,2,3])
    }

    func test_dictionary() throws {
        let validated: Validated<[String: Decoded<Int>]> = try decode(#"{"a":1}"#)
        XCTAssertEqual(validated.count, 1)
        XCTAssertEqual(validated["a"], 1)

        XCTAssertEqual(validated.unwrapped, ["a": 1])
    }
}
