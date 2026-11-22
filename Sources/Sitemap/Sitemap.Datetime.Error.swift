public import ISO_8601

extension Sitemap.Datetime {

    public enum Error: Swift::Error, Sendable, Equatable {

        case form(String)

        case date(ISO.`8601`.CalendarDate.Error)

        case time(ISO.`8601`.DateTime.Error)

        case offset(ISO.`8601`.Timezone.Offset.Error)
    }
}
