// Batch-0 parity corpus: Form.Encoder / Form.Decoder wire-shape snapshots.
//
// For every strategy configuration in real-world use (mailgun, mailgun list
// members `.yesNo`, stripe `.bracketsWithIndices`, identities) plus each
// individual strategy axis with a default-config control, this suite encodes a
// representative fixture value with FIXED timestamps and fixed data bytes,
// snapshots the encoded pair string, decodes it back, and snapshots the
// round-trip equality result. Round-trip failures on the current stack are
// captured as-is in `__Corpus__/KNOWN-NON-ROUNDTRIP.txt`, not fixed.

import Foundation
import Testing
import URLFormCoding

// MARK: - Fixtures (fixed values only)

private struct Profile: Codable, Equatable {
    let name: String
    let active: Bool
}

/// Nested fixture: nested struct, arrays, bools, optionals, fixed date, fixed data.
private struct NestedFixture: Codable, Equatable {
    let profile: Profile
    let tags: [String]
    let counts: [Int]
    let flags: [Bool]
    let active: Bool
    let score: Double
    let createdAt: Date
    let payload: Data
    let nickname: String?
    let motto: String?
}

/// Flat fixture for "flat" strategies (accumulateValues cannot represent nesting).
private struct FlatFixture: Codable, Equatable {
    let name: String
    let count: Int
    let active: Bool
    let score: Double
    let tags: [String]
    let flags: [Bool]
    let createdAt: Date
    let payload: Data
    let nickname: String?
    let motto: String?
}

private let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
private let fixedData = Data([0xDE, 0xAD, 0xBE, 0xEF])

private let nestedFixture = NestedFixture(
    profile: Profile(name: "Blob McBlob", active: true),
    tags: ["swift", "server side"],
    counts: [1, 2, 3],
    flags: [true, false],
    active: false,
    score: 4.5,
    createdAt: fixedDate,
    payload: fixedData,
    nickname: nil,
    motto: "carpe diem ✓"
)

private let flatFixture = FlatFixture(
    name: "Blob McBlob",
    count: 42,
    active: true,
    score: 4.5,
    tags: ["swift", "server side"],
    flags: [true, false],
    createdAt: fixedDate,
    payload: fixedData,
    nickname: nil,
    motto: "carpe diem ✓"
)

// MARK: - Real-world configuration replicas

/// Replica of `rfc2822Formatter` in swift-mailgun-types
/// `Sources/Mailgun Types Shared/Form.Coder.swift`.
private func rfc2822Formatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
}

/// Replica of the fixed-format axis control.
private func yyyyMMddFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
}

/// Replica of `Form.Encoder.mailgun` (swift-mailgun-types Form.Coder.swift:58).
private func mailgunEncoder() -> Form.Encoder {
    Form.Encoder(
        dataEncodingStrategy: .base64,
        dateEncodingStrategy: .init { rfc2822Formatter().string(from: $0) },
        arrayEncodingStrategy: .brackets
    )
}

/// Replica of `Form.Decoder.mailgun` (swift-mailgun-types Form.Coder.swift:12).
private func mailgunDecoder() -> Form.Decoder {
    Form.Decoder(
        dataDecodingStrategy: .base64,
        dateDecodingStrategy: .init { dateString in
            if let date = rfc2822Formatter().date(from: dateString) { return date }
            if let timestamp = Double(dateString) {
                return Date(timeIntervalSince1970: timestamp)
            }
            if let date = ISO8601DateFormatter().date(from: dateString) { return date }
            return nil
        },
        arrayParsingStrategy: .brackets
    )
}

// MARK: - Case table

private struct Case {
    let name: String
    let run: () -> (encoded: String, roundtrip: String)

    init<T: Codable & Equatable>(
        _ name: String,
        _ fixture: T,
        encoder: @autoclosure @escaping () -> Form.Encoder,
        decoder: @autoclosure @escaping () -> Form.Decoder
    ) {
        self.name = name
        self.run = {
            do {
                let data = try encoder().encode(fixture)
                let encoded = String(decoding: data, as: UTF8.self)
                do {
                    let decoded = try decoder().decode(T.self, from: data)
                    let verdict = decoded == fixture ? "equal" : "mismatch"
                    return (encoded, "roundtrip: \(verdict)")
                } catch {
                    return (encoded, "roundtrip: decode-error: \(error)")
                }
            } catch {
                return ("encode-error: \(error)", "roundtrip: not-run")
            }
        }
    }
}

