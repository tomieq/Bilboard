import Foundation
import SwiftGD

public final class Bilboard {
    private let spacingBetweenLetters = 1
    public let horizontalVirtualPixelsAmount: Int
    public let verticalVirtualPixelsAmount: Int
    public let colorSign: BilboardColorSign
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
        colorSign: BilboardColorSign = .red,
        borderActive: Bool = false
    ) throws {
        guard horizontalVirtualPixelsAmount >= 0, imageHeightInLines >= 0 else {
            throw BilboardError.invalidCanvasSize
        }

        self.horizontalVirtualPixelsAmount = horizontalVirtualPixelsAmount
        self.verticalVirtualPixelsAmount = imageHeightInLines * 10
        self.colorSign = colorSign
        self.borderActive = borderActive
        self.borderOffset = borderActive ? 4 : 0
        self.imageWidth = horizontalVirtualPixelsAmount * 3 + 7 + 2 * self.borderOffset
        self.imageHeight = self.verticalVirtualPixelsAmount * 3 + 7 + 2 * self.borderOffset
        self.font = try BilboardFont.load()
        self.palette = BilboardPalette(sign: colorSign)
        self.activePixels = []
    }

    public func fillRandom(granularity: Int = 3) {
        let normalizedGranularity = max(0, granularity)

        for x in 0...self.horizontalVirtualPixelsAmount {
            for y in 0...self.verticalVirtualPixelsAmount {
                if Int.random(in: 0...normalizedGranularity) == 0 {
                    self.setBigPixel(x, y)
                }
            }
        }
    }

    public func addLine(x1: Int, y1: Int, x2: Int, y2: Int, separator: Int = 1) {
        let step = max(1, separator)

        if y1 == y2 {
            let start = min(x1, x2)
            let end = max(x1, x2)

            for x in stride(from: start, through: end, by: step) {
                self.setBigPixel(x, y1)
            }
        }

        if x1 == x2 {
            let start = min(y1, y2)
            let end = max(y1, y2)

            for y in stride(from: start, through: end, by: step) {
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
                setBigPixel(x + columnIndex, 1 + y + rowIndex)
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
        let parts = self.splitLongSentence(sentence, xOffset: xOffset)
            .components(separatedBy: .newlines)

        for (index, part) in parts.enumerated() {
            self.addSentenceLeft(part, xOffset: xOffset, yOffset: yOffset + index)
        }
    }

    public func getImage() throws -> Data {
        guard let image = Image(width: imageWidth, height: imageHeight) else {
            throw BilboardError.imageCreationFailed
        }

        image.transparent = true

        self.renderBackground(on: image)
        self.renderActivePixels(on: image)

        do {
            return try image.export(as: .png)
        } catch {
            throw BilboardError.pngExportFailed
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

    private func renderBackground(on image: Image) {
        image.fillRectangle(
            topLeft: Point(x: 0, y: 0),
            bottomRight: Point(x: self.imageWidth - 1, y: self.imageHeight - 1),
            color: BilboardPalette.rgb(0, 0, 0, alpha: 0)
        )

        if self.borderActive {
            let black = BilboardPalette.rgb(0, 0, 0)

            image.drawLine(from: Point(x: 4, y: 0), to: Point(x: self.imageWidth - 5, y: 0), color: black)
            image.drawLine(from: Point(x: 2, y: 1), to: Point(x: self.imageWidth - 3, y: 1), color: black)
            image.drawLine(from: Point(x: 1, y: 2), to: Point(x: self.imageWidth - 2, y: 2), color: black)
            image.drawLine(from: Point(x: 1, y: 3), to: Point(x: self.imageWidth - 2, y: 3), color: black)

            image.drawLine(from: Point(x: 4, y: self.imageHeight - 1), to: Point(x: self.imageWidth - 5, y: self.imageHeight - 1), color: black)
            image.drawLine(from: Point(x: 2, y: self.imageHeight - 2), to: Point(x: self.imageWidth - 3, y: self.imageHeight - 2), color: black)
            image.drawLine(from: Point(x: 1, y: self.imageHeight - 3), to: Point(x: self.imageWidth - 2, y: self.imageHeight - 3), color: black)
            image.drawLine(from: Point(x: 1, y: self.imageHeight - 4), to: Point(x: self.imageWidth - 2, y: self.imageHeight - 4), color: black)

            image.fillRectangle(
                topLeft: Point(x: 0, y: 4),
                bottomRight: Point(x: 4, y: self.imageHeight - 5),
                color: black
            )
            image.fillRectangle(
                topLeft: Point(x: self.imageWidth - 4, y: 4),
                bottomRight: Point(x: self.imageWidth - 1, y: self.imageHeight - 5),
                color: black
            )
        }

        image.fillRectangle(
            topLeft: Point(x: self.borderOffset, y: self.borderOffset),
            bottomRight: Point(x: self.imageWidth - 1 - self.borderOffset, y: self.imageHeight - 1 - self.borderOffset),
            color: BilboardPalette.rgb(34, 34, 34)
        )
        image.drawLine(
            from: Point(x: self.borderOffset + 2, y: self.imageHeight - 2 - self.borderOffset),
            to: Point(x: self.imageWidth - 2 - self.borderOffset, y: self.imageHeight - 2 - self.borderOffset),
            color: BilboardPalette.rgb(102, 102, 102)
        )
        image.drawLine(
            from: Point(x: self.imageWidth - 2 - self.borderOffset, y: self.borderOffset + 2),
            to: Point(x: self.imageWidth - 2 - self.borderOffset, y: self.imageHeight - 2 - self.borderOffset),
            color: BilboardPalette.rgb(102, 102, 102)
        )

        for x in 0...self.horizontalVirtualPixelsAmount {
            for y in 0...self.verticalVirtualPixelsAmount {
                self.renderVirtualPixel(on: image, x: x, y: y, light: self.palette.backgroundLight, dark: self.palette.backgroundDark)
            }
        }
    }

    private func renderActivePixels(on image: Image) {
        for pixel in self.activePixels {
            self.renderVirtualPixel(on: image, x: pixel.x, y: pixel.y, light: self.palette.pixelLight, dark: self.palette.pixelDark)
        }
    }

    private func renderVirtualPixel(on image: Image, x: Int, y: Int, light: Color, dark: Color) {
        let pixelOffset = self.borderOffset + 2
        let originX = pixelOffset + 3 * x
        let originY = pixelOffset + 3 * y

        image.set(pixel: Point(x: originX, y: originY), to: light)
        image.set(pixel: Point(x: originX + 1, y: originY), to: dark)
        image.set(pixel: Point(x: originX, y: originY + 1), to: dark)
        image.set(pixel: Point(x: originX + 1, y: originY + 1), to: dark)
    }

    private func isWithinBounds(x: Int, y: Int) -> Bool {
        x >= 0 && x <= self.horizontalVirtualPixelsAmount && y >= 0 && y <= self.verticalVirtualPixelsAmount
    }
}

private struct VirtualPixel: Hashable {
    let x: Int
    let y: Int
}
