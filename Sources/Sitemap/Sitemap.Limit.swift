extension Sitemap {

    public enum Limit {}
}

extension Sitemap.Limit {

    public static let entries: ClosedRange<Int> = 1...50_000

    public static let bytes = 52_428_800

    public static let location: Range<Int> = 12..<2_048
}
