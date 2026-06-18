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

        let content: String

        do {
            content = try String(contentsOf: url, encoding: .utf8)
        } catch {
            throw BilboardError.fontResourceUnreadable
        }

        return BilboardFont(glyphs: self.parse(content))
    }

    func glyph(for key: String) -> Glyph {
        if let glyph = glyphs[key] {
            return glyph
        }

        if let fallback = glyphs[Self.fallbackKey] {
            return fallback
        }

        return Glyph(width: Self.fallbackWidth, rows: [])
    }

    private static func parse(_ content: String) -> [String: Glyph] {
        let normalized = content.replacingOccurrences(of: "\r\n", with: "\n")
        let lines = normalized.components(separatedBy: "\n")
        var glyphs: [String: Glyph] = [:]
        var index = 0

        while index < lines.count {
            let line = lines[index]

            guard line.hasPrefix("-----") else {
                index += 1
                continue
            }

            let key = String(line.dropFirst(5))
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