public import RFC_3986

extension Sitemap.Location {

    public enum Error: Swift::Error, Sendable, Hashable {

        case uri(RFC_3986.Error)

        case relative(RFC_3986.URI)

        case length(Int)
    }
}