private func makeCases() -> [Case] { [
    // Default-config controls
    Case(
        "default-flat",
        flatFixture,
        encoder: Form.Encoder(),
        decoder: Form.Decoder()
    ),
    Case(
        "default-nested",
        nestedFixture,
        encoder: Form.Encoder(),
        decoder: Form.Decoder()
    ),
    // Bool axis
    Case(
        "bool-yesNo",
        flatFixture,
        encoder: Form.Encoder(boolEncodingStrategy: .yesNo),
        decoder: Form.Decoder(boolDecodingStrategy: .yesNo)
    ),
    // Array axis
    Case(
        "array-brackets",
        nestedFixture,
        encoder: Form.Encoder(arrayEncodingStrategy: .brackets),
        decoder: Form.Decoder(arrayParsingStrategy: .brackets)
    ),
    Case(
        "array-bracketsWithIndices",
        nestedFixture,
        encoder: Form.Encoder(arrayEncodingStrategy: .bracketsWithIndices),
        decoder: Form.Decoder(arrayParsingStrategy: .bracketsWithIndices)
    ),
    // Date axis
    Case(
        "date-secondsSince1970",
        flatFixture,
        encoder: Form.Encoder(dateEncodingStrategy: .secondsSince1970),
        decoder: Form.Decoder(dateDecodingStrategy: .secondsSince1970)
    ),
    Case(
        "date-millisecondsSince1970",
        flatFixture,
        encoder: Form.Encoder(dateEncodingStrategy: .millisecondsSince1970),
        decoder: Form.Decoder(dateDecodingStrategy: .millisecondsSince1970)
    ),
    Case(
        "date-iso8601",
        flatFixture,
        encoder: Form.Encoder(dateEncodingStrategy: .iso8601),
        decoder: Form.Decoder(dateDecodingStrategy: .iso8601)
    ),
    Case(
        "date-formatted-yyyyMMdd",
        flatFixture,
        encoder: Form.Encoder(dateEncodingStrategy: .formatted(yyyyMMddFormatter())),
        decoder: Form.Decoder(dateDecodingStrategy: .formatted(yyyyMMddFormatter()))
    ),
    // Data axis
    Case(
        "data-base64",
        flatFixture,
        encoder: Form.Encoder(dataEncodingStrategy: .base64),
        decoder: Form.Decoder(dataDecodingStrategy: .base64)
    ),
    // Real-world configurations
    Case(
        "mailgun",
        nestedFixture,
        encoder: mailgunEncoder(),
        decoder: mailgunDecoder()
    ),
    Case(
        "mailgun-list-members-yesNo",
        nestedFixture,
        encoder: {
            // Replica of Mailgun Lists Types Lists.API.swift:404-418.
            let encoder = mailgunEncoder()
            encoder.boolEncodingStrategy = .yesNo
            return encoder
        }(),
        decoder: {
            let decoder = mailgunDecoder()
            decoder.boolDecodingStrategy = .yesNo
            return decoder
        }()
    ),
    Case(
        "mailgun-routes",
        flatFixture,
        encoder: {
            // Replica of Form.Encoder.mailgunRoutes (Form.Coder.swift:66).
            let encoder = mailgunEncoder()
            encoder.arrayEncodingStrategy = .accumulateValues
            return encoder
        }(),
        decoder: {
            let decoder = mailgunDecoder()
            decoder.arrayParsingStrategy = .accumulateValues
            return decoder
        }()
    ),
    Case(
        "mailgun-events",
        flatFixture,
        encoder: {
            // Replica of Form.Encoder.mailgunEvents (Form.Coder.swift:74).
            let encoder = Form.Encoder(
                dataEncodingStrategy: .base64,
                dateEncodingStrategy: .init { String(Int($0.timeIntervalSince1970)) },
                arrayEncodingStrategy: .accumulateValues
            )
            return encoder
        }(),
        decoder: {
            let decoder = mailgunDecoder()
            decoder.arrayParsingStrategy = .accumulateValues
            return decoder
        }()
    ),
    Case(
        "stripe",
        nestedFixture,
        // Replica of swift-stripe-types Stripe Types Shared/FormCoding.swift:24.
        encoder: Form.Encoder(
            dateEncodingStrategy: .secondsSince1970,
            arrayEncodingStrategy: .bracketsWithIndices
        ),
        decoder: Form.Decoder(
            dateDecodingStrategy: .secondsSince1970,
            arrayParsingStrategy: .bracketsWithIndices
        )
    ),
    Case(
        "identities",
        nestedFixture,
        // Replica of swift-identities-types Form.Coding.identities.swift:19.
        encoder: Form.Encoder(arrayEncodingStrategy: .bracketsWithIndices),
        decoder: Form.Decoder(arrayParsingStrategy: .bracketsWithIndices)
    ),
] }

// MARK: - Tests

@Suite("Form Coder Parity")
struct FormCoderParityTests {
    @Test("wire-shape corpus (compare-or-record)")
    func corpus() throws {
        var nonRoundtrip: [String] = []
        for testCase in makeCases() {
            let (encoded, roundtrip) = testCase.run()
            try Corpus.compareOrRecord(
                "encoded: \(encoded)\n\(roundtrip)\n",
                named: testCase.name
            )
            if roundtrip != "roundtrip: equal" {
                nonRoundtrip.append("\(testCase.name): \(roundtrip)")
            }
        }
        let known =
            nonRoundtrip.isEmpty
            ? "none\n"
            : nonRoundtrip.joined(separator: "\n") + "\n"
        try Corpus.compareOrRecord(known, named: "KNOWN-NON-ROUNDTRIP")
    }
}
