import W3C_XML

extension Sitemap {

    struct Writer {

        var namespaces: [W3C_XML::W3C_XML.Namespace] = [Sitemap.namespace]
    }
}

extension Sitemap.Writer {

    mutating func element(_ extension: Sitemap.Extension) -> W3C_XML::W3C_XML.Element {
        var element = `extension`.element
        element.namespaces = element.namespaces.filter { namespace in
            guard let prefix = namespace.prefix else { return true }
            if let bound = namespaces.first(where: { $0.prefix == prefix }) {
                return bound.uri != namespace.uri
            }
            namespaces.append(namespace)
            return false
        }
        return element
    }

    static func element(_ local: String, _ text: String) -> W3C_XML::W3C_XML.Element {
        W3C_XML::W3C_XML.Element(name: W3C_XML::W3C_XML.Name(local: local), content: [.text(text)])
    }

    func document(_ local: String, _ content: [W3C_XML::W3C_XML.Element]) -> [UInt8] {
        let root = W3C_XML::W3C_XML.Element(
            name: W3C_XML::W3C_XML.Name(local: local),
            content: content.map { .element($0) },
            namespaces: namespaces
        )
        return W3C_XML::W3C_XML.Document(declaration: Sitemap.declaration, root: root).encode(options: Sitemap.options)
    }
}
