public import W3C_XML

extension Sitemap.Extension {

    public enum Error: Swift::Error, Sendable, Hashable {

        case undeclared(String?)

        case unqualified(W3C_XML::W3C_XML.Name)

        case sitemap(W3C_XML::W3C_XML.Name)
    }
}
