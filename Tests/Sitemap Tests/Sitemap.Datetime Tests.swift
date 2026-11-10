import Testing

@testable import Sitemap

enum `Sitemap.Datetime Tests` {}

extension `Sitemap.Datetime Tests` {
    @Suite
    struct `W3C Datetime` {
        @Test(arguments: [
            "2026", "2026-11", "2026-11-10", "2026-11-10T09:30:00Z", "2026-11-10T09:30:00+01:00",
            "2026-11-10T09:30:00.5-05:30",
        ])
        func `each granularity writes back as read`(_ text: String) throws {
            #expect(try Sitemap.Datetime(text).description == text)
        }

        @Test
        func `a time without seconds reads as second zero`() throws {
            #expect(try Sitemap.Datetime("2026-11-10T09:30+01:00").description == "2026-11-10T09:30:00+01:00")
        }

        @Test
        func `a fraction is written without trailing zeros and dropped when zero`() throws {
            #expect(try Sitemap.Datetime("2026-11-10T09:30:00.250Z").description == "2026-11-10T09:30:00.25Z")
            #expect(try Sitemap.Datetime("2026-11-10T09:30:00.000Z").description == "2026-11-10T09:30:00Z")
        }

        @Test(arguments: [
            "20261110", "2026-11-10T09:30:00", "2026-11-10T09", "2026-11-10t09:30Z", "2026-11-10T09:30:00,5Z",
            "2026-11-10T09:30:00z", "2026-11-10 09:30Z", "2026-11-10T09:30+0100", "2026-11-10T09:30+01:75", "26-11-10",
            "2026-11-10T09:30:00.Z",
        ])
        func `forms outside the profile are refused`(_ text: String) {
            #expect(throws: Sitemap.Datetime.Error.form(text)) {
                _ = try Sitemap.Datetime(text)
            }
        }

        @Test
        func `an impossible date or time is refused by ISO 8601`() {
            #expect(throws: Sitemap.Datetime.Error.date(.dayOutOfRange(30, month: 2, year: 2026))) {
                _ = try Sitemap.Datetime("2026-02-30")
            }
            #expect(throws: Sitemap.Datetime.Error.time(.hourOutOfRange(24))) {
                _ = try Sitemap.Datetime("2026-11-10T24:00:00Z")
            }
        }

        @Test
        func `a date and a date-time from ISO 8601 are taken as they are`() throws {
            let date = try ISO_8601.CalendarDate(year: 2026, month: 11, day: 10)
            #expect(Sitemap.Datetime(date).description == "2026-11-10")
            let time = try ISO_8601.DateTime(year: 2026, month: 11, day: 10, hour: 8, minute: 5)
            #expect(Sitemap.Datetime(time).description == "2026-11-10T08:05:00Z")
        }
    }
}
