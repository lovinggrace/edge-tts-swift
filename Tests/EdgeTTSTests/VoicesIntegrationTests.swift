import XCTest
@testable import EdgeTTS

final class VoicesIntegrationTests: XCTestCase {
    func testListVoicesReturnsData() async throws {
        let shouldRun = ProcessInfo.processInfo.environment["EDGE_TTS_RUN_NETWORK_TESTS"] == "1"
        try XCTSkipUnless(shouldRun, "Set EDGE_TTS_RUN_NETWORK_TESTS=1 to run integration tests.")

        let client = EdgeTTSClient()
        let voices = try await client.listVoices()
        XCTAssertFalse(voices.isEmpty, "Expected voices list to be non-empty.")
        if let first = voices.first {
            print("First voice: \(first.shortName) (\(first.gender))")
        }
    }
}
