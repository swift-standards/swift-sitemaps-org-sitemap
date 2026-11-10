import Testing

@testable import Sitemap

enum `Sitemap.Priority Tests` {}

extension `Sitemap.Priority Tests` {
    @Suite
    struct `Priority` {
        @Test(arguments: [("0.8", "0.8"), ("1", "1.0"), ("0", "0.0"), ("0.50", "0.5"), ("+.25", "0.25"), ("-0.0", "0.0"), ("1.000", "1.0"), ("00.125", "0.125")])
        func `decimals from 0 to 1 are written canonically`(_ text: String, _ written: String) throws {
            #expect(try Sitemap.Priority(text).description == written)
        }

        @Test(arguments: ["1.01", "-0.1", "2"])
        func `values outside 0 to 1 are refused`(_ text: String) {
            #expect(throws: Sitemap.Priority.Error.range(text)) {
                _ = try Sitemap.Priority(text)
            }
        }

        @Test(arguments: ["", ".", "0.5.", "1e-1", "0,5", " 0.5", "abc"])
        func `text that is not a decimal is refused`(_ text: String) {
            #expect(throws: Sitemap.Priority.Error.decimal(text)) {
                _ = try Sitemap.Priority(text)
            }
        }

        @Test
        func `at most eighteen fraction digits are kept`() throws {
            #expect(try Sitemap.Priority("0." + String(repeating: "1", count: 18)).description.count == 20)
            #expect(throws: Sitemap.Priority.Error.scale("0." + String(repeating: "1", count: 19))) {
                _ = try Sitemap.Priority("0." + String(repeating: "1", count: 19))
            }
        }

        @Test
        func `a double is taken at its shortest decimal`() throws {
            #expect(try Sitemap.Priority(0.8).description == "0.8")
            #expect(try Sitemap.Priority(0.00001).description == "0.00001")
            #expect(throws: Sitemap.Priority.Error.range("1.5")) {
                _ = try Sitemap.Priority(1.5)
            }
        }

        @Test
        func `priorities order by value`() throws {
            #expect(try Sitemap.Priority("0.25") < Sitemap.Priority("0.3"))
            #expect(try Sitemap.Priority("0.30") == Sitemap.Priority("0.3"))
            #expect(try Sitemap.Priority("1") > Sitemap.Priority("0.999"))
        }
    }
}
