public import ISO_8601

extension Sitemap.Datetime {

    public enum Error: Swift::Error, Sendable, Equatable {

        case form(String)

        case date(ISO_8601.CalendarDate.Error)

        case time(ISO_8601.DateTime.Error)

        case offset(ISO_8601.Timezone.Offset.Error)
    }
}
