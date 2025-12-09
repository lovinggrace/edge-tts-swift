import XCTest
@testable import EdgeTTS

final class IntegrationTests: XCTestCase {
    func testSynthesizeReturnsAudio() async throws {
        // Opt-in to avoid accidental network calls in CI.
//        let shouldRun = ProcessInfo.processInfo.environment["EDGE_TTS_RUN_NETWORK_TESTS"] == "1"
//        try XCTSkipUnless(shouldRun, "Set EDGE_TTS_RUN_NETWORK_TESTS=1 to run integration tests.")

        let start = Date()
        let client = EdgeTTSClient()
        let audio = try await client.synthesize(text: "Hello from Edge TTS integration test.")
        XCTAssertFalse(audio.isEmpty, "Expected synthesized audio data.")
        print("Synthesis took \(Date().timeIntervalSince(start))s, bytes: \(audio.count)")
    }
}
