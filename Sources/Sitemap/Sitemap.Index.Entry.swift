import W3C_XML

extension Sitemap.Index {

    public struct Entry: Sendable, Hashable {

        public var location: Sitemap.Location

        public var modified: Sitemap.Datetime?

        public var extensions: [Sitemap.Extension]

        public init(
            _ location: Sitemap.Location,
            modified: Sitemap.Datetime? = nil,
            extensions: [Sitemap.Extension] = []
        ) {
            self.location = location
            self.modified = modified
            self.extensions = extensions
        }
    }
}

extension Sitemap.Index.Entry {

    func element(_ writer: inout Sitemap.Writer) -> W3C_XML.Element {
        var children = [Sitemap.Writer.element("loc", location.uri.value)]
        if let modified {
            children.append(Sitemap.Writer.element("lastmod", modified.description))
        }
        for item in extensions {
            children.append(writer.element(item))
        }
        return W3C_XML.Element(name: W3C_XML.Name(local: "sitemap"), content: children.map { .element($0) })
    }
}
