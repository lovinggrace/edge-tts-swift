import CryptoKit
import Foundation

enum DRM {
    @MainActor private static var clockSkewSeconds: TimeInterval = 0
    private static let winEpoch: TimeInterval = 11_644_473_600 // Seconds between 1601 and 1970

    @MainActor static func adjustClockSkew(by seconds: TimeInterval) {
        clockSkewSeconds += seconds
    }

    @MainActor static func currentUnixTimestamp() -> TimeInterval {
        Date().timeIntervalSince1970 + clockSkewSeconds
    }

    static func parseRFC2616Date(_ value: String) -> TimeInterval? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return formatter.date(from: value)?.timeIntervalSince1970
    }

    @MainActor static func handleClientResponseError(_ response: HTTPURLResponse) throws {
        guard let serverDate = response.value(forHTTPHeaderField: "Date") else {
            throw EdgeTTSError.skewAdjustmentFailed("Server did not return a Date header")
        }
        guard let parsed = parseRFC2616Date(serverDate) else {
            throw EdgeTTSError.skewAdjustmentFailed("Failed to parse server date: \(serverDate)")
        }
        let clientDate = currentUnixTimestamp()
        adjustClockSkew(by: parsed - clientDate)
    }

    @MainActor static func generateSecMSGEC(timestamp: TimeInterval? = nil) -> String {
        let base = timestamp ?? currentUnixTimestamp()
        var ticks = base + winEpoch // seconds since Windows epoch
        ticks -= ticks.truncatingRemainder(dividingBy: 300) // round down to 5 minutes
        let fileTimeUnits = ticks * 10_000_000 // 100ns units

        let toHash = String(format: "%.0f%@", fileTimeUnits, EdgeTTSConstants.trustedClientToken)
        let digest = SHA256.hash(data: Data(toHash.utf8))
        return digest.map { String(format: "%02X", $0) }.joined()
    }
}
