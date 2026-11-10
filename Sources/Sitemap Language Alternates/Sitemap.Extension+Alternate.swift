public import Sitemap
import W3C_XML

extension Sitemap.Extension {

    public init(_ alternate: Sitemap.Alternate) {
        self.init(
            unchecked: W3C_XML::W3C_XML.Element(
                name: W3C_XML::W3C_XML.Name(local: "link", prefix: Sitemap.Alternate.namespace.prefix),
                attributes: [
                    W3C_XML::W3C_XML.Attribute(name: "rel", value: "alternate"),
                    W3C_XML::W3C_XML.Attribute(name: "hreflang", value: alternate.language.description),
                    W3C_XML::W3C_XML.Attribute(name: "href", value: alternate.location.uri.value),
                ],
                namespaces: [Sitemap.Alternate.namespace]
            )
        )
    }
}
