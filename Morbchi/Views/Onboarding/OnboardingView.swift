//
//  OnboardingView.swift
//  Morbchi
//
//  Created by Marissa Langham on 5/22/26.
//

import SwiftUI

enum OnboardingStep
{
    case welcome, name, personality, hatch
}

struct OnboardingView: View
{
    @State private var step: OnboardingStep = .welcome
    @State private var petName: String = ""
    @State private var selectedPersonality: Personality = .gentle

    var onComplete: (String, Personality) -> Void

    var body: some View
    {
        ZStack
        {
            Theme.Color.surface.ignoresSafeArea()

            switch step
            {
            case .welcome:
                WelcomeStepView(onNext: { step = .name })
            case .name:
                NameStepView(petName: $petName, onNext: { step = .personality })
            case .personality:
                PersonalityStepView(selected: $selectedPersonality, onNext: { step = .hatch })
            case .hatch:
                HatchStepView(onComplete: { onComplete(petName, selectedPersonality) })
            }
        }
        .frame(width: 480, height: 560)
    }
}

// Welcome Onboarding
struct WelcomeStepView: View
{
    var onNext: () -> Void

    var body: some View
    {
        VStack(spacing: 24)
        {
            Spacer()
            Text(" Morbchi ")
                .font(Theme.Font.heading(28))
                .foregroundColor(Theme.Color.textPrimary)
            Text("A magical companion is waiting for you...")
                .font(Theme.Font.flavor(15))
                .foregroundColor(Theme.Color.textMuted)
                .multilineTextAlignment(.center)
            Spacer()
            Button("Begin") { onNext() }
                .buttonStyle(.borderedProminent)
        }
        .padding(40)
    }
}

// Name Onboarding
struct NameStepView: View
{
    @Binding var petName: String
    var onNext: () -> Void

    var body: some View
    {
        VStack(spacing: 24)
        {
            Spacer()
            Text("What shall we call them?")
                .font(Theme.Font.heading(28))
                .foregroundColor(Theme.Color.textPrimary)
            TextField("Enter a name...", text: $petName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 280)
            Spacer()
            Button("Continue") { onNext()}
                .buttonStyle(.borderedProminent)
                .disabled(petName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(40)
    }
}

// Personality Onboarding
struct PersonalityStepView: View
{
    @Binding var selected: Personality
    var onNext: () -> Void

    var body: some View
    {
        VStack(spacing: 24)
        {
            Text("Choose their nature")
                .font(Theme.Font.heading(28))
                .foregroundColor(Theme.Color.textPrimary)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12)
            {
                ForEach(Personality.allCases, id: \.self)
                { personality in
                    PersonalityCard(personality: personality, isSelected: selected == personality)
                        .onTapGesture { selected = personality }
                }
            }
            .padding(.horizontal)
            Button("Continue") { onNext() }
                .buttonStyle(.borderedProminent)
        }
        .padding(40)
    }
}

struct PersonalityCard: View
{
    let personality: Personality
    let isSelected: Bool

    var body: some View
    {
        VStack(spacing: 8)
        {
            Text(personality.rawValue)
                .font(Theme.Font.body(16))
                .foregroundColor(Theme.Color.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isSelected ? Theme.Color.accentCool : Theme.Color.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.Color.accentCool, lineWidth: isSelected ? 2 : 0)
        )
    }
}

// Hatch Onboarding 
struct HatchStepView: View
{
    var onComplete: () -> Void
    @State private var cracked = false

    var body: some View {
        VStack(spacing: 24)
        {
            Spacer()
            Text(cracked ? "CrackedEgg" : "UncrackedEgg")
                .font(.system(size: 80))
            Text(cracked ? "They're here!" : "Your companion is ready to hatch...")
                .font(Theme.Font.flavor(15))
                .foregroundColor(Theme.Color.textMuted)
                .multilineTextAlignment(.center)
            Spacer()
            Button(cracked ? "Meet Them!" : "Hatch!")
            {
                if cracked { onComplete() }
                else { withAnimation { cracked = true } }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
    }
}
