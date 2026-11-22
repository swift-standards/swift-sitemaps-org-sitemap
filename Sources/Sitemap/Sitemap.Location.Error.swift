public import RFC_3986

extension Sitemap.Location {

    public enum Error: Swift::Error, Sendable, Hashable {

        case uri(IETF.RFC.`3986`.Error)

        case relative(IETF.RFC.`3986`.URI)

        case length(Int)
    }
}
