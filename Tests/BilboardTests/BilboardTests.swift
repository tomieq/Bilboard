import Foundation
import Testing
import SwiftGD
@testable import Bilboard

@Test func exportsExpectedPNGDimensions() throws {
    let bilboard = try Bilboard(
        horizontalVirtualPixelsAmount: 20,
        imageHeightInLines: 2,
        colorSign: .blue,
        borderActive: true
    )

    let data = try bilboard.getImage()
    let image = try Image(data: data, as: .png)

    #expect(image.size.width == 75)
    #expect(image.size.height == 75)
}

@Test func rendersSentencePixelsUsingBundledFont() throws {
    let bilboard = try Bilboard(horizontalVirtualPixelsAmount: 20, imageHeightInLines: 1)
    bilboard.addSentenceLeft("A")

    let image = try Image(data: bilboard.getImage(), as: .png)
    let litPixel = image.get(pixel: Point(x: 5, y: 5))
    let darkPixel = image.get(pixel: Point(x: 6, y: 5))

    assertColor(litPixel, red: 1, green: 102.0 / 255.0, blue: 102.0 / 255.0)
    assertColor(darkPixel, red: 1, green: 0, blue: 0)
}

@Test func leavesOneVirtualPixelBetweenLetters() throws {
    let bilboard = try Bilboard(horizontalVirtualPixelsAmount: 20, imageHeightInLines: 1)
    bilboard.addSentenceLeft("HH")

    let image = try Image(data: bilboard.getImage(), as: .png)

    let separatorLight = image.get(pixel: Point(x: 17, y: 8))
    let separatorDark = image.get(pixel: Point(x: 18, y: 8))

    assertColor(separatorLight, red: 136.0 / 255.0, green: 0, blue: 0)
    assertColor(separatorDark, red: 102.0 / 255.0, green: 0, blue: 0)
}


private func assertColor(_ color: Color, red: Double, green: Double, blue: Double, tolerance: Double = 0.02) {
    #expect(abs(color.redComponent - red) < tolerance)
    #expect(abs(color.greenComponent - green) < tolerance)
    #expect(abs(color.blueComponent - blue) < tolerance)
}
