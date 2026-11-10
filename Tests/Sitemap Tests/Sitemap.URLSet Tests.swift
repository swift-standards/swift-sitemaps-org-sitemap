import Testing

@testable import Sitemap

enum `Sitemap.URLSet Tests` {}

extension `Sitemap.URLSet Tests` {
    static func location(_ text: String) throws -> Sitemap.Location {
        try Sitemap.Location(text)
    }

    static func text(_ bytes: [UInt8]) -> String {
        String(decoding: bytes, as: UTF8.self)
    }

    @Suite
    struct `Writing` {
        @Test
        func `a set is written with the declaration, the namespace and the fields in protocol order`() throws {
            let set = try Sitemap.URLSet([
                Sitemap.URL(
                    try location("https://example.com/"),
                    modified: try Sitemap.Datetime("2026-11-10"),
                    frequency: .weekly,
                    priority: try Sitemap.Priority("0.8")
                )
            ])
            #expect(
                text(set.bytes) == """
                    <?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><url><loc>https://example.com/</loc><lastmod>2026-11-10</lastmod><changefreq>weekly</changefreq><priority>0.8</priority></url></urlset>
                    """
            )
        }

        @Test
        func `absent fields are not written`() throws {
            let set = try Sitemap.URLSet([Sitemap.URL(try location("https://example.com/a"))])
            #expect(!text(set.bytes).contains("priority"))
            #expect(!text(set.bytes).contains("lastmod"))
            #expect(!text(set.bytes).contains("changefreq"))
        }

