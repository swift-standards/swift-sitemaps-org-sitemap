extension Sitemap {

    public enum Frequency: Sendable, Hashable, CaseIterable {

        case always

        case hourly

        case daily

        case weekly

        case monthly

        case yearly

        case never
    }
}

extension Sitemap.Frequency {

    public init?(_ text: some StringProtocol) {
        guard let frequency = Self.allCases.first(where: { $0.description == text }) else { return nil }
        self = frequency
    }
}

extension Sitemap.Frequency: CustomStringConvertible {

    public var description: String {
        switch self {
        case .always: "always"
        case .hourly: "hourly"
        case .daily: "daily"
        case .weekly: "weekly"
        case .monthly: "monthly"
        case .yearly: "yearly"
        case .never: "never"
        }
    }
}
