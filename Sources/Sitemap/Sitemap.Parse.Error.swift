public import W3C_XML

extension Sitemap.Parse {

    public enum Error: Swift::Error, Sendable, Equatable {

        case xml(W3C.XML.Parse.Error)

        case encoding(String)

        case limit(Sitemap.Limit.Error)

        case undeclared(String)

        case unexpected(W3C.XML.Name, in: W3C.XML.Name?)

        case text(in: W3C.XML.Name)

        case missing(W3C.XML.Name, in: W3C.XML.Name)

        case location(Sitemap.Location.Error)

        case modified(Sitemap.Datetime.Error)

        case frequency(String)

        case priority(Sitemap.Priority.Error)

        case `extension`(Sitemap.Extension.Error)
    }
}
