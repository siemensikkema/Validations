import Common
import Decoded
import Validations
import XCTest

final class ValidatedTests: XCTestCase {
    func test_singleValue() throws {
        let decoded: Decoded<DecodedValueWrapper<Int>> = try decode("0")
        let validated = try decoded.validated()
        XCTAssertEqual(validated.value, 0)
    }

    func test_directPropertyAccess() throws {
        struct Gadget: Decodable {
            @Decoded<String> var name
        }

        let decoded: Decoded<Gadget> = try decode(#"{"name":"arduino"}"#)
        let validated = try decoded.validated()
        XCTAssertEqual(validated.name, "arduino")
    }

    func test_directPropertyAccess_nested() throws {
        struct CarRequest: Decodable {
            struct Engine: Decodable {
                @Decoded<Double> var cylinderVolume
            }
            @Decoded<Engine> var engine
        }

        let decoded: Decoded<CarRequest> = try decode(#"{"engine":{"cylinderVolume": 0.9}}"#)
        let validated = try decoded.validated()
        XCTAssertEqual(validated.engine.cylinderVolume, 0.9)
    }

    func test_checkingFailedDecodingThrowsError() throws {
        let decoded: Decoded<String> = try decode("0")

        XCTAssertThrowsError(try decoded.validated()) { error in
            guard let error = error as? KeyedErrors else {
                XCTFail("expected error of type `KeyedErrors`")
                return
            }
            XCTAssertTrue(error.value.values.first?.first is DecodingFailure)
        }
    }

    func test_nameConflictWithState() throws {
        struct City: Decodable {
            struct State: Decodable {
                @Decoded<String> var name
            }
            @Decoded<State> var state
        }
        let decoded: Decoded<City> = try decode(#"{"state":{"name":"NY"}}"#)
        let validated = try decoded.validated()
        XCTAssertEqual(validated.state.name, "NY")
        XCTAssertEqual(validated.$state.codingPath, ["state"])
    }

    func test_directDecoding() throws {
        let decoded: Validated<DecodedValueWrapper<Int>> = try decode("1")
        XCTAssertEqual(decoded.value, 1)
    }

    func test_array() throws {
        let validated: Validated<[DecodingResult<Int>]> = try decode("[1,2,3]")
        XCTAssertEqual(validated.count, 3)
        XCTAssertEqual(validated[0], 1)
        XCTAssertEqual(validated.first, 1)
        XCTAssertEqual(validated.first?.value, 1)

        XCTAssertEqual(validated.unwrapped(), [1,2,3])
    }

    func test_dictionary() throws {
        let validated: Validated<[String: DecodingResult<Int>]> = try decode(#"{"a":1}"#)
        XCTAssertEqual(validated.count, 1)
        XCTAssertEqual(validated["a"], 1)

        XCTAssertEqual(validated.unwrapped(), ["a": 1])
    }
}
