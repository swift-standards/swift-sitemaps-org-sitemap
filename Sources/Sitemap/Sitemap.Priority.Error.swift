extension Sitemap.Priority {

    public enum Error: Swift::Error, Sendable, Hashable {

        case decimal(String)

        case range(String)

        case scale(String)
    }
}
