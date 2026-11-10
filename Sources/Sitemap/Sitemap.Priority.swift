extension Sitemap {

    public struct Priority: Sendable, Hashable {

        let significand: Int

        let scale: Int

        private init(unchecked parts: (significand: Int, scale: Int)) {
            self.significand = parts.significand
            self.scale = parts.scale
        }
    }
}

extension Sitemap.Priority {

    public static let maximumScale = 18

    public init(_ text: some StringProtocol) throws(Error) {
        let invalid = Error.decimal(String(text))
        var bytes = Array(text.utf8)[...]
        var negative = false
        if bytes.first == UInt8(ascii: "+") || bytes.first == UInt8(ascii: "-") {
            negative = bytes.first == UInt8(ascii: "-")
            bytes = bytes.dropFirst()
        }
        let integerDigits = bytes.prefix(while: Self.isDigit)
        bytes = bytes.dropFirst(integerDigits.count)
        var fractionDigits = bytes[bytes.endIndex...]
        if bytes.first == UInt8(ascii: ".") {
            bytes = bytes.dropFirst()
            fractionDigits = bytes.prefix(while: Self.isDigit)
            bytes = bytes.dropFirst(fractionDigits.count)
        }
        guard bytes.isEmpty, !(integerDigits.isEmpty && fractionDigits.isEmpty) else { throw invalid }
        try self.init(
            negative: negative,
            integer: Array(integerDigits.drop(while: { $0 == UInt8(ascii: "0") })),
            fraction: Array(fractionDigits.reversed().drop(while: { $0 == UInt8(ascii: "0") }).reversed()),
            text: String(text)
        )
    }

    public init(_ value: Double) throws(Error) {
        guard value.isFinite else { throw .decimal(value.description) }
        let text = value.description
        guard let exponentIndex = text.utf8.firstIndex(of: UInt8(ascii: "e")) else {
            try self.init(text)
            return
        }
        let mantissa = text.utf8[..<exponentIndex]
        guard let exponent = Int(String(decoding: text.utf8[text.utf8.index(after: exponentIndex)...], as: UTF8.self)),
            exponent < 0
        else { throw .range(text) }
        let digits = Array(mantissa.filter(Self.isDigit))
        let point = mantissa.firstIndex(of: UInt8(ascii: ".")).map { mantissa.distance(from: mantissa.startIndex, to: $0) }
        let integerCount = point ?? digits.count
        guard integerCount <= -exponent else { throw .range(text) }
        let zeros = [UInt8](repeating: UInt8(ascii: "0"), count: -exponent - integerCount)
        try self.init("0." + String(decoding: zeros + digits, as: UTF8.self))
    }

    private init(negative: Bool, integer: [UInt8], fraction: [UInt8], text: String) throws(Error) {
        guard fraction.count <= Self.maximumScale else { throw .scale(text) }
        let isZero = integer.isEmpty && fraction.isEmpty
        guard !negative || isZero else { throw .range(text) }
        guard integer.isEmpty || (integer == [UInt8(ascii: "1")] && fraction.isEmpty) else { throw .range(text) }
        var significand = integer.isEmpty ? 0 : 1
        for digit in fraction {
            significand = significand * 10 + Int(digit - UInt8(ascii: "0"))
        }
        self.init(unchecked: (significand, fraction.count))
    }

    private static func isDigit(_ byte: UInt8) -> Bool {
        byte >= UInt8(ascii: "0") && byte <= UInt8(ascii: "9")
    }

    private static func power(_ exponent: Int) -> Int128 {
        var result: Int128 = 1
        for _ in 0..<exponent {
            result *= 10
        }
        return result
    }
}

extension Sitemap.Priority: Comparable {

    public static func < (lhs: Self, rhs: Self) -> Bool {
        let scale = max(lhs.scale, rhs.scale)
        return Int128(lhs.significand) * power(scale - lhs.scale) < Int128(rhs.significand) * power(scale - rhs.scale)
    }
}

extension Sitemap.Priority: CustomStringConvertible {

    public var description: String {
        guard scale > 0 else { return "\(significand).0" }
        let fraction = String(significand)
        let padded = String(repeating: "0", count: max(0, scale - fraction.count)) + fraction
        return "0." + padded
    }
}
