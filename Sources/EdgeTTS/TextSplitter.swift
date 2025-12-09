import Foundation

enum TextSplitter {
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
