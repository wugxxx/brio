import AppKit

enum MenuBarIcon {
    static let image: NSImage = {
        let image = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { rect in
            guard let context = NSGraphicsContext.current?.cgContext else { return false }

            context.saveGState()
            context.translateBy(x: 0, y: rect.height)
            context.scaleBy(x: rect.width / 18, y: -rect.height / 18)
            context.setFillColor(CGColor(gray: 0, alpha: 1))

            context.addPath(makeNibPath())
            context.fillPath()
            context.addPath(makeBasePath())
            context.fillPath()

            context.setBlendMode(.clear)
            context.fill(CGRect(x: 8.62, y: 1.35, width: 0.76, height: 12))
            context.setBlendMode(.normal)

            context.addPath(makeSparkPath())
            context.fillPath()
            context.restoreGState()

            return true
        }
        image.isTemplate = true
        return image
    }()

    private static func makeNibPath() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 9, y: 1.2))
        path.addCurve(
            to: CGPoint(x: 10.5, y: 4.9),
            control1: CGPoint(x: 9.55, y: 2.2),
            control2: CGPoint(x: 10.1, y: 3.5)
        )
        path.addCurve(
            to: CGPoint(x: 12.45, y: 6.8),
            control1: CGPoint(x: 11.8, y: 5.35),
            control2: CGPoint(x: 12.45, y: 6)
        )
        path.addCurve(
            to: CGPoint(x: 10.95, y: 7.75),
            control1: CGPoint(x: 12.45, y: 7.5),
            control2: CGPoint(x: 11.8, y: 7.75)
        )
        path.addCurve(
            to: CGPoint(x: 12.6, y: 9.8),
            control1: CGPoint(x: 11.9, y: 7.9),
            control2: CGPoint(x: 12.6, y: 8.7)
        )
        path.addCurve(
            to: CGPoint(x: 10.55, y: 11.1),
            control1: CGPoint(x: 12.6, y: 10.7),
            control2: CGPoint(x: 11.7, y: 11.1)
        )
        path.addLine(to: CGPoint(x: 10.55, y: 13.35))
        path.addLine(to: CGPoint(x: 7.45, y: 13.35))
        path.addLine(to: CGPoint(x: 7.45, y: 12.7))
        path.addCurve(
            to: CGPoint(x: 5.05, y: 9.4),
            control1: CGPoint(x: 6.25, y: 12.2),
            control2: CGPoint(x: 5.05, y: 11)
        )
        path.addCurve(
            to: CGPoint(x: 6.05, y: 7.55),
            control1: CGPoint(x: 5.05, y: 8.6),
            control2: CGPoint(x: 5.45, y: 8)
        )
        path.addCurve(
            to: CGPoint(x: 5.35, y: 5),
            control1: CGPoint(x: 5.55, y: 6.7),
            control2: CGPoint(x: 5.35, y: 5.8)
        )
        path.addCurve(
            to: CGPoint(x: 9, y: 1.2),
            control1: CGPoint(x: 5.35, y: 3),
            control2: CGPoint(x: 6.9, y: 1.85)
        )
        path.closeSubpath()
        return path
    }

    private static func makeBasePath() -> CGPath {
        CGPath(
            roundedRect: CGRect(x: 6.35, y: 14.55, width: 6.3, height: 1.6),
            cornerWidth: 0.65,
            cornerHeight: 0.65,
            transform: nil
        )
    }

    private static func makeSparkPath() -> CGPath {
        let center = CGPoint(x: 14.8, y: 4)
        let radius: CGFloat = 2
        let inner: CGFloat = 0.46
        let outerPoints = [
            CGPoint(x: center.x, y: center.y - radius),
            CGPoint(x: center.x + radius, y: center.y),
            CGPoint(x: center.x, y: center.y + radius),
            CGPoint(x: center.x - radius, y: center.y)
        ]
        let innerPoints = [
            CGPoint(x: center.x + inner, y: center.y - inner),
            CGPoint(x: center.x + inner, y: center.y + inner),
            CGPoint(x: center.x - inner, y: center.y + inner),
            CGPoint(x: center.x - inner, y: center.y - inner)
        ]

        let path = CGMutablePath()
        path.move(to: outerPoints[0])
        for index in 0..<4 {
            path.addQuadCurve(to: outerPoints[(index + 1) % 4], control: innerPoints[index])
        }
        path.closeSubpath()
        return path
    }
}
