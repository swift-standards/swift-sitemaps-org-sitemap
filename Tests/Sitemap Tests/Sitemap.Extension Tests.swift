import Testing

@testable import Sitemap

enum `Sitemap.Extension Tests` {}

extension `Sitemap.Extension Tests` {
    static let image = W3C_XML::W3C_XML.Namespace(prefix: "image", uri: "http://www.google.com/schemas/sitemap-image/1.1")

    static func picture(_ address: String) -> W3C_XML::W3C_XML.Element {
        W3C_XML::W3C_XML.Element(
            name: W3C_XML::W3C_XML.Name(local: "image", prefix: "image"),
            content: [.element(W3C_XML::W3C_XML.Element(name: W3C_XML::W3C_XML.Name(local: "loc", prefix: "image"), content: [.text(address)]))],
            namespaces: [image]
        )
    }

    @Suite
    struct `Extensions` {
        @Test
        func `an element that declares the namespace it uses is an extension`() throws {
            let item = try Sitemap.Extension(picture("https://example.com/a.png"))
            #expect(item.namespace == image)
        }

        @Test
        func `an element using an undeclared prefix is refused`() {
            let element = W3C_XML::W3C_XML.Element(name: W3C_XML::W3C_XML.Name(local: "image", prefix: "image"))
            #expect(throws: Sitemap.Extension.Error.undeclared("image")) {
                _ = try Sitemap.Extension(element)
            }
        }

        @Test
        func `an element in no namespace is refused`() {
            #expect(throws: Sitemap.Extension.Error.undeclared(nil)) {
                _ = try Sitemap.Extension(W3C_XML::W3C_XML.Element(name: "note"))
            }
            #expect(throws: Sitemap.Extension.Error.unqualified(W3C_XML::W3C_XML.Name("note"))) {
                _ = try Sitemap.Extension(W3C_XML::W3C_XML.Element(name: "note", namespaces: [W3C_XML::W3C_XML.Namespace(uri: "")]))
            }
        }

        @Test
        func `an element in the sitemaps namespace is refused`() {
            #expect(throws: Sitemap.Extension.Error.sitemap(W3C_XML::W3C_XML.Name("note"))) {
                _ = try Sitemap.Extension(W3C_XML::W3C_XML.Element(name: "note", namespaces: [Sitemap.namespace]))
            }
        }

        @Test
        func `prefixed declarations move to the root and the extension is written after the fields`() throws {
            let set = try Sitemap.URLSet([
                Sitemap.URL(
                    try Sitemap.Location("https://example.com/"),
                    priority: try Sitemap.Priority("0.5"),
                    extensions: [try Sitemap.Extension(picture("https://example.com/a.png"))]
                )
            ])
            #expect(
                String(decoding: set.bytes, as: UTF8.self) == """
                    <?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:image="http://www.google.com/schemas/sitemap-image/1.1"><url><loc>https://example.com/</loc><priority>0.5</priority><image:image><image:loc>https://example.com/a.png</image:loc></image:image></url></urlset>
                    """
            )
            #expect(try Sitemap.URLSet(parsing: set.bytes) == set)
        }

        @Test
        func `a prefix bound differently at the root keeps its own declaration`() throws {
            let other = W3C_XML::W3C_XML.Element(
                name: W3C_XML::W3C_XML.Name(local: "image", prefix: "image"),
                namespaces: [W3C_XML::W3C_XML.Namespace(prefix: "image", uri: "urn:example:other")]
            )
            let set = try Sitemap.URLSet([
                Sitemap.URL(
                    try Sitemap.Location("https://example.com/"),
                    extensions: [try Sitemap.Extension(picture("https://example.com/a.png")), try Sitemap.Extension(other)]
                )
            ])
            #expect(String(decoding: set.bytes, as: UTF8.self).contains(#"<image:image xmlns:image="urn:example:other"/>"#))
            #expect(try Sitemap.URLSet(parsing: set.bytes) == set)
        }

        @Test
        func `a read extension carries the declarations it relies on`() throws {
            let set = try Sitemap.URLSet(
                parsing: Array(
                    #"<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:image="http://www.google.com/schemas/sitemap-image/1.1"><url><loc>https://example.com/</loc><image:image><image:loc>https://example.com/a.png</image:loc></image:image></url></urlset>"#
                        .utf8
                )
            )
            #expect(set.urls.first?.extensions == [try Sitemap.Extension(picture("https://example.com/a.png"))])
        }

        @Test
        func `extensions of the set come before its first url and are refused after it`() throws {
            let head = #"<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:x="urn:example:x">"#
            let url = "<url><loc>https://example.com/</loc></url>"
            let set = try Sitemap.URLSet(parsing: Array((head + "<x:note/>" + url + "</urlset>").utf8))
            #expect(set.extensions.count == 1)
            #expect(throws: Sitemap.Parse.Error.unexpected(W3C_XML::W3C_XML.Name("x:note"), in: W3C_XML::W3C_XML.Name("urlset"))) {
                _ = try Sitemap.URLSet(parsing: Array((head + url + "<x:note/></urlset>").utf8))
            }
        }

        @Test
        func `an extension inside a url comes after its fields`() {
            let head = #"<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:x="urn:example:x"><url>"#
            #expect(throws: Sitemap.Parse.Error.missing(W3C_XML::W3C_XML.Name("loc"), in: W3C_XML::W3C_XML.Name("url"))) {
                _ = try Sitemap.URLSet(parsing: Array((head + "<x:note/><loc>https://example.com/</loc></url></urlset>").utf8))
            }
            #expect(throws: Sitemap.Parse.Error.unexpected(W3C_XML::W3C_XML.Name("priority"), in: W3C_XML::W3C_XML.Name("url"))) {
                _ = try Sitemap.URLSet(
                    parsing: Array((head + "<loc>https://example.com/</loc><x:note/><priority>1</priority></url></urlset>").utf8)
                )
            }
        }

        @Test
        func `declarations are kept sorted by prefix`() throws {
            let element = W3C_XML::W3C_XML.Element(
                name: "b:note",
                attributes: [W3C_XML::W3C_XML.Attribute(name: "a:kind", value: "k")],
                namespaces: [
                    W3C_XML::W3C_XML.Namespace(prefix: "b", uri: "urn:b"), W3C_XML::W3C_XML.Namespace(prefix: "a", uri: "urn:a"),
                ]
            )
            #expect(try Sitemap.Extension(element).element.namespaces.compactMap(\.prefix) == ["a", "b"])
        }

        @Test
        func `an element in no namespace inside a url is refused`() {
            #expect(throws: Sitemap.Parse.Error.unexpected(W3C_XML::W3C_XML.Name("note"), in: W3C_XML::W3C_XML.Name("url"))) {
                _ = try Sitemap.URLSet(
                    parsing: Array(
                        #"<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><url><loc>https://example.com/</loc><note xmlns=""/></url></urlset>"#
                            .utf8
                    )
                )
            }
        }

        @Test
        func `an undeclared prefix in the document is refused`() {
            #expect(throws: Sitemap.Parse.Error.undeclared("x")) {
                _ = try Sitemap.URLSet(
                    parsing: Array(
                        #"<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><url><loc>https://example.com/</loc><x:note/></url></urlset>"#
                            .utf8
                    )
                )
            }
        }
    }
}
