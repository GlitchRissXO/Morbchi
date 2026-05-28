//
//  MenuBarPopoverView.swift
//  Morbchi
//
//  Created by Marissa Langham on 5/27/26.
//

import SwiftUI

struct MenuBarPopoverView: View
{
    @ObservedObject var viewModel: PetViewModel

    var body: some View
    {
        VStack(alignment: .leading, spacing: 16)
        {
            // Header — pet name on the left, mood badge on the right
            HStack
            {
                Text(viewModel.pet?.name ?? "Morbchi")
                    .font(Theme.Font.heading(28))
                    .foregroundColor(Theme.Color.textPrimary)
                Spacer()
                HStack(spacing: 6)
                {
                    Circle()
                        .fill(moodDotColor(for: viewModel.stats?.mood))
                        .frame(width: 8, height: 8)
                    Text(viewModel.stats?.mood.displayName ?? "")
                        .font(Theme.Font.body(13))
                        .foregroundColor(Theme.Color.textPrimary)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 4)
                .background(Theme.Color.surface)
                .cornerRadius(12)
            }
            
            // Stats — 4 rows matching the Figma StatGauge layout
            if let stats = viewModel.stats
            {
                StatRowView(label: "Hunger", value: stats.hunger)
                StatRowView(label: "Happy",  value: stats.happiness)
                StatRowView(label: "Energy", value: stats.energy)
                StatRowView(label: "Health", value: stats.health)
            }
            
            // Action buttons
            VStack(spacing: 10)
            {
                Button("Quick Feed") { viewModel.feed() }
                    .buttonStyle(MainButtonStyle())
                    .frame(maxWidth: .infinity)
                
                Button("Open Room") { }
                    .buttonStyle(MainButtonStyle())
                    .frame(maxWidth: .infinity)
                
                Button("Hide Pet") { }
                    .buttonStyle(MainButtonStyle())
                    .frame(maxWidth: .infinity)
            }
            
        }
        
        .padding(20)
        .frame(maxWidth: 280, alignment: .center)
        .background(Theme.Color.backgroundPanel)
    }

    private func moodDotColor(for mood: Mood?) -> SwiftUI.Color
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
        case .sick:     return Theme.Color.sage
        case nil:       return Theme.Color.textMuted
        }
    }
}

// A single stat row: colored square icon + label + progress bar
struct StatRowView: View
{
    let label: String  // e.g. "Hunger"
    let value: Double  // 0–100

    var body: some View
    {
        HStack(spacing: 10)
        {
            // Colored square icon — matches the lavender squares in Figma
            RoundedRectangle(cornerRadius: 4)
                .fill(Theme.Color.accentCool)
                .frame(width: 16, height: 16)

            // Stat name label
            Text(label)
                .font(Theme.Font.body(13))
                .foregroundColor(Theme.Color.textPrimary)
                .frame(width: 45, alignment: .leading)

            // Progress bar track + fill
            let trackWidth: CGFloat = 120

            ZStack(alignment: .leading)
            {
                // Track (empty background)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Theme.Color.surface)
                    .frame(width: trackWidth, height: 8)

                // Fill (amber bar showing current value)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Theme.Color.accentWarm)
                    .frame(width: trackWidth * (value / 100), height: 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
