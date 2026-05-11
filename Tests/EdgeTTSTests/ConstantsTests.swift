import XCTest
@testable import EdgeTTS

final class ConstantsTests: XCTestCase {
    func testBackendCompatibilityConstantsMatchUpstream() {
        XCTAssertEqual(EdgeTTSConstants.baseURL, "speech.platform.bing.com/consumer/speech/synthesize/readaloud")
        XCTAssertEqual(EdgeTTSConstants.voiceListURL, "https://speech.platform.bing.com/consumer/speech/synthesize/readaloud/voices/list?trustedclienttoken=6A5AA1D4EAFF4E9FB37E23D68491D6F4")
        XCTAssertEqual(EdgeTTSConstants.chromiumFullVersion, "143.0.3650.75")
        XCTAssertEqual(EdgeTTSConstants.secMsGecVersion, "1-143.0.3650.75")
        XCTAssertEqual(EdgeTTSConstants.defaultOutputFormat, "audio-24khz-48kbitrate-mono-mp3")
        XCTAssertEqual(EdgeTTSConstants.ticksPerSecond, 10_000_000)
        XCTAssertEqual(EdgeTTSConstants.mp3BitrateBPS, 48_000)
    }

    func testHeadersMatchCurrentBackendExpectations() {
        XCTAssertEqual(EdgeTTSConstants.baseHeaders["Accept-Encoding"], "gzip, deflate, br, zstd")
        XCTAssertNil(EdgeTTSConstants.wssHeaders["Host"])
        XCTAssertEqual(EdgeTTSConstants.voiceHeaders["Authority"], "speech.platform.bing.com")
        XCTAssertTrue(EdgeTTSConstants.voiceHeaders["Sec-CH-UA"]?.contains("\"Microsoft Edge\";v=\"143\"") == true)
    }
}
