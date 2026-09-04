#if os(iOS)
import UIKit

public final class Bilboard {
    private let spacingBetweenLetters = 1
    public let horizontalVirtualPixelsAmount: Int
    public let verticalVirtualPixelsAmount: Int
    public let color: BilboardColor
    public let borderActive: Bool

    private let font: BilboardFont
    private let palette: BilboardPalette
    private let borderOffset: Int
    private let imageWidth: Int
    private let imageHeight: Int
    private var activePixels: Set<VirtualPixel>

    public init(
        horizontalVirtualPixelsAmount: Int,
        imageHeightInLines: Int,
        color: BilboardColor = .red,
        borderActive: Bool = false
    ) throws {
        guard horizontalVirtualPixelsAmount >= 0, imageHeightInLines >= 0 else {
            throw BilboardError.invalidCanvasSize
        }

        self.horizontalVirtualPixelsAmount = horizontalVirtualPixelsAmount
        self.verticalVirtualPixelsAmount = imageHeightInLines * 10
        self.color = color
        self.borderActive = borderActive
        self.borderOffset = borderActive ? 4 : 0
        self.imageWidth = horizontalVirtualPixelsAmount * 3 + 7 + 2 * self.borderOffset
        self.imageHeight = self.verticalVirtualPixelsAmount * 3 + 7 + 2 * self.borderOffset
        self.font = try BilboardFont.load()
        self.palette = BilboardPalette(color: color)
        self.activePixels = []
    }

    public func fillRandom(granularity: Int = 3) {
        let normalizedGranularity = max(0, granularity)

        for x in 0...self.horizontalVirtualPixelsAmount {
            for y in 0...self.verticalVirtualPixelsAmount where Int.random(in: 0...normalizedGranularity) == 0 {
                self.setBigPixel(x, y)
            }
        }
    }

    public func addLine(x1: Int, y1: Int, x2: Int, y2: Int, separator: Int = 1) {
        let step = max(1, separator)

        if y1 == y2 {
            for x in stride(from: min(x1, x2), through: max(x1, x2), by: step) {
                self.setBigPixel(x, y1)
            }
        }

        if x1 == x2 {
            for y in stride(from: min(y1, y2), through: max(y1, y2), by: step) {
                self.setBigPixel(x1, y)
            }
        }
    }

    public func setBigPixel(_ x: Int, _ y: Int) {
        guard self.isWithinBounds(x: x, y: y) else {
            return
        }

        self.activePixels.insert(VirtualPixel(x: x, y: y))
    }

    public func printLetter(_ letter: String, x: Int, y: Int) {
        let glyph = self.font.glyph(for: letter)

        for (rowIndex, row) in glyph.rows.enumerated() {
            for (columnIndex, isFilled) in row.enumerated() where isFilled {
                self.setBigPixel(x + columnIndex, 1 + y + rowIndex)
            }
        }
    }

    public func addSentenceLeft(_ sentence: String, xOffset: Int = 0, yOffset: Int = 0) {
        let normalizedSentence = sentence.replacingOccurrences(of: "\t", with: "  ")
        var offset = xOffset

        for scalar in normalizedSentence {
            let glyphKey = String(scalar)
            let glyph = self.font.glyph(for: glyphKey)
            self.printLetter(glyphKey, x: offset, y: yOffset * 10)
            offset += 1 + self.spacingBetweenLetters + glyph.width
        }
    }

    public func addSentenceRight(_ sentence: String, xOffsetRight: Int = 0, yOffset: Int = 0) {
        let width = self.countSentenceWidth(sentence)
        self.addSentenceLeft(sentence, xOffset: self.horizontalVirtualPixelsAmount - width - xOffsetRight, yOffset: yOffset)
    }

    public func addSentenceCenter(_ sentence: String, xOffsetRight: Int = 0, yOffset: Int = 0) {
        let width = self.countSentenceWidth(sentence)
        self.addSentenceLeft(
            sentence,
            xOffset: self.horizontalVirtualPixelsAmount / 2 - width / 2 - xOffsetRight,
            yOffset: yOffset
        )
    }

    public func addMultiSentence(_ sentence: String, xOffset: Int = 0, yOffset: Int = 0) {
        let parts = self.splitLongSentence(sentence, xOffset: xOffset).components(separatedBy: .newlines)

        for (index, part) in parts.enumerated() {
            self.addSentenceLeft(part, xOffset: xOffset, yOffset: yOffset + index)
        }
    }

    public func getImage() -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false

