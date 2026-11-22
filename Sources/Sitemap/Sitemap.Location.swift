public import RFC_3986

extension Sitemap {

    public struct Location: Sendable, Hashable {

        public let uri: IETF.RFC.`3986`.URI

        public init(_ uri: IETF.RFC.`3986`.URI) throws(Error) {
            guard !uri.isRelative else { throw .relative(uri) }
            let length = Sitemap.escaped(uri.value).count
            guard Sitemap.Limit.location.contains(length) else { throw .length(length) }
            self.uri = uri
        }

        package init(unchecked uri: IETF.RFC.`3986`.URI) {
            self.uri = uri
        }
    }
}

extension Sitemap.Location {

    public init(_ text: some StringProtocol) throws(Error) {
        let uri: IETF.RFC.`3986`.URI
        do throws(IETF.RFC.`3986`.Error) {
            uri = try IETF.RFC.`3986`.URI(text)
        } catch {
            throw .uri(error)
        }
        try self.init(uri)
    }
}

extension Sitemap.Location: CustomStringConvertible {

    public var description: String { uri.value }
}