        @Test
        func `data values use all five entity escapes`() throws {
            let set = try Sitemap.URLSet([Sitemap.URL(try location("https://example.com/?a=1&b='2'"))])
            #expect(text(set.bytes).contains("<loc>https://example.com/?a=1&amp;b=&apos;2&apos;</loc>"))
        }
    }

    @Suite
    struct `Limits` {
        @Test
        func `an empty set is refused`() {
            #expect(throws: Sitemap.Limit.Error.entries(0)) {
                _ = try Sitemap.URLSet([])
            }
        }

        @Test
        func `fifty thousand URLs are accepted and one more is refused`() throws {
            let url = Sitemap.URL(try location("https://example.com/"))
            #expect(try Sitemap.URLSet(Array(repeating: url, count: 50_000)).urls.count == 50_000)
            #expect(throws: Sitemap.Limit.Error.entries(50_001)) {
                _ = try Sitemap.URLSet(Array(repeating: url, count: 50_001))
            }
        }

        @Test
        func `a set whose file would exceed fifty megabytes is refused`() throws {
            let long = try location("https://example.com/" + String(repeating: "a", count: 2_000))
            let urls = Array(repeating: Sitemap.URL(long), count: 26_000)
            #expect {
                _ = try Sitemap.URLSet(urls)
            } throws: { error in
                guard case Sitemap.Limit.Error.bytes(let count) = error else { return false }
                return count > Sitemap.Limit.bytes
            }
        }

        @Test
        func `input over fifty megabytes is refused before it is read`() {
            #expect(throws: Sitemap.Parse.Error.limit(.bytes(Sitemap.Limit.bytes + 1))) {
                _ = try Sitemap.URLSet(parsing: [UInt8](repeating: 0x20, count: Sitemap.Limit.bytes + 1))
            }
        }
    }

    @Suite
    struct `Reading` {
        @Test
        func `a written set reads back equal and writes the same bytes`() throws {
            let set = try Sitemap.URLSet([
                Sitemap.URL(
                    try location("https://example.com/"),
                    modified: try Sitemap.Datetime("2026-11-10T09:30:00+01:00"),
                    frequency: .daily,
                    priority: try Sitemap.Priority("1")
                ),
                Sitemap.URL(try location("https://example.com/b?x=1&y=2"))
            ])
            let read = try Sitemap.URLSet(parsing: set.bytes)
            #expect(read == set)
            #expect(read.bytes == set.bytes)
        }

        @Test
        func `values are trimmed of XML whitespace and comments are ignored`() throws {
            let set = try Sitemap.URLSet(
                parsing: Array(
                    """
                    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><!-- c --><url>
                      <loc>
                        https://example.com/
                      </loc>
                      <changefreq> never </changefreq>
                    </url></urlset>
                    """.utf8
                )
            )
            #expect(set.urls.first?.location.uri.value == "https://example.com/")
            #expect(set.urls.first?.frequency == .never)
        }

        @Test
        func `the sitemaps namespace may be bound to a prefix`() throws {
            let set = try Sitemap.URLSet(
                parsing: Array(
                    #"<s:urlset xmlns:s="http://www.sitemaps.org/schemas/sitemap/0.9"><s:url><s:loc>https://example.com/</s:loc></s:url></s:urlset>"#
                        .utf8
                )
            )
            #expect(set.urls.count == 1)
        }

        @Test
        func `a urlset outside the sitemaps namespace is refused`() {
            #expect(throws: Sitemap.Parse.Error.unexpected(W3C_XML.Name("urlset"), in: nil)) {
                _ = try Sitemap.URLSet(parsing: Array("<urlset><url><loc>https://example.com/</loc></url></urlset>".utf8))
            }
        }

        @Test
        func `an encoding other than UTF-8 is refused`() {
            #expect(throws: Sitemap.Parse.Error.encoding("ISO-8859-1")) {
                _ = try Sitemap.URLSet(
                    parsing: Array(
                        #"<?xml version="1.0" encoding="ISO-8859-1"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><url><loc>https://example.com/</loc></url></urlset>"#
                            .utf8
                    )
                )
            }
        }
    }

    @Suite
    struct `Strict reading` {
        func parse(_ url: String) throws(Sitemap.Parse.Error) -> Sitemap.URLSet {
            try Sitemap.URLSet(
                parsing: Array(#"<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><url>\#(url)</url></urlset>"#.utf8)
            )
        }

        @Test
        func `fields out of protocol order are refused`() {
            #expect(throws: Sitemap.Parse.Error.unexpected(W3C_XML.Name("lastmod"), in: W3C_XML.Name("url"))) {
                _ = try parse("<loc>https://example.com/</loc><priority>0.5</priority><lastmod>2026</lastmod>")
            }
        }

        @Test
        func `a field given twice is refused`() {
            #expect(throws: Sitemap.Parse.Error.unexpected(W3C_XML.Name("loc"), in: W3C_XML.Name("url"))) {
                _ = try parse("<loc>https://example.com/</loc><loc>https://example.com/</loc>")
            }
        }

        @Test
        func `a url without loc first is refused`() {
            #expect(throws: Sitemap.Parse.Error.missing(W3C_XML.Name("loc"), in: W3C_XML.Name("url"))) {
                _ = try parse("<lastmod>2026</lastmod><loc>https://example.com/</loc>")
            }
            #expect(throws: Sitemap.Parse.Error.missing(W3C_XML.Name("loc"), in: W3C_XML.Name("url"))) {
                _ = try parse("")
            }
        }

        @Test
        func `an unknown element of the sitemaps namespace is refused`() {
            #expect(throws: Sitemap.Parse.Error.unexpected(W3C_XML.Name("title"), in: W3C_XML.Name("url"))) {
                _ = try parse("<loc>https://example.com/</loc><title>x</title>")
            }
        }

        @Test
        func `text between elements is refused`() {
            #expect(throws: Sitemap.Parse.Error.text(in: W3C_XML.Name("url"))) {
                _ = try parse("<loc>https://example.com/</loc>stray")
            }
        }

        @Test
        func `an unknown change frequency is refused`() {
            #expect(throws: Sitemap.Parse.Error.frequency("Weekly")) {
                _ = try parse("<loc>https://example.com/</loc><changefreq>Weekly</changefreq>")
            }
        }

        @Test
        func `a value holding an element is refused`() {
            #expect(throws: Sitemap.Parse.Error.unexpected(W3C_XML.Name("b"), in: W3C_XML.Name("loc"))) {
                _ = try parse("<loc>https://example.com/<b/></loc>")
            }
        }
    }
}
