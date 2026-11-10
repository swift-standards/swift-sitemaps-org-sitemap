extension Sitemap.Datetime {

    struct Scanner {

        let bytes: [UInt8]

        var index: Int

        init(_ text: some StringProtocol) {
            self.bytes = Array(text.utf8)
            self.index = 0
        }
    }
}

extension Sitemap.Datetime.Scanner {

    var isAtEnd: Bool { index == bytes.count }

    mutating func take(_ byte: UInt8) -> Bool {
        guard index < bytes.count, bytes[index] == byte else { return false }
        index += 1
        return true
    }

    func digit(at position: Int) -> Int? {
        guard position < bytes.count else { return nil }
        let byte = bytes[position]
        guard byte >= UInt8(ascii: "0"), byte <= UInt8(ascii: "9") else { return nil }
        return Int(byte - UInt8(ascii: "0"))
    }

    mutating func digits(_ count: Int) -> Int? {
        guard index + count <= bytes.count else { return nil }
        let slice = bytes[index..<(index + count)]
        guard slice.allSatisfy({ $0 >= UInt8(ascii: "0") && $0 <= UInt8(ascii: "9") }) else { return nil }
        index += count
        return slice.reduce(0) { $0 * 10 + Int($1 - UInt8(ascii: "0")) }
    }

    mutating func fraction() -> Int? {
        var nanoseconds = 0
        var count = 0
        while let digit = digit(at: index) {
            if count < 9 {
                nanoseconds = nanoseconds * 10 + digit
            }
            count += 1
            index += 1
        }
        guard count > 0 else { return nil }
        for _ in min(count, 9)..<9 {
            nanoseconds *= 10
        }
        return nanoseconds
    }

    mutating func designator() -> Int? {
        if take(UInt8(ascii: "Z")) { return 0 }
        let sign: Int
        if take(UInt8(ascii: "+")) {
            sign = 1
        } else if take(UInt8(ascii: "-")) {
            sign = -1
        } else {
            return nil
        }
        guard let hours = digits(2), take(UInt8(ascii: ":")), let minutes = digits(2), minutes < 60 else {
            return nil
        }
        return sign * (hours * 3_600 + minutes * 60)
    }
}
