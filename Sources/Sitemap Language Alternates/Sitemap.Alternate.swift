public import Sitemap
public import W3C_XML

extension Sitemap {

    public struct Alternate: Sendable, Hashable {

        public let language: Language

        public let location: Sitemap.Location

        public init(_ language: Language, _ location: Sitemap.Location) {
            self.language = language
            self.location = location
        }
    }
}

extension Sitemap.Alternate {

    public static let namespace = W3C_XML::W3C_XML.Namespace(prefix: "xhtml", uri: "http://www.w3.org/1999/xhtml")

    static func isAlternate(_ extension: Sitemap.Extension) -> Bool {
        `extension`.namespace.uri == namespace.uri
            && `extension`.element.name.local == "link"
            && `extension`.element.attribute("rel") == "alternate"
    }

    public init(_ extension: Sitemap.Extension) throws(Error) {
        guard Self.isAlternate(`extension`) else { throw .link(`extension`.element.name) }
        guard let hreflang = `extension`.element.attribute("hreflang") else { throw .missing("hreflang") }
        guard let href = `extension`.element.attribute("href") else { throw .missing("href") }
        let language: Language
        do throws(BCP47.Error) {
            language = try Language(hreflang)
        } catch {
            throw .language(error)
        }
        do throws(Sitemap.Location.Error) {
            self.init(language, try Sitemap.Location(href))
        } catch {
            throw .location(error)
        }
    }
}
