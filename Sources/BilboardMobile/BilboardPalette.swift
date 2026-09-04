#if os(iOS)
import UIKit

struct BilboardPalette {
    let pixelLight: UIColor
    let pixelDark: UIColor
    let backgroundLight: UIColor
    let backgroundDark: UIColor

    init(color: BilboardColor) {
        switch color {
        case .red: (pixelLight, pixelDark, backgroundLight, backgroundDark) = Self.colors(255, 102, 102, 255, 0, 0, 136, 0, 0, 102, 0, 0)
        case .green: (pixelLight, pixelDark, backgroundLight, backgroundDark) = Self.colors(160, 254, 104, 97, 255, 1, 51, 136, 0, 38, 102, 0)
        case .orange: (pixelLight, pixelDark, backgroundLight, backgroundDark) = Self.colors(254, 192, 104, 255, 150, 1, 136, 80, 0, 102, 60, 0)
        case .darkgray: (pixelLight, pixelDark, backgroundLight, backgroundDark) = Self.colors(178, 178, 178, 127, 127, 127, 68, 68, 68, 51, 51, 51)
        case .lightgray: (pixelLight, pixelDark, backgroundLight, backgroundDark) = Self.colors(242, 242, 242, 235, 235, 235, 125, 125, 125, 94, 94, 94)
        case .blue: (pixelLight, pixelDark, backgroundLight, backgroundDark) = Self.colors(104, 167, 254, 1, 109, 255, 0, 58, 136, 0, 43, 102)
        case .whiteOnBlue: (pixelLight, pixelDark, backgroundLight, backgroundDark) = Self.colors(234, 237, 248, 223, 228, 244, 61, 92, 184, 46, 69, 139)
        case .sea: (pixelLight, pixelDark, backgroundLight, backgroundDark) = Self.colors(104, 254, 253, 1, 255, 252, 0, 136, 134, 0, 102, 101)
        case .violet: (pixelLight, pixelDark, backgroundLight, backgroundDark) = Self.colors(217, 104, 254, 192, 1, 255, 102, 0, 136, 77, 0, 102)
        case .yellow: (pixelLight, pixelDark, backgroundLight, backgroundDark) = Self.colors(254, 231, 104, 255, 216, 1, 136, 115, 0, 102, 86, 0)
        case .pink: (pixelLight, pixelDark, backgroundLight, backgroundDark) = Self.colors(254, 104, 192, 255, 1, 150, 136, 0, 80, 102, 0, 60)
        case .idemia: (pixelLight, pixelDark, backgroundLight, backgroundDark) = Self.colors(185, 132, 255, 153, 107, 214, 67, 0, 153, 50, 0, 104)
        case .streetGreen: (pixelLight, pixelDark, backgroundLight, backgroundDark) = Self.colors(234, 237, 248, 223, 228, 244, 20, 122, 111, 33, 115, 113)
        }
    }

    private static func colors(_ values: Int...) -> (UIColor, UIColor, UIColor, UIColor) {
        (color(values, 0), color(values, 3), color(values, 6), color(values, 9))
    }

    private static func color(_ values: [Int], _ start: Int) -> UIColor {
        UIColor(red: CGFloat(values[start]) / 255, green: CGFloat(values[start + 1]) / 255, blue: CGFloat(values[start + 2]) / 255, alpha: 1)
    }
}
#endif