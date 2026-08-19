import SwiftUI

struct DreamBubbleView: View
{
    let text: String

    var body: some View
    {
        ZStack
        {
            Image("thought_bubble")
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 185)

            Text(text)
                .font(Theme.Font.flavor(11))
                .foregroundColor(Color(hex: "#1A1225"))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: 150)
                .offset(x: 12, y: -20)
        }
    }
}
