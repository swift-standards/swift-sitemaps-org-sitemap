public import W3C_XML

extension Sitemap.Parse {

    public enum Error: Swift::Error, Sendable, Equatable {

        case xml(W3C_XML::W3C_XML.Parse.Error)

        case encoding(String)

        case limit(Sitemap.Limit.Error)

        case undeclared(String)

        case unexpected(W3C_XML::W3C_XML.Name, in: W3C_XML::W3C_XML.Name?)

        case text(in: W3C_XML::W3C_XML.Name)

        case missing(W3C_XML::W3C_XML.Name, in: W3C_XML::W3C_XML.Name)

        case location(Sitemap.Location.Error)

        case modified(Sitemap.Datetime.Error)

        case frequency(String)

        case priority(Sitemap.Priority.Error)

        case `extension`(Sitemap.Extension.Error)
    }
}