        return UIGraphicsImageRenderer(
            size: CGSize(width: self.imageWidth, height: self.imageHeight),
            format: format
        ).image { rendererContext in
            let context = rendererContext.cgContext
            self.renderBackground(in: context)
            self.renderActivePixels(in: context)
        }
    }

    public func drawFromPattern(_ pattern: String, x: Int, y: Int) {
        for (row, line) in pattern.split(separator: "\n").enumerated() {
            for (index, character) in line.enumerated() where character != " " {
                self.setBigPixel(x + index, y + row)
            }
        }
    }

    private func countSentenceWidth(_ sentence: String) -> Int {
        sentence.reduce(into: 0) { width, scalar in
            width += 1 + self.spacingBetweenLetters + self.font.glyph(for: String(scalar)).width
        }
    }

    private func splitLongSentence(_ sentence: String, xOffset: Int) -> String {
        let normalized = sentence.replacingOccurrences(of: "\n", with: " \n ")
        let words = normalized.split(separator: " ", omittingEmptySubsequences: false)
        var finalSentence = ""
        var sentenceLength = 0

        for wordSlice in words {
            let word = String(wordSlice)

            if word == "\n" {
                sentenceLength = 0
                finalSentence.append("\n")
                continue
            }

            let wordLength = self.countSentenceWidth(word)
            let interWordSpacing = sentenceLength == 0 ? 0 : 6

            if sentenceLength + interWordSpacing + xOffset + wordLength < self.horizontalVirtualPixelsAmount {
                if sentenceLength > 0 {
                    finalSentence.append(" ")
                }
                finalSentence.append(word)
                sentenceLength += interWordSpacing + wordLength
            } else {
                if !finalSentence.isEmpty {
                    finalSentence.append("\n")
                }
                finalSentence.append(word)
                sentenceLength = wordLength
            }
        }

        return finalSentence
    }

    private func renderBackground(in context: CGContext) {
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: self.imageWidth, height: self.imageHeight))

        if self.borderActive {
            let black = UIColor.black.cgColor
            context.setStrokeColor(black)
            context.setLineWidth(1)
            self.strokeLine(in: context, fromX: 4, fromY: 0, toX: self.imageWidth - 5, toY: 0)
            self.strokeLine(in: context, fromX: 2, fromY: 1, toX: self.imageWidth - 3, toY: 1)
            self.strokeLine(in: context, fromX: 1, fromY: 2, toX: self.imageWidth - 2, toY: 2)
            self.strokeLine(in: context, fromX: 1, fromY: 3, toX: self.imageWidth - 2, toY: 3)
            self.strokeLine(in: context, fromX: 4, fromY: self.imageHeight - 1, toX: self.imageWidth - 5, toY: self.imageHeight - 1)
            self.strokeLine(in: context, fromX: 2, fromY: self.imageHeight - 2, toX: self.imageWidth - 3, toY: self.imageHeight - 2)
            self.strokeLine(in: context, fromX: 1, fromY: self.imageHeight - 3, toX: self.imageWidth - 2, toY: self.imageHeight - 3)
            self.strokeLine(in: context, fromX: 1, fromY: self.imageHeight - 4, toX: self.imageWidth - 2, toY: self.imageHeight - 4)
            context.setFillColor(black)
            context.fill(CGRect(x: 0, y: 4, width: 5, height: self.imageHeight - 9))
            context.fill(CGRect(x: self.imageWidth - 4, y: 4, width: 4, height: self.imageHeight - 9))
        }

        self.fill(
            context,
            rect: CGRect(x: self.borderOffset, y: self.borderOffset, width: self.imageWidth - 2 * self.borderOffset, height: self.imageHeight - 2 * self.borderOffset),
            color: UIColor(red: 34 / 255, green: 34 / 255, blue: 34 / 255, alpha: 1)
        )
        if self.borderActive {
            context.setStrokeColor(UIColor(red: 102 / 255, green: 102 / 255, blue: 102 / 255, alpha: 1).cgColor)
            context.setLineWidth(1)
            self.strokeLine(in: context, fromX: self.borderOffset + 2, fromY: self.imageHeight - 2 - self.borderOffset, toX: self.imageWidth - 2 - self.borderOffset, toY: self.imageHeight - 2 - self.borderOffset)
            self.strokeLine(in: context, fromX: self.imageWidth - 2 - self.borderOffset, fromY: self.borderOffset + 2, toX: self.imageWidth - 2 - self.borderOffset, toY: self.imageHeight - 2 - self.borderOffset)
        }

        for x in 0...self.horizontalVirtualPixelsAmount {
            for y in 0...self.verticalVirtualPixelsAmount {
                self.renderVirtualPixel(in: context, x: x, y: y, light: self.palette.backgroundLight, dark: self.palette.backgroundDark)
            }
        }
    }

    private func renderActivePixels(in context: CGContext) {
        for pixel in self.activePixels {
            self.renderVirtualPixel(in: context, x: pixel.x, y: pixel.y, light: self.palette.pixelLight, dark: self.palette.pixelDark)
        }
    }

    private func renderVirtualPixel(in context: CGContext, x: Int, y: Int, light: UIColor, dark: UIColor) {
        let originX = self.borderOffset + 2 + 3 * x
        let originY = self.borderOffset + 2 + 3 * y
        self.fill(context, rect: CGRect(x: originX, y: originY, width: 1, height: 1), color: light)
        self.fill(context, rect: CGRect(x: originX + 1, y: originY, width: 1, height: 1), color: dark)
        self.fill(context, rect: CGRect(x: originX, y: originY + 1, width: 1, height: 1), color: dark)
        self.fill(context, rect: CGRect(x: originX + 1, y: originY + 1, width: 1, height: 1), color: dark)
    }

    private func fill(_ context: CGContext, rect: CGRect, color: UIColor) {
        context.setFillColor(color.cgColor)
        context.fill(rect)
    }

    private func strokeLine(in context: CGContext, fromX: Int, fromY: Int, toX: Int, toY: Int) {
        context.move(to: CGPoint(x: fromX, y: fromY))
        context.addLine(to: CGPoint(x: toX, y: toY))
        context.strokePath()
    }

    private func isWithinBounds(x: Int, y: Int) -> Bool {
        x >= 0 && x <= self.horizontalVirtualPixelsAmount && y >= 0 && y <= self.verticalVirtualPixelsAmount
    }
}

private struct VirtualPixel: Hashable {
    let x: Int
    let y: Int
}
#endif