//
//  BoolStrategyTests.swift
//  URLFormCoding Tests
//
//  Created for testing the Bool encoding/decoding strategies added for RT-030b.
//  Mirrors RFC_2046.Multipart.Encoder's Bool.Encoder (swift-url-routing), which
//  offers the same .trueFalse/.yesNo presets for multipart form encoding.
//

import Foundation
import Testing
import URLFormCoding

@Suite("Bool Strategy Tests")
struct BoolStrategyTests {

    // MARK: - Test Models

    struct Flag: Codable, Equatable {
        let name: String
        let enabled: Bool
    }

    struct OptionalFlag: Codable, Equatable {
        let name: String
        let enabled: Bool?
    }

    // MARK: - Encoding

    @Suite("Bool Encoding")
    struct EncodingTests {

        @Test("Encodes true/false with the default trueFalse strategy")
        func testDefaultStrategyEncodesTrueFalse() throws {
            let encoder = Form.Encoder()

            let onData = try encoder.encode(Flag(name: "a", enabled: true))
            let offData = try encoder.encode(Flag(name: "a", enabled: false))

            // Keyed containers are dictionary-backed, so field order is not guaranteed;
            // check field presence rather than exact string equality (matches this
            // suite's existing convention, e.g. FormEncoder Tests.swift).
            #expect(String(data: onData, encoding: .utf8)!.contains("enabled=true"))
            #expect(String(data: offData, encoding: .utf8)!.contains("enabled=false"))
        }

        @Test("Encodes true/false explicitly with .trueFalse")
        func testExplicitTrueFalseStrategy() throws {
            let encoder = Form.Encoder(boolEncodingStrategy: .trueFalse)

            let onData = try encoder.encode(Flag(name: "a", enabled: true))
            let offData = try encoder.encode(Flag(name: "a", enabled: false))

            #expect(String(data: onData, encoding: .utf8)!.contains("enabled=true"))
            #expect(String(data: offData, encoding: .utf8)!.contains("enabled=false"))
        }

        @Test("Encodes true/false as yes/no with .yesNo")
        func testYesNoStrategy() throws {
            let encoder = Form.Encoder(boolEncodingStrategy: .yesNo)

            let onData = try encoder.encode(Flag(name: "a", enabled: true))
            let offData = try encoder.encode(Flag(name: "a", enabled: false))

            #expect(String(data: onData, encoding: .utf8)!.contains("enabled=yes"))
            #expect(String(data: offData, encoding: .utf8)!.contains("enabled=no"))
        }

        @Test("Applies .yesNo to optional Bool fields")
        func testYesNoStrategyWithOptional() throws {
            let encoder = Form.Encoder(boolEncodingStrategy: .yesNo)

            let data = try encoder.encode(OptionalFlag(name: "a", enabled: true))
            #expect(String(data: data, encoding: .utf8)!.contains("enabled=yes"))
        }

        @Test("Custom bool encoding strategy")
        func testCustomStrategy() throws {
            let encoder = Form.Encoder(boolEncodingStrategy: .custom { $0 ? "1" : "0" })

            let data = try encoder.encode(Flag(name: "a", enabled: true))
            #expect(String(data: data, encoding: .utf8)!.contains("enabled=1"))
        }
    }

    // MARK: - Decoding

    @Suite("Bool Decoding")
    struct DecodingTests {

        @Test("Default trueFalse strategy decodes 1/true as true, everything else as false")
        func testDefaultStrategyDecoding() throws {
            let decoder = Form.Decoder()

            #expect(
                try decoder.decode(Flag.self, from: Data("name=a&enabled=true".utf8)).enabled
                    == true
            )
            #expect(
                try decoder.decode(Flag.self, from: Data("name=a&enabled=1".utf8)).enabled == true
            )
            #expect(
                try decoder.decode(Flag.self, from: Data("name=a&enabled=false".utf8)).enabled
                    == false
            )
            #expect(
                try decoder.decode(Flag.self, from: Data("name=a&enabled=0".utf8)).enabled == false
            )

            // Unchanged default behavior: "yes" is NOT recognized as true unless opted in.
            #expect(
                try decoder.decode(Flag.self, from: Data("name=a&enabled=yes".utf8)).enabled
                    == false
            )
        }

        @Test("Explicit .trueFalse strategy matches default behavior")
        func testExplicitTrueFalseStrategyDecoding() throws {
            let decoder = Form.Decoder(boolDecodingStrategy: .trueFalse)

            #expect(
                try decoder.decode(Flag.self, from: Data("name=a&enabled=true".utf8)).enabled
                    == true
            )
            #expect(
                try decoder.decode(Flag.self, from: Data("name=a&enabled=yes".utf8)).enabled
                    == false
            )
        }

        @Test(".yesNo strategy additionally accepts yes as true")
        func testYesNoStrategyDecoding() throws {
            let decoder = Form.Decoder(boolDecodingStrategy: .yesNo)

            #expect(
                try decoder.decode(Flag.self, from: Data("name=a&enabled=yes".utf8)).enabled == true
            )
            #expect(
                try decoder.decode(Flag.self, from: Data("name=a&enabled=YES".utf8)).enabled == true
            )
            // Existing true-forms still accepted.
            #expect(
                try decoder.decode(Flag.self, from: Data("name=a&enabled=true".utf8)).enabled
                    == true
            )
            #expect(
                try decoder.decode(Flag.self, from: Data("name=a&enabled=1".utf8)).enabled == true
            )
            // "no" and anything unrecognized still decode to false.
            #expect(
                try decoder.decode(Flag.self, from: Data("name=a&enabled=no".utf8)).enabled == false
            )
            #expect(
                try decoder.decode(Flag.self, from: Data("name=a&enabled=false".utf8)).enabled
                    == false
            )
        }

        @Test("Custom bool decoding strategy")
        func testCustomStrategyDecoding() throws {
            let decoder = Form.Decoder(boolDecodingStrategy: .custom { $0 == "on" })

            #expect(
                try decoder.decode(Flag.self, from: Data("name=a&enabled=on".utf8)).enabled == true
            )
            #expect(
                try decoder.decode(Flag.self, from: Data("name=a&enabled=true".utf8)).enabled
                    == false
            )
        }
    }

    // MARK: - Round-trip

    @Suite("Bool Round-trip")
    struct RoundTripTests {

        @Test("Round-trips true/false with matching default strategies")
        func testDefaultRoundTrip() throws {
            let encoder = Form.Encoder()
            let decoder = Form.Decoder()

            let original = Flag(name: "a", enabled: true)
            let encoded = try encoder.encode(original)
            let decoded = try decoder.decode(Flag.self, from: encoded)

            #expect(decoded == original)
        }

        @Test("Round-trips yes/no with matching .yesNo strategies")
        func testYesNoRoundTrip() throws {
            let encoder = Form.Encoder(boolEncodingStrategy: .yesNo)
            let decoder = Form.Decoder(boolDecodingStrategy: .yesNo)

            for value in [true, false] {
                let original = Flag(name: "a", enabled: value)
                let encoded = try encoder.encode(original)
                let decoded = try decoder.decode(Flag.self, from: encoded)
                #expect(decoded == original)
            }
        }
    }
}
