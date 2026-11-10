public import ISO_8601

extension Sitemap {

    public enum Datetime: Sendable, Hashable {

        case date(ISO_8601.CalendarDate.Reduced)

        case time(ISO_8601.DateTime)
    }
}

extension Sitemap.Datetime {

    public init(_ date: ISO_8601.CalendarDate) {
        self = .date(ISO_8601.CalendarDate.Reduced(date))
    }

    public init(_ time: ISO_8601.DateTime) {
        self = .time(time)
    }
}

extension Sitemap.Datetime: CustomStringConvertible {

    public var description: String {
        switch self {
        case .date(let date): date.extended
        case .time(let time): time.description
        }
    }
}
