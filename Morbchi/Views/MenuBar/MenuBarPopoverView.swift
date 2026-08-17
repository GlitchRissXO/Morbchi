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
                if let mood = viewModel.stats?.mood
                {
                    MoodBadgeView(mood: mood)
                }
            }
            
            // Stats — 4 rows matching the Figma StatGauge layout
            if let stats = viewModel.stats
            {
                StatRowView(icon: "icon_hunger", label: "Hunger", value: stats.hunger)
                StatRowView(icon: "icon_happy",  label: "Happy",  value: stats.happiness)
                StatRowView(icon: "icon_energy", label: "Energy", value: stats.energy)
                StatRowView(icon: "icon_health", label: "Health", value: stats.health)
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

}

// A single stat row: colored square icon + label + progress bar
struct StatRowView: View
{
    let icon: String   // e.g. "icon_hunger"
    let label: String  // e.g. "Hunger"
    let value: Double  // 0–100

    var body: some View
    {
        HStack(spacing: 10)
        {
            // Custom stat icon
            Image(icon)
                .resizable()
                .scaledToFit()
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
