//
//  MoodBadgeView.swift
//  Morbchi
//
//  Created by Marissa Langham on 8/17/26.
//
import SwiftUI

struct MoodBadgeView: View
{
    let mood: Mood

    var body: some View
    {
        HStack(spacing: 6)
        {
            Circle()
                .fill(moodDotColor)
                .frame(width: 8, height: 8)
            Text(mood.displayName)
                .font(Theme.Font.body(13))
                .foregroundColor(Theme.Color.textPrimary)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 4)
        .background(Theme.Color.surface)
        .cornerRadius(12)
    }

    private var moodDotColor: Color
    {
        switch mood
        {
        case .happy:    return Theme.Color.accentWarm
        case .excited:  return Theme.Color.highlight
        case .playful:  return Theme.Color.highlight
        case .curious:  return Theme.Color.accentCool
        case .magical:  return Theme.Color.highlight
        case .ascended: return Theme.Color.accentCool
        case .sleepy:   return Theme.Color.textMuted
        case .hungry:   return Theme.Color.accentWarm
        case .sad:      return Theme.Color.textMuted
        case .grumpy:   return Theme.Color.pop
        case .sick:     return Theme.Color.accentWarm
        }
    }
}
