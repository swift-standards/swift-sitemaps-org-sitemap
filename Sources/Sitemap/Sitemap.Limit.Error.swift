extension Sitemap.Limit {

    public enum Error: Swift::Error, Sendable, Hashable {

        case entries(Int)

        case bytes(Int)
    }
}
