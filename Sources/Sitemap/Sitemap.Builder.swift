extension Sitemap {

    @resultBuilder
    public enum Builder<Element> {

        public static func buildExpression(_ element: Element) -> [Element] { [element] }

        public static func buildExpression(_ elements: [Element]) -> [Element] { elements }

        public static func buildBlock(_ components: [Element]...) -> [Element] { components.flatMap(\.self) }

        public static func buildOptional(_ component: [Element]?) -> [Element] { component ?? [] }

        public static func buildEither(first component: [Element]) -> [Element] { component }

        public static func buildEither(second component: [Element]) -> [Element] { component }

        public static func buildArray(_ components: [[Element]]) -> [Element] { components.flatMap(\.self) }

        public static func buildLimitedAvailability(_ component: [Element]) -> [Element] { component }
    }
}
