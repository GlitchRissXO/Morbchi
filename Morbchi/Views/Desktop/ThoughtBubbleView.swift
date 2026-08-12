// Thought Bubble View
import SwiftUI

struct ThoughtBubbleView: View
{
    let text: String
    
    var body: some View
    {
        VStack(spacing: 4)
        {
            Text(text)
                .font(Theme.Font.flavor(14))
                .foregroundColor(.white)
                .italic()
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Theme.Color.backgroundPanel)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                            .stroke(Theme.Color.accentCool, lineWidth: 1.5)))
            Triangle()
                .fill(Theme.Color.backgroundPanel)
                .frame(width: 20, height: 14)
        }
    }
}

// Traingle for Thought Bubble
struct Triangle: Shape
{
    func path(in rect: CGRect) -> Path
    {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
