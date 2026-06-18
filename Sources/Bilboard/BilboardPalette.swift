import SwiftGD

struct BilboardPalette {
    let pixelLight: Color
    let pixelDark: Color
    let backgroundLight: Color
    let backgroundDark: Color

    init(sign: BilboardColorSign) {
        switch sign {
        case .red:
            self.pixelLight = Self.rgb(255, 102, 102)
            self.pixelDark = Self.rgb(255, 0, 0)
            self.backgroundLight = Self.rgb(136, 0, 0)
            self.backgroundDark = Self.rgb(102, 0, 0)
        case .green:
            self.pixelLight = Self.rgb(160, 254, 104)
            self.pixelDark = Self.rgb(97, 255, 1)
            self.backgroundLight = Self.rgb(51, 136, 0)
            self.backgroundDark = Self.rgb(38, 102, 0)
        case .orange:
            self.pixelLight = Self.rgb(254, 192, 104)
            self.pixelDark = Self.rgb(255, 150, 1)
            self.backgroundLight = Self.rgb(136, 80, 0)
            self.backgroundDark = Self.rgb(102, 60, 0)
        case .darkgray:
            self.pixelLight = Self.rgb(178, 178, 178)
            self.pixelDark = Self.rgb(127, 127, 127)
            self.backgroundLight = Self.rgb(68, 68, 68)
            self.backgroundDark = Self.rgb(51, 51, 51)
        case .lightgray:
            self.pixelLight = Self.rgb(242, 242, 242)
            self.pixelDark = Self.rgb(235, 235, 235)
            self.backgroundLight = Self.rgb(125, 125, 125)
            self.backgroundDark = Self.rgb(94, 94, 94)
        case .blue:
            self.pixelLight = Self.rgb(104, 167, 254)
            self.pixelDark = Self.rgb(1, 109, 255)
            self.backgroundLight = Self.rgb(0, 58, 136)
            self.backgroundDark = Self.rgb(0, 43, 102)
        case .whiteOnBlue:
            self.pixelLight = Self.rgb(234, 237, 248)
            self.pixelDark = Self.rgb(223, 228, 244)
            self.backgroundLight = Self.rgb(61, 92, 184)
            self.backgroundDark = Self.rgb(46, 69, 139)
        case .sea:
            self.pixelLight = Self.rgb(104, 254, 253)
            self.pixelDark = Self.rgb(1, 255, 252)
            self.backgroundLight = Self.rgb(0, 136, 134)
            self.backgroundDark = Self.rgb(0, 102, 101)
        case .violet:
            self.pixelLight = Self.rgb(217, 104, 254)
            self.pixelDark = Self.rgb(192, 1, 255)
            self.backgroundLight = Self.rgb(102, 0, 136)
            self.backgroundDark = Self.rgb(77, 0, 102)
        case .yellow:
            self.pixelLight = Self.rgb(254, 231, 104)
            self.pixelDark = Self.rgb(255, 216, 1)
            self.backgroundLight = Self.rgb(136, 115, 0)
            self.backgroundDark = Self.rgb(102, 86, 0)
        case .pink:
            self.pixelLight = Self.rgb(254, 104, 192)
            self.pixelDark = Self.rgb(255, 1, 150)
            self.backgroundLight = Self.rgb(136, 0, 80)
            self.backgroundDark = Self.rgb(102, 0, 60)
        case .idemia:
            self.pixelLight = Self.rgb(185, 132, 255)
            self.pixelDark = Self.rgb(153, 107, 214)
            self.backgroundLight = Self.rgb(67, 0, 153)
            self.backgroundDark = Self.rgb(50, 0, 104)
        case .streetGreen:
            self.pixelLight = Self.rgb(234, 237, 248)
            self.pixelDark = Self.rgb(223, 228, 244)
            self.backgroundLight = Self.rgb(20, 122, 111)
            self.backgroundDark = Self.rgb(33, 115, 113)
        }
    }

    static func rgb(_ red: Int, _ green: Int, _ blue: Int, alpha: Double = 1) -> Color {
        Color(
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            alpha: alpha
        )
    }
}