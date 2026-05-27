import SwiftUI

enum Theme {
    // MARK: - Colors
    enum Color {
        static let backgroundPanel  = SwiftUI.Color(hex: "#1A1225")
        static let surface          = SwiftUI.Color(hex: "#2D2040")
        static let accentWarm       = SwiftUI.Color(hex: "#E8A87C")
        static let accentCool       = SwiftUI.Color(hex: "#9B72CF")
        static let highlight        = SwiftUI.Color(hex: "#F4D35E")
        static let textPrimary      = SwiftUI.Color(hex: "#F0E6FF")
        static let textMuted        = SwiftUI.Color(hex: "#8A7AA0")
        static let pop              = SwiftUI.Color(hex: "#C97B84")
        static let sage             = SwiftUI.Color(hex: "7AAB5F")
    }
    
    

    // Typography
    enum Font {
        static func heading(_ size: CGFloat) -> SwiftUI.Font {
            .custom("Playfair Display", size: size).bold()
        }
        static func body(_ size: CGFloat) -> SwiftUI.Font {
            .system(size: size, design: .rounded)
        }
        static func flavor(_ size: CGFloat) -> SwiftUI.Font {
            .custom("Playfair Display", size: size).italic()
        }
    }

    // MARK: - Sizing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 40
    }
}

extension SwiftUI.Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
