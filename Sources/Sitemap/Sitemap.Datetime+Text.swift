import ISO_8601

extension Sitemap.Datetime {

    public init(_ text: some StringProtocol) throws(Error) {
        var scanner = Sitemap.Datetime.Scanner(text)
        let form = Error.form(String(text))
        guard let year = scanner.digits(4) else { throw form }
        guard scanner.take(UInt8(ascii: "-")) else {
            guard scanner.isAtEnd else { throw form }
            self = .date(try Self.reduced(year: year))
            return
        }
        guard let month = scanner.digits(2) else { throw form }
        guard scanner.take(UInt8(ascii: "-")) else {
            guard scanner.isAtEnd else { throw form }
            self = .date(try Self.reduced(year: year, month: month))
            return
        }
        guard let day = scanner.digits(2) else { throw form }
        guard scanner.take(UInt8(ascii: "T")) else {
            guard scanner.isAtEnd else { throw form }
            self = .date(try Self.reduced(year: year, month: month, day: day))
            return
        }
        guard let hour = scanner.digits(2), scanner.take(UInt8(ascii: ":")), let minute = scanner.digits(2) else {
            throw form
        }
        var second = 0
        var nanoseconds = 0
        if scanner.take(UInt8(ascii: ":")) {
            guard let value = scanner.digits(2) else { throw form }
            second = value
            if scanner.take(UInt8(ascii: ".")) {
                guard let fraction = scanner.fraction() else { throw form }
                nanoseconds = fraction
            }
        }
        guard let offsetSeconds = scanner.designator(), scanner.isAtEnd else { throw form }
        let offset: ISO_8601.Timezone.Offset
        do throws(ISO_8601.Timezone.Offset.Error) {
            offset = try ISO_8601.Timezone.Offset(seconds: offsetSeconds)
        } catch {
            throw .offset(error)
        }
        do throws(ISO_8601.DateTime.Error) {
            self = .time(
                try ISO_8601.DateTime(
                    year: year,
                    month: month,
                    day: day,
                    hour: hour,
                    minute: minute,
                    second: second,
                    nanoseconds: nanoseconds,
                    offset: offset
                )
            )
        } catch {
            throw .time(error)
        }
    }

    private static func reduced(
        year: Int,
        month: Int? = nil,
        day: Int? = nil
    ) throws(Error) -> ISO_8601.CalendarDate.Reduced {
        do throws(ISO_8601.CalendarDate.Error) {
            return try ISO_8601.CalendarDate.Reduced(year: year, month: month, day: day)
        } catch {
            throw .date(error)
        }
    }
}
