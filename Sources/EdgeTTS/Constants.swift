import Foundation

enum EdgeTTSConstants {
    static let baseURL = "api.msedgeservices.com/tts/cognitiveservices"
    static let trustedClientToken = "6A5AA1D4EAFF4E9FB37E23D68491D6F4"

    static let wssURL = "wss://\(baseURL)/websocket/v1?Ocp-Apim-Subscription-Key=\(trustedClientToken)"
    static let voiceListURL = "https://\(baseURL)/voices/list?Ocp-Apim-Subscription-Key=\(trustedClientToken)"

    static let defaultVoice = "en-US-EmmaMultilingualNeural"

    static let chromiumFullVersion = "140.0.3485.14"
    static let chromiumMajorVersion = chromiumFullVersion.split(separator: ".", maxSplits: 1).first ?? "140"
    static let secMsGecVersion = "1-\(chromiumFullVersion)"

    static var baseHeaders: [String: String] {
        [
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/\(chromiumMajorVersion).0.0.0 Safari/537.36 Edg/\(chromiumMajorVersion).0.0.0",
            "Accept-Encoding": "gzip, deflate, br",
            "Accept-Language": "en-US,en;q=0.9",
        ]
    }

    static var wssHeaders: [String: String] {
        var headers = [
            "Pragma": "no-cache",
            "Cache-Control": "no-cache",
            "Origin": "chrome-extension://jdiccldimpdaibmpdkjnbmckianbfold",
            "Sec-WebSocket-Version": "13",
            "Host": "api.msedgeservices.com",
        ]
        EdgeTTSConstants.baseHeaders.forEach { headers[$0.key] = $0.value }
        return headers
    }

    static var voiceHeaders: [String: String] {
        var headers = [
            "Authority": "speech.platform.bing.com",
            "Sec-CH-UA": "\" Not;A Brand\";v=\"99\", \"Microsoft Edge\";v=\"\(chromiumMajorVersion)\", \"Chromium\";v=\"\(chromiumMajorVersion)\"",
            "Sec-CH-UA-Mobile": "?0",
            "Accept": "*/*",
            "Sec-Fetch-Site": "none",
            "Sec-Fetch-Mode": "cors",
            "Sec-Fetch-Dest": "empty",
        ]
        EdgeTTSConstants.baseHeaders.forEach { headers[$0.key] = $0.value }
        return headers
    }
}
