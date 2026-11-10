extension Sitemap {

    public struct Index: Sendable, Hashable {

        public let entries: [Entry]

        public let extensions: [Extension]

        public let bytes: [UInt8]

        public init(_ entries: [Entry], extensions: [Extension] = []) throws(Limit.Error) {
            guard Limit.entries.contains(entries.count) else { throw .entries(entries.count) }
            var writer = Writer()
            var content = extensions.map { writer.element($0) }
            for entry in entries {
                content.append(entry.element(&writer))
            }
            let bytes = writer.document("sitemapindex", content)
            guard bytes.count <= Limit.bytes else { throw .bytes(bytes.count) }
            self.entries = entries
            self.extensions = extensions
            self.bytes = bytes
        }
    }
}

extension Sitemap.Index {

    public init(
        extensions: [Sitemap.Extension] = [],
        @Sitemap.Builder<Sitemap.Index.Entry> _ entries: () -> [Sitemap.Index.Entry]
    ) throws(Sitemap.Limit.Error) {
        try self.init(entries(), extensions: extensions)
    }

    public init(parsing bytes: [UInt8]) throws(Sitemap.Parse.Error) {
        let (root, scope) = try Sitemap.Reader.document(bytes, root: "sitemapindex")
        var entries: [Sitemap.Index.Entry] = []
        var extensions: [Sitemap.Extension] = []
        for child in try Sitemap.Reader.children(of: root, in: scope) {
            guard child.isSitemap else {
                guard entries.isEmpty else { throw .unexpected(child.element.name, in: root.name) }
                extensions.append(try Sitemap.Reader.extension(child.element, in: child.scope))
                continue
            }
            guard child.element.name.local == "sitemap" else { throw .unexpected(child.element.name, in: root.name) }
            entries.append(try Sitemap.Reader.entry(child.element, in: child.scope))
        }
        do throws(Sitemap.Limit.Error) {
            try self.init(entries, extensions: extensions)
        } catch {
            throw .limit(error)
        }
    }
}
