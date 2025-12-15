import Foundation

/// A utility for preparing and splitting text into byte-size–constrained chunks.
///
/// ## Overview
/// `TextSplitter` is primarily used for text-to-speech or other network-bound APIs where:
/// - Certain Unicode control characters are rejected
/// - Request payloads must not exceed a strict UTF-8 byte limit
///
/// The splitter is designed to:
/// - Preserve valid Unicode scalars
/// - Prefer splitting on whitespace boundaries
/// - Avoid breaking HTML or XML entities mid-sequence
/// - Gracefully degrade when no clean split point exists
enum TextSplitter {
    /// Sanitizes a string by replacing Unicode control characters that are incompatible with
    /// downstream APIs.
    ///
    /// ## Details
    /// The following Unicode scalar ranges are mapped to a single space (`U+0020`):
    /// - `U+0000`–`U+0008`
    /// - `U+000B`–`U+000C`
    /// - `U+000E`–`U+001F`
    ///
    /// All other Unicode scalars are preserved verbatim.
    ///
    /// - Parameter text: The input string to sanitize.
    /// - Returns: A new string with incompatible characters replaced by spaces.
    static func removeIncompatibleCharacters(_ text: String) -> String {
        let scalars = text.unicodeScalars.map { scalar -> UnicodeScalar in
            let code = scalar.value
            if (0...8).contains(code) || (11...12).contains(code) || (14...31).contains(code) {
                return UnicodeScalar(32)!
            }
            return scalar
        }
        return String(String.UnicodeScalarView(scalars))
    }

    /// Splits a string into UTF-8–encoded data chunks that do not exceed a given byte size.
    ///
    /// ## Algorithm
    /// The splitter incrementally consumes the input string while:
    /// - Tracking UTF-8 byte length (not scalar or character count)
    /// - Favoring the last whitespace or newline before the byte limit
    /// - Avoiding splits inside incomplete HTML or XML entities (for example, `&amp`)
    ///
    /// Each resulting chunk is trimmed of leading and trailing whitespace or newlines and
    /// encoded as UTF-8 ``Data``.
    ///
    /// - Parameters:
    ///   - text: The input string to split.
    ///   - byteLimit: The maximum allowed size, in UTF-8 bytes, for each chunk. Must be positive.
    /// - Throws: ``EdgeTTSError/invalidParameter(_:)`` if `byteLimit` is zero or negative.
    /// - Returns: An ordered array of UTF-8–encoded ``Data`` chunks.
    static func split(text: String, byteLimit: Int) throws -> [Data] {
        guard byteLimit > 0 else { throw EdgeTTSError.invalidParameter("Byte limit must be positive") }
        let cleaned = removeIncompatibleCharacters(text)
        var remaining = cleaned[cleaned.startIndex..<cleaned.endIndex]
        var chunks: [Data] = []

        while remaining.utf8.count > byteLimit {
            var byteCount = 0
            var candidateIndex = remaining.startIndex
            var lastWhitespace: String.Index?

            var idx = remaining.startIndex
            while idx < remaining.endIndex {
                let next = remaining.index(after: idx)
                let charBytes = remaining[idx..<next].utf8.count
                if byteCount + charBytes > byteLimit { break }
                byteCount += charBytes
                if remaining[idx].isWhitespace || remaining[idx].isNewline {
                    lastWhitespace = idx
                }
                candidateIndex = next
                idx = next
            }

            var splitIndex = lastWhitespace ?? candidateIndex

            if let ampRange = remaining[..<splitIndex].range(of: "&", options: .backwards) {
                if remaining[ampRange.lowerBound..<splitIndex].contains(";") == false {
                    splitIndex = ampRange.lowerBound
                }
            }

            if splitIndex == remaining.startIndex {
                guard remaining.startIndex < remaining.endIndex else { break }
                splitIndex = remaining.index(after: remaining.startIndex)
            }

            let chunkString = remaining[remaining.startIndex..<splitIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            if !chunkString.isEmpty {
                chunks.append(Data(chunkString.utf8))
            }
            remaining = remaining[splitIndex..<remaining.endIndex]
        }

        let finalChunk = remaining.trimmingCharacters(in: .whitespacesAndNewlines)
        if !finalChunk.isEmpty {
            chunks.append(Data(finalChunk.utf8))
        }

        return chunks
    }
}
