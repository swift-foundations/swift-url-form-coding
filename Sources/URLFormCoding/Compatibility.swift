@_exported import HTML_Form_Coder
@_exported import HTML_Form_Coder_Codable
import HTML_Standard

/// Compatibility spelling for the form-coding surface now owned by
/// `swift-html-form-coder`.
@available(*, deprecated, renamed: "HTML.Form.Coder")
public typealias Form = HTML.Form.Coder

extension HTML.Form.Coder.Encoder {
    public typealias DataEncodingStrategy = HTML.Form.Coder.Strategy.Data.Encoding
    public typealias DateEncodingStrategy = HTML.Form.Coder.Strategy.Date.Encoding
    public typealias ArrayEncodingStrategy = HTML.Form.Coder.Strategy.Array.Encoding
    public typealias BoolEncodingStrategy = HTML.Form.Coder.Strategy.Bool.Encoding
}

extension HTML.Form.Coder.Decoder {
    public typealias DataDecodingStrategy = HTML.Form.Coder.Strategy.Data.Decoding
    public typealias DateDecodingStrategy = HTML.Form.Coder.Strategy.Date.Decoding
    public typealias ArrayParsingStrategy = HTML.Form.Coder.Strategy.Array.Decoding
    public typealias BoolDecodingStrategy = HTML.Form.Coder.Strategy.Bool.Decoding
}

extension HTML.Form.Coder.Strategy.Data.Encoding {
    @available(*, deprecated, renamed: "deferred")
    public static var deferredToData: Self { .deferred }
}

extension HTML.Form.Coder.Strategy.Data.Decoding {
    @available(*, deprecated, renamed: "deferred")
    public static var deferredToData: Self { .deferred }
}

extension HTML.Form.Coder.Strategy.Date.Encoding {
    @available(*, deprecated, renamed: "deferred")
    public static var deferredToDate: Self { .deferred }

    @available(*, deprecated, renamed: "seconds")
    public static var secondsSince1970: Self { .seconds }

    @available(*, deprecated, renamed: "milliseconds")
    public static var millisecondsSince1970: Self { .milliseconds }
}

extension HTML.Form.Coder.Strategy.Date.Decoding {
    @available(*, deprecated, renamed: "deferred")
    public static var deferredToDate: Self { .deferred }

    @available(*, deprecated, renamed: "seconds")
    public static var secondsSince1970: Self { .seconds }

    @available(*, deprecated, renamed: "milliseconds")
    public static var millisecondsSince1970: Self { .milliseconds }
}

extension HTML.Form.Coder.Strategy.Bool.Encoding {
    @available(*, deprecated, renamed: "true")
    public static var trueFalse: Self { .true }

    @available(*, deprecated, renamed: "yes")
    public static var yesNo: Self { .yes }
}

extension HTML.Form.Coder.Strategy.Bool.Decoding {
    @available(*, deprecated, renamed: "true")
    public static var trueFalse: Self { .true }

    @available(*, deprecated, renamed: "yes")
    public static var yesNo: Self { .yes }
}
