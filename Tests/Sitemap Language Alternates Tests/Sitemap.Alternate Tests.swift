import Testing

@testable import Sitemap_Language_Alternates

enum `Sitemap.Alternate Tests` {}

extension `Sitemap.Alternate Tests` {
    @Suite
    struct `Language alternates` {
        @Test
        func `alternates are written as xhtml links sorted by language, then x-default`() throws {
            let nl = try Sitemap.Location("https://example.com/nl/")
            let en = try Sitemap.Location("https://example.com/en/")
            let set = try Sitemap.URLSet {
                Sitemap.URL(nl, alternates: [.nl: nl, .en: en], default: nl)
            }
            #expect(
                String(decoding: set.bytes, as: UTF8.self) == """
                    <?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml"><url><loc>https://example.com/nl/</loc><xhtml:link rel="alternate" hreflang="en" href="https://example.com/en/"/><xhtml:link rel="alternate" hreflang="nl" href="https://example.com/nl/"/><xhtml:link rel="alternate" hreflang="x-default" href="https://example.com/nl/"/></url></urlset>
                    """
            )
        }

        @Test
        func `alternates read back from the written set`() throws {
            let nl = try Sitemap.Location("https://example.com/nl/")
            let en = try Sitemap.Location("https://example.com/en-GB/")
            let tag = try BCP47.LanguageTag("en-GB")
            let set = try Sitemap.URLSet { Sitemap.URL(nl, alternates: [.nl: nl, tag: en], default: en) }
            let read = try Sitemap.URLSet(parsing: set.bytes)
            #expect(read == set)
            #expect(
                try read.urls.first?.alternates == [
                    Sitemap.Alternate(.tag(tag), en),
                    Sitemap.Alternate(.tag(.nl), nl),
                    Sitemap.Alternate(.default, en),
                ]
            )
        }

        @Test
        func `x-default is read without regard to case`() throws {
            #expect(try Sitemap.Alternate.Language("X-Default") == .default)
        }

        @Test
        func `other extensions are not alternates`() throws {
            let note = try Sitemap.Extension(W3C_XML::W3C_XML.Element(name: "x:note", namespaces: [W3C_XML::W3C_XML.Namespace(prefix: "x", uri: "urn:x")]))
            let url = Sitemap.URL(try Sitemap.Location("https://example.com/"), extensions: [note])
            #expect(try url.alternates.isEmpty)
            #expect(throws: Sitemap.Alternate.Error.link(W3C_XML::W3C_XML.Name("x:note"))) {
                _ = try Sitemap.Alternate(note)
            }
        }

        @Test
        func `a link with a malformed hreflang or href is refused`() throws {
            func link(_ attributes: [W3C_XML::W3C_XML.Attribute]) throws -> Sitemap.URL {
                let element = W3C_XML::W3C_XML.Element(
                    name: "xhtml:link",
                    attributes: [W3C_XML::W3C_XML.Attribute(name: "rel", value: "alternate")] + attributes,
                    namespaces: [Sitemap.Alternate.namespace]
                )
                return Sitemap.URL(try Sitemap.Location("https://example.com/"), extensions: [try Sitemap.Extension(element)])
            }
            #expect(throws: Sitemap.Alternate.Error.missing("hreflang")) {
                _ = try link([W3C_XML::W3C_XML.Attribute(name: "href", value: "https://example.com/")]).alternates
            }
            #expect(throws: Sitemap.Alternate.Error.language(.invalidSubtagOrder("en-USA"))) {
                _ = try link([
                    W3C_XML::W3C_XML.Attribute(name: "hreflang", value: "en-USA"),
                    W3C_XML::W3C_XML.Attribute(name: "href", value: "https://example.com/"),
                ]).alternates
            }
            #expect(throws: Sitemap.Alternate.Error.location(.relative(try RFC_3986.URI("/en/")))) {
                _ = try link([
                    W3C_XML::W3C_XML.Attribute(name: "hreflang", value: "en"),
                    W3C_XML::W3C_XML.Attribute(name: "href", value: "/en/"),
                ]).alternates
            }
        }
    }
}
