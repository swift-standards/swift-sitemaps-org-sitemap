import Testing

@testable import Sitemap

enum `Sitemap.Location Tests` {}

extension `Sitemap.Location Tests` {
    @Suite
    struct `Location limits` {
        @Test
        func `a relative reference is refused`() throws {
            let uri = try RFC_3986.URI("/about")
            #expect(throws: Sitemap.Location.Error.relative(uri)) {
                _ = try Sitemap.Location(uri)
            }
        }

        @Test
        func `text that is not a URI is refused`() {
            #expect(throws: Sitemap.Location.Error.self) {
                _ = try Sitemap.Location("https://example.com/ü")
            }
        }

        @Test
        func `the escaped length must be under 2048 characters`() throws {
            let prefix = "https://example.com/"
            let longest = prefix + String(repeating: "a", count: 2_047 - prefix.count)
            #expect(try Sitemap.Location(longest).uri.value.count == 2_047)
            #expect(throws: Sitemap.Location.Error.length(2_048)) {
                _ = try Sitemap.Location(longest + "a")
            }
        }

        @Test
        func `an ampersand counts as its five-character escape`() throws {
            let prefix = "https://example.com/?"
            let text = prefix + String(repeating: "a", count: 2_043 - prefix.count) + "&"
            #expect(text.count == 2_044)
            #expect(throws: Sitemap.Location.Error.length(2_048)) {
                _ = try Sitemap.Location(text)
            }
        }

        @Test
        func `the escaped length must be at least 12 characters`() throws {
            #expect(throws: Sitemap.Location.Error.length(11)) {
                _ = try Sitemap.Location("http://a.b/")
            }
            #expect(try Sitemap.Location("http://ab.c/").uri.value == "http://ab.c/")
        }
    }
}
