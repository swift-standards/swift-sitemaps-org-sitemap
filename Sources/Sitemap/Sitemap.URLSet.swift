extension Sitemap {

    public struct URLSet: Sendable, Hashable {

        public let urls: [URL]

        public let extensions: [Extension]

        public let bytes: [UInt8]

        public init(_ urls: [URL], extensions: [Extension] = []) throws(Limit.Error) {
            guard Limit.entries.contains(urls.count) else { throw .entries(urls.count) }
            var writer = Writer()
            var content = extensions.map { writer.element($0) }
            for url in urls {
                content.append(url.element(&writer))
            }
            let bytes = writer.document("urlset", content)
            guard bytes.count <= Limit.bytes else { throw .bytes(bytes.count) }
            self.urls = urls
            self.extensions = extensions
            self.bytes = bytes
        }
    }
}

extension Sitemap.URLSet {

    public init(
        extensions: [Sitemap.Extension] = [],
        @Sitemap.Builder<Sitemap.URL> _ urls: () -> [Sitemap.URL]
    ) throws(Sitemap.Limit.Error) {
        try self.init(urls(), extensions: extensions)
    }

    public init(parsing bytes: [UInt8]) throws(Sitemap.Parse.Error) {
        let (root, scope) = try Sitemap.Reader.document(bytes, root: "urlset")
        var urls: [Sitemap.URL] = []
        var extensions: [Sitemap.Extension] = []
        for child in try Sitemap.Reader.children(of: root, in: scope) {
            guard child.isSitemap else {
                guard urls.isEmpty else { throw .unexpected(child.element.name, in: root.name) }
                extensions.append(try Sitemap.Reader.extension(child.element, in: child.scope))
                continue
            }
            guard child.element.name.local == "url" else { throw .unexpected(child.element.name, in: root.name) }
            urls.append(try Sitemap.Reader.url(child.element, in: child.scope))
        }
        do throws(Sitemap.Limit.Error) {
            try self.init(urls, extensions: extensions)
        } catch {
            throw .limit(error)
        }
    }
}
