import Foundation

final class BilboardFont {
    struct Glyph {
        let width: Int
        let rows: [[Bool]]
    }

    private static let fallbackWidth = 5
    private static let fallbackKey = "++"
    private let glyphs: [String: Glyph]

    private init(glyphs: [String: Glyph]) {
        self.glyphs = glyphs
    }

    static func load() throws -> BilboardFont {
        guard let url = Bundle.module.url(forResource: "fonts", withExtension: "txt") else {
            throw BilboardError.fontResourceMissing
        }

        do {
            return BilboardFont(glyphs: self.parse(try String(contentsOf: url, encoding: .utf8)))
        } catch {
            throw BilboardError.fontResourceUnreadable
        }
    }

    func glyph(for key: String) -> Glyph {
        self.glyphs[key] ?? self.glyphs[Self.fallbackKey] ?? Glyph(width: Self.fallbackWidth, rows: [])
    }

    private static func parse(_ content: String) -> [String: Glyph] {
        let lines = content.replacingOccurrences(of: "\r\n", with: "\n").components(separatedBy: "\n")
        var glyphs: [String: Glyph] = [:]
        var index = 0

        while index < lines.count {
            guard lines[index].hasPrefix("-----") else {
                index += 1
                continue
            }

            let key = String(lines[index].dropFirst(5))
            index += 1
            var rows: [[Bool]] = []
            var width = 0

            while index < lines.count, !lines[index].hasPrefix("-----") {
                let row = lines[index]
                rows.append(row.map { $0 == "x" })
                width = max(width, max(0, row.count - 1))
                index += 1
            }

            glyphs[key] = Glyph(width: width, rows: rows)
        }

        return glyphs
    }
}