import Foundation

public enum EdgeTTSError: Error, LocalizedError {
    case unknownResponse(String)
    case unexpectedResponse(String)
    case noAudioReceived
    case websocketError(String)
    case skewAdjustmentFailed(String)
    case invalidParameter(String)

    public var errorDescription: String? {
        switch self {
        case .unknownResponse(let message),
             .unexpectedResponse(let message),
             .websocketError(let message),
             .skewAdjustmentFailed(let message),
             .invalidParameter(let message):
            return message
        case .noAudioReceived:
            return "No audio was received. Please verify that your parameters are correct."
        }
    }
}

public enum Boundary: String, Codable, Sendable {
    case word = "WordBoundary"
    case sentence = "SentenceBoundary"
}

public struct TTSConfig: Sendable {
    public var voice: String
    public var rate: String
    public var volume: String
    public var pitch: String
    public var boundary: Boundary

    public init(
        voice: String = "en-US-EmmaMultilingualNeural",
        rate: String = "+0%",
        volume: String = "+0%",
        pitch: String = "+0Hz",
        boundary: Boundary = .sentence
    ) throws {
        self.voice = voice
        self.rate = rate
        self.volume = volume
        self.pitch = pitch
        self.boundary = boundary
        try validate()
    }

    private mutating func validate() throws {
        let voicePattern = #"^[A-Za-z0-9][A-Za-z0-9\s\-\(\),]+$"#
        guard voice.range(of: voicePattern, options: .regularExpression) != nil else {
            throw EdgeTTSError.invalidParameter("Voice must match Microsoft voice format")
        }
        guard rate.range(of: #"^[\+\-]\d+%$"#, options: .regularExpression) != nil else {
            throw EdgeTTSError.invalidParameter("Rate must be like +0% or -50%")
        }
        guard volume.range(of: #"^[\+\-]\d+%$"#, options: .regularExpression) != nil else {
            throw EdgeTTSError.invalidParameter("Volume must be like +0% or -50%")
        }
        guard pitch.range(of: #"^[\+\-]\d+Hz$"#, options: .regularExpression) != nil else {
            throw EdgeTTSError.invalidParameter("Pitch must be like +0Hz or -50Hz")
        }

        if let match = voice.range(of: #"^([a-z]{2,})-([A-Z]{2,})-(.+Neural)$"#, options: [.regularExpression]) {
            let sub = String(voice[match])
            let parts = sub.split(separator: "-", maxSplits: 2).map(String.init)
            if parts.count == 3 {
                let lang = parts[0]
                var region = parts[1]
                var name = parts[2]
                if let dash = name.firstIndex(of: "-") {
                    region.append("-" + name[..<dash])
                    name = String(name[name.index(after: dash)...])
                }
                voice = "Microsoft Server Speech Text to Speech Voice (\(lang)-\(region), \(name))"
            }
        }
    }
}

public enum StreamEvent {
    case audio(Data)
    case boundary(type: Boundary, offset: Int64, duration: Int64, text: String)
}

public struct VoiceTag: Codable, Sendable {
    public let contentCategories: [String]
    public let voicePersonalities: [String]

    enum CodingKeys: String, CodingKey {
        case contentCategories = "ContentCategories"
        case voicePersonalities = "VoicePersonalities"
    }

    public init(contentCategories: [String] = [], voicePersonalities: [String] = []) {
        self.contentCategories = contentCategories
        self.voicePersonalities = voicePersonalities
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let categories = try container.decodeIfPresent([String].self, forKey: .contentCategories) ?? []
        let personalities = try container.decodeIfPresent([String].self, forKey: .voicePersonalities) ?? []
        self.init(contentCategories: categories, voicePersonalities: personalities)
    }
}

public struct Voice: Codable, Sendable {
    public let name: String
    public let shortName: String
    public let gender: String
    public let locale: String
    public let localeName: String?
    public let sampleRateHertz: String?
    public let voiceType: String?
    public let status: String?
    public let voiceTag: VoiceTag?

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case shortName = "ShortName"
        case gender = "Gender"
        case locale = "Locale"
        case localeName = "LocaleName"
        case sampleRateHertz = "SampleRateHertz"
        case voiceType = "VoiceType"
        case status = "Status"
        case voiceTag = "VoiceTag"
    }
}

struct MetadataEnvelope: Decodable {
    struct Metadata: Decodable {
        struct InnerData: Decodable {
            struct TextData: Decodable {
                let text: String

                enum CodingKeys: String, CodingKey {
                    case text = "Text"
                }
            }

            let offset: Int64
            let duration: Int64
            let text: TextData

            enum CodingKeys: String, CodingKey {
                case offset = "Offset"
                case duration = "Duration"
                case text
            }
        }

        let type: String
        let data: InnerData

        enum CodingKeys: String, CodingKey {
            case type = "Type"
            case data = "Data"
        }
    }

    let metadata: [Metadata]

    enum CodingKeys: String, CodingKey {
        case metadata = "Metadata"
    }
}
