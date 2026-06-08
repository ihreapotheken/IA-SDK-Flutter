import SwiftUI

extension Color {
    /// Creates a `Color` from an ARGB integer value (e.g. `0xFFRRGGBB`).
    init(argb value: Int) {
        let a = Double((value >> 24) & 0xFF) / 255.0
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
