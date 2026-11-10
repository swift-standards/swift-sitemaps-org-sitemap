public import W3C_XML

extension Sitemap {

    public struct Extension: Sendable, Hashable {

        public let element: W3C_XML::W3C_XML.Element

        public init(_ element: W3C_XML::W3C_XML.Element) throws(Error) {
            if let prefix = Sitemap.Scope.free(in: element).min() {
                throw .undeclared(prefix.isEmpty ? nil : prefix)
            }
            guard let uri = Sitemap.Scope().entering(element).namespace(of: element.name) else {
                throw .unqualified(element.name)
            }
            guard uri != Sitemap.namespace.uri else { throw .sitemap(element.name) }
            self.init(unchecked: element)
        }

        package init(unchecked element: W3C_XML::W3C_XML.Element) {
            var element = element
            element.namespaces.sort { Sitemap.Scope.key($0.prefix) < Sitemap.Scope.key($1.prefix) }
            self.element = element
        }
    }
}

extension Sitemap.Extension {

    public var namespace: W3C_XML::W3C_XML.Namespace {
        element.namespaces.first { $0.prefix == element.name.prefix } ?? W3C_XML::W3C_XML.Namespace(prefix: element.name.prefix, uri: "")
    }
}
