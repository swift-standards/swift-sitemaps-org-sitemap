public import BCP_47
public import Sitemap

extension Sitemap.Alternate {

    public enum Language: Sendable, Hashable {

        case tag(BCP47.LanguageTag)

        case `default`
    }
}

extension Sitemap.Alternate.Language {

    public init(_ text: some StringProtocol) throws(BCP47.Error) {
        guard text.lowercased() != "x-default" else {
            self = .default
            return
        }
        self = .tag(try BCP47.LanguageTag(text))
    }
}

extension Sitemap.Alternate.Language: CustomStringConvertible {

    public var description: String {
        switch self {
        case .tag(let tag): tag.value
        case .default: "x-default"
        }
    }
}
