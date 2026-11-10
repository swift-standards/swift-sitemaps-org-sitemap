public import W3C_XML

public enum Sitemap {}

extension Sitemap {

    public static let namespace = W3C_XML::W3C_XML.Namespace(uri: "http://www.sitemaps.org/schemas/sitemap/0.9")

    static let options = W3C_XML::W3C_XML.Options(
        prettyPrint: false,
        includeDeclaration: true,
        escapeApostrophe: true,
        escapeQuotesInText: true
    )

    static let declaration = W3C_XML::W3C_XML.Declaration(version: .v1_0, encoding: "UTF-8")

    static func escaped(_ text: String) -> [UInt8] {
        guard !text.isEmpty else { return [] }
        let encoded = W3C_XML::W3C_XML.Element(name: "x", content: [.text(text)]).encode(options: options)
        return Array(encoded.dropFirst(3).dropLast(4))
    }
}
