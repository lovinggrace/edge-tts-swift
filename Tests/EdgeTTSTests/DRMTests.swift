import XCTest
@testable import EdgeTTS

final class DRMTests: XCTestCase {
    @MainActor
    func testGenerateSecMSGECForKnownTimestamp() {
        let timestamp: TimeInterval = 1_730_000_000
        let expected = "68EBC40536E04FEDEC126E928E3BD86045309ED62EA865F537896B0A96858D3B"

        let token = DRM.generateSecMSGEC(timestamp: timestamp)

        XCTAssertEqual(token, expected)
    }

    func testGenerateMUIDShape() {
        let muid = DRM.generateMUID()

        XCTAssertEqual(muid.count, 32)
        XCTAssertNotNil(muid.range(of: #"^[0-9A-F]{32}$"#, options: .regularExpression))
    }

    func testHeadersWithMUIDAddsCookie() {
        let headers = DRM.headersWithMUID(["User-Agent": "test"])

        XCTAssertEqual(headers["User-Agent"], "test")
        XCTAssertNotNil(headers["Cookie"]?.range(of: #"^muid=[0-9A-F]{32};$"#, options: .regularExpression))
    }
}
