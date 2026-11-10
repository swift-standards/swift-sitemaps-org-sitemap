public import BCP_47
public import Sitemap
public import W3C_XML

extension Sitemap.Alternate {

    public enum Error: Swift::Error, Sendable, Equatable {

        case link(W3C_XML.Name)

        case missing(String)

        case language(BCP47.Error)

        case location(Sitemap.Location.Error)
    }
}
