import W3C_XML

extension Sitemap.Reader {

    struct Child {

        let element: W3C_XML::W3C_XML.Element

        let scope: Sitemap.Scope

        let isSitemap: Bool
    }
}
