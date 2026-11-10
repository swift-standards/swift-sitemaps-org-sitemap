import W3C_XML

extension Sitemap {

    struct Scope {

        var bindings: [String: String]

        init() {
            self.bindings = ["xml": W3C_XML::W3C_XML.Namespace.xml.uri]
        }
    }
}

extension Sitemap.Scope {

    static func key(_ prefix: String?) -> String { prefix ?? "" }

    func entering(_ element: W3C_XML::W3C_XML.Element) -> Self {
        var scope = self
        for namespace in element.namespaces {
            scope.bindings[Self.key(namespace.prefix)] = namespace.uri
        }
        return scope
    }

    func namespace(of name: W3C_XML::W3C_XML.Name) -> String? {
        guard let uri = bindings[Self.key(name.prefix)], !uri.isEmpty else { return nil }
        return uri
    }

    static func free(in element: W3C_XML::W3C_XML.Element, declared outer: Set<String> = ["xml"]) -> Set<String> {
        var declared = outer
        for namespace in element.namespaces {
            declared.insert(key(namespace.prefix))
        }
        var free: Set<String> = []
        if !declared.contains(key(element.name.prefix)) {
            free.insert(key(element.name.prefix))
        }
        for attribute in element.attributes {
            if let prefix = attribute.name.prefix, !declared.contains(prefix) {
                free.insert(prefix)
            }
        }
        for child in element.children {
            free.formUnion(Self.free(in: child, declared: declared))
        }
        return free
    }
}
