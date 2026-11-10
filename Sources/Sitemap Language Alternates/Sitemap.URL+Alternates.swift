public import BCP_47
public import Sitemap

extension Sitemap.URL {

    public init(
        _ location: Sitemap.Location,
        modified: Sitemap.Datetime? = nil,
        frequency: Sitemap.Frequency? = nil,
        priority: Sitemap.Priority? = nil,
        alternates: [BCP47.LanguageTag: Sitemap.Location],
        default: Sitemap.Location? = nil,
        extensions: [Sitemap.Extension] = []
    ) {
        var links =
            alternates
            .sorted { $0.key.value < $1.key.value }
            .map { Sitemap.Alternate(.tag($0.key), $0.value) }
        if let `default` {
            links.append(Sitemap.Alternate(.default, `default`))
        }
        self.init(
            location,
            modified: modified,
            frequency: frequency,
            priority: priority,
            extensions: links.map(Sitemap.Extension.init) + extensions
        )
    }

    public var alternates: [Sitemap.Alternate] {
        get throws(Sitemap.Alternate.Error) {
            var alternates: [Sitemap.Alternate] = []
            for item in extensions where Sitemap.Alternate.isAlternate(item) {
                alternates.append(try Sitemap.Alternate(item))
            }
            return alternates
        }
    }
}
