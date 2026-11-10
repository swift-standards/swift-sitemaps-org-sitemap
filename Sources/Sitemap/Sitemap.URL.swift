import W3C_XML

extension Sitemap {

    public struct URL: Sendable, Hashable {

        public var location: Location

        public var modified: Datetime?

        public var frequency: Frequency?

        public var priority: Priority?

        public var extensions: [Extension]

        public init(
            _ location: Location,
            modified: Datetime? = nil,
            frequency: Frequency? = nil,
            priority: Priority? = nil,
            extensions: [Extension] = []
        ) {
            self.location = location
            self.modified = modified
            self.frequency = frequency
            self.priority = priority
            self.extensions = extensions
        }
    }
}

extension Sitemap.URL {

    func element(_ writer: inout Sitemap.Writer) -> W3C_XML::W3C_XML.Element {
        var children = [Sitemap.Writer.element("loc", location.uri.value)]
        if let modified {
            children.append(Sitemap.Writer.element("lastmod", modified.description))
        }
        if let frequency {
            children.append(Sitemap.Writer.element("changefreq", frequency.description))
        }
        if let priority {
            children.append(Sitemap.Writer.element("priority", priority.description))
        }
        for item in extensions {
            children.append(writer.element(item))
        }
        return W3C_XML::W3C_XML.Element(name: W3C_XML::W3C_XML.Name(local: "url"), content: children.map { .element($0) })
    }
}
