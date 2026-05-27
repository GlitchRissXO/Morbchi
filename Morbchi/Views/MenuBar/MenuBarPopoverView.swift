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
                    .font(Theme.Font.heading(20))
                    .foregroundColor(Theme.Color.textPrimary)
                Spacer()
                Text(viewModel.stats?.mood.displayName ?? "")
                    .font(Theme.Font.body(13))
                    .foregroundColor(Theme.Color.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Theme.Color.accentCool)
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

            // Action buttons — all same solid style like in Figma
            Button("Quick Feed") { viewModel.feed() }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)

            Button("Open Room") { }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)

            Button("Hide Pet") { }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
        }
        .padding(20)
        .frame(width: 280)
        .background(Theme.Color.backgroundPanel)
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
                .frame(width: 24, height: 24)

            // Stat name label
            Text(label)
                .font(Theme.Font.body(13))
                .foregroundColor(Theme.Color.textPrimary)
                .frame(width: 55, alignment: .leading)

            // Progress bar track + fill
            GeometryReader { geo in
                ZStack(alignment: .leading)
                {
                    // Track (empty background)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Theme.Color.surface)
                        .frame(height: 8)

                    // Fill (amber bar showing current value)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Theme.Color.accentWarm)
                        .frame(width: geo.size.width * (value / 100), height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}
