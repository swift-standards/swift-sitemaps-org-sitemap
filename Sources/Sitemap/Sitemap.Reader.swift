import W3C_XML

extension Sitemap {

    enum Reader {}
}

extension Sitemap.Reader {

    static func document(_ bytes: [UInt8], root local: String) throws(Sitemap.Parse.Error) -> (W3C_XML::W3C_XML.Element, Sitemap.Scope) {
        guard bytes.count <= Sitemap.Limit.bytes else { throw .limit(.bytes(bytes.count)) }
        let document: W3C_XML::W3C_XML.Document
        do throws(W3C_XML::W3C_XML.Parse.Error) {
            document = try W3C_XML::W3C_XML.parse(bytes)
        } catch {
            throw .xml(error)
        }
        if let encoding = document.declaration?.encoding, encoding.lowercased() != "utf-8" {
            throw .encoding(encoding)
        }
        let scope = Sitemap.Scope().entering(document.root)
        guard try namespace(of: document.root.name, in: scope) == Sitemap.namespace.uri,
            document.root.name.local == local
        else {
            throw .unexpected(document.root.name, in: nil)
        }
        return (document.root, scope)
    }

    static func namespace(of name: W3C_XML::W3C_XML.Name, in scope: Sitemap.Scope) throws(Sitemap.Parse.Error) -> String? {
        if let prefix = name.prefix, scope.bindings[prefix] == nil {
            throw .undeclared(prefix)
        }
        return scope.namespace(of: name)
    }

    static func children(of element: W3C_XML::W3C_XML.Element, in scope: Sitemap.Scope) throws(Sitemap.Parse.Error) -> [Child] {
        var children: [Child] = []
        for item in element.content {
            switch item {
            case .text(let text), .cdata(let text):
                guard text.utf8.allSatisfy(isWhitespace) else { throw .text(in: element.name) }

            case .comment, .instruction:
                continue

            case .element(let child):
                let inner = scope.entering(child)
                guard let uri = try namespace(of: child.name, in: inner) else {
                    throw .unexpected(child.name, in: element.name)
                }
                children.append(Child(element: child, scope: inner, isSitemap: uri == Sitemap.namespace.uri))
            }
        }
        return children
    }

    static func isWhitespace(_ byte: UInt8) -> Bool {
        byte == 0x20 || byte == 0x09 || byte == 0x0A || byte == 0x0D
    }

    static func value(_ element: W3C_XML::W3C_XML.Element) throws(Sitemap.Parse.Error) -> String {
        if let child = element.children.first {
            throw .unexpected(child.name, in: element.name)
        }
        let bytes = Array(element.textContent.utf8)
        let start = bytes.firstIndex { !isWhitespace($0) } ?? bytes.endIndex
        let end = bytes.lastIndex { !isWhitespace($0) }.map { $0 + 1 } ?? start
        return String(decoding: bytes[start..<max(start, end)], as: UTF8.self)
    }

    static func `extension`(_ element: W3C_XML::W3C_XML.Element, in scope: Sitemap.Scope) throws(Sitemap.Parse.Error) -> Sitemap.Extension {
        var element = element
        for prefix in Sitemap.Scope.free(in: element).sorted() {
            guard let uri = scope.bindings[prefix] else { continue }
            element.namespaces.append(W3C_XML::W3C_XML.Namespace(prefix: prefix.isEmpty ? nil : prefix, uri: uri))
        }
        do throws(Sitemap.Extension.Error) {
            return try Sitemap.Extension(element)
        } catch {
            throw .extension(error)
        }
    }
}

extension Sitemap.Reader {

    static func url(_ element: W3C_XML::W3C_XML.Element, in scope: Sitemap.Scope) throws(Sitemap.Parse.Error) -> Sitemap.URL {
        let fields = try self.fields(of: element, in: scope, order: ["loc", "lastmod", "changefreq", "priority"])
        var url = Sitemap.URL(try location(fields.values["loc"], in: element.name), extensions: fields.extensions)
        if let text = fields.values["lastmod"] {
            url.modified = try modified(text)
        }
        if let text = fields.values["changefreq"] {
            guard let frequency = Sitemap.Frequency(text) else { throw .frequency(text) }
            url.frequency = frequency
        }
        if let text = fields.values["priority"] {
            do throws(Sitemap.Priority.Error) {
                url.priority = try Sitemap.Priority(text)
            } catch {
                throw .priority(error)
            }
        }
        return url
    }

    static func entry(_ element: W3C_XML::W3C_XML.Element, in scope: Sitemap.Scope) throws(Sitemap.Parse.Error) -> Sitemap.Index.Entry {
        let fields = try self.fields(of: element, in: scope, order: ["loc", "lastmod"])
        var entry = Sitemap.Index.Entry(try location(fields.values["loc"], in: element.name), extensions: fields.extensions)
        if let text = fields.values["lastmod"] {
            entry.modified = try modified(text)
        }
        return entry
    }

    static func fields(
        of element: W3C_XML::W3C_XML.Element,
        in scope: Sitemap.Scope,
        order: [String]
    ) throws(Sitemap.Parse.Error) -> (values: [String: String], extensions: [Sitemap.Extension]) {
        var values: [String: String] = [:]
        var extensions: [Sitemap.Extension] = []
        var stage = -1
        for child in try children(of: element, in: scope) {
            guard child.isSitemap else {
                guard stage >= 0 else { throw .missing(W3C_XML::W3C_XML.Name(local: "loc"), in: element.name) }
                stage = order.count
                extensions.append(try self.extension(child.element, in: child.scope))
                continue
            }
            guard let position = order.firstIndex(of: child.element.name.local), position > stage else {
                throw .unexpected(child.element.name, in: element.name)
            }
            guard stage >= 0 || position == 0 else { throw .missing(W3C_XML::W3C_XML.Name(local: "loc"), in: element.name) }
            stage = position
            values[child.element.name.local] = try value(child.element)
        }
        return (values, extensions)
    }

    static func location(_ text: String?, in parent: W3C_XML::W3C_XML.Name) throws(Sitemap.Parse.Error) -> Sitemap.Location {
        guard let text else { throw .missing(W3C_XML::W3C_XML.Name(local: "loc"), in: parent) }
        do throws(Sitemap.Location.Error) {
            return try Sitemap.Location(text)
        } catch {
            throw .location(error)
        }
    }

    static func modified(_ text: String) throws(Sitemap.Parse.Error) -> Sitemap.Datetime {
        do throws(Sitemap.Datetime.Error) {
            return try Sitemap.Datetime(text)
        } catch {
            throw .modified(error)
        }
    }
}
