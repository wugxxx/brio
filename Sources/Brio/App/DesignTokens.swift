import SwiftUI

enum Space {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
}

enum Radius {
    static let panel: CGFloat = 18
    static let card: CGFloat = 10
    static let well: CGFloat = 8
    static let field: CGFloat = 6
    static let dock: CGFloat = 12
}

enum Tone {
    static let wash = Color.primary.opacity(0.03)
    static let fill = Color.primary.opacity(0.05)
    static let raised = Color.primary.opacity(0.075)
    static let hairline = Color.primary.opacity(0.08)
    static let border = Color.primary.opacity(0.12)
    static let accentWash = Color.accentColor.opacity(0.06)
    static let accentSoft = Color.accentColor.opacity(0.12)
    static let accentBorder = Color.accentColor.opacity(0.28)
}
