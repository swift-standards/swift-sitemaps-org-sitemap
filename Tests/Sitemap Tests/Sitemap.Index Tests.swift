import Testing

@testable import Sitemap

enum `Sitemap.Index Tests` {}

extension `Sitemap.Index Tests` {
    @Suite
    struct `Sitemap index` {
        @Test
        func `an index is written as a sitemapindex of sitemap entries`() throws {
            let index = try Sitemap.Index([
                Sitemap.Index.Entry(try Sitemap.Location("https://example.com/sitemap-1.xml"), modified: try Sitemap.Datetime("2026-11")),
                Sitemap.Index.Entry(try Sitemap.Location("https://example.com/sitemap-2.xml"))
            ])
            #expect(
                String(decoding: index.bytes, as: UTF8.self) == """
                    <?xml version="1.0" encoding="UTF-8"?><sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><sitemap><loc>https://example.com/sitemap-1.xml</loc><lastmod>2026-11</lastmod></sitemap><sitemap><loc>https://example.com/sitemap-2.xml</loc></sitemap></sitemapindex>
                    """
            )
            #expect(try Sitemap.Index(parsing: index.bytes) == index)
        }

        @Test
        func `an index holds one to fifty thousand entries`() throws {
            #expect(throws: Sitemap.Limit.Error.entries(0)) {
                _ = try Sitemap.Index([])
            }
            let entry = Sitemap.Index.Entry(try Sitemap.Location("https://example.com/sitemap.xml"))
            #expect(throws: Sitemap.Limit.Error.entries(50_001)) {
                _ = try Sitemap.Index(Array(repeating: entry, count: 50_001))
            }
        }

        @Test
        func `an entry takes only loc and lastmod`() {
            #expect(throws: Sitemap.Parse.Error.unexpected(W3C_XML.Name("priority"), in: W3C_XML.Name("sitemap"))) {
                _ = try Sitemap.Index(
                    parsing: Array(
                        #"<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><sitemap><loc>https://example.com/s.xml</loc><priority>1</priority></sitemap></sitemapindex>"#
                            .utf8
                    )
                )
            }
        }

        @Test
        func `a urlset is not an index`() {
            #expect(throws: Sitemap.Parse.Error.unexpected(W3C_XML.Name("urlset"), in: nil)) {
                _ = try Sitemap.Index(
                    parsing: Array(#"<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"/>"#.utf8)
                )
            }
        }
    }
}
