import Common
import Checked
import Decoded
import XCTest

final class CheckedTests: XCTestCase {
    func test_singleValue() throws {
        let decoded: Decoded<DecodedValueWrapper<Int>> = try decode("0")
        let checked = try decoded.checked()
        XCTAssertEqual(checked.value, 0)
    }

    func test_directPropertyAccess() throws {
        struct Gadget: Decodable {
            @Decoded<String> var name
        }

        let decoded: Decoded<Gadget> = try decode(#"{"name":"arduino"}"#)
        let checked = try decoded.checked()
        XCTAssertEqual(checked.name, "arduino")
    }

    func test_directPropertyAccess_nested() throws {
        struct CarRequest: Decodable {
            struct Engine: Decodable {
                @Decoded<Double> var cylinderVolume
            }
            @Decoded<Engine> var engine
        }

        let decoded: Decoded<CarRequest> = try decode(#"{"engine":{"cylinderVolume": 0.9}}"#)
        let checked = try decoded.checked()
        XCTAssertEqual(checked.engine.cylinderVolume, 0.9)
    }

    func test_checkingFailedDecodingThrowsError() throws {
        let decoded: Decoded<String> = try decode("0")

        XCTAssertThrowsError(try decoded.checked()) { error in
            guard let error = error as? KeyedErrors else {
                XCTFail("expected error of type `KeyedErrors`")
                return
            }
            let mappedErrors = error.mapErrors { $0 is Decoded<String>.State.TypeMismatch }
            XCTAssertEqual(mappedErrors, [[]: [true]])
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
        let checked = try decoded.checked()
        XCTAssertEqual(checked.state.name, "NY")
        XCTAssertEqual(checked.$state.codingPath, ["state"])
    }

    func test_directDecoding() throws {
        let decoded: Checked<DecodedValueWrapper<Int>> = try decode("1")
        XCTAssertEqual(decoded.value, 1)
    }

    func test_array() throws {
        let checked: Checked<[Decoded<Int>.State]> = try decode("[1,2,3]")
        XCTAssertEqual(checked.count, 3)
        XCTAssertEqual(checked[0], 1)
        XCTAssertEqual(checked.first, 1)
        XCTAssertEqual(try checked.first?.value, 1)

        XCTAssertEqual(checked.unwrapped(), [1,2,3])
    }

    func test_dictionary() throws {
        let checked: Checked<[String: Decoded<Int>.State]> = try decode(#"{"a":1}"#)
        XCTAssertEqual(checked.count, 1)
        XCTAssertEqual(checked["a"], 1)

        XCTAssertEqual(checked.unwrapped(), ["a": 1])
    }
}
