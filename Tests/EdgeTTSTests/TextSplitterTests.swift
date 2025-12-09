import XCTest
@testable import EdgeTTS

final class TextSplitterTests: XCTestCase {
    func testSplitRespectsByteLimit() throws {
        let text = String(repeating: "hello ", count: 50)
        let chunks = try TextSplitter.split(text: text, byteLimit: 32)
        XCTAssertFalse(chunks.isEmpty)
        XCTAssertTrue(chunks.allSatisfy { $0.count <= 32 })
    }

    func testSplitKeepsUTF8Boundaries() throws {
        let text = String(repeating: "你好", count: 10)
        let chunks = try TextSplitter.split(text: text, byteLimit: 7)
        XCTAssertTrue(chunks.allSatisfy { String(data: $0, encoding: .utf8) != nil })
    }

    func testConfigValidation() throws {
        let config = try TTSConfig(voice: "en-US-EmmaMultilingualNeural", rate: "+0%", volume: "+0%", pitch: "+0Hz", boundary: .sentence)
        XCTAssertTrue(config.voice.contains("Microsoft Server Speech"))
    }

    @MainActor
    func testDRMTokenLength() async {
        let token = await DRM.generateSecMSGEC()
        XCTAssertEqual(token.count, 64)
    }
}
