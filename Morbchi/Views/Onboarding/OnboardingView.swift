//
//  OnboardingView.swift
//  Morbchi
//
//  Created by Marissa Langham on 5/22/26.
//

import SwiftUI

enum OnboardingStep
{
    case welcome, pet, personality, name, hatch, meet
}

struct OnboardingView: View
{
    @State private var step: OnboardingStep = .welcome
    @State private var petName: String = ""
    @State private var selectedPersonality: Personality = .gentle
    @State private var selectedPetType: PetType = .cat

    var onComplete: (String, Personality, PetType ) -> Void

    var body: some View
    {
        ZStack
        {
            // Dark background matching the Figma designs
            Theme.Color.backgroundPanel.ignoresSafeArea()

            switch step
            {
            case .welcome:
                WelcomeStepView(onNext: { step = .pet })
            case .pet:
                PetTypeStepView(selected: $selectedPetType, onNext: { step = .personality })
            case .personality:
                PersonalityStepView(selected: $selectedPersonality, onNext: { step = .name })
            case .name:
                NameStepView(petName: $petName, onNext: { step = .hatch })
            case .hatch:
                HatchStepView(onNext: { step = .meet })
            case .meet:
                MeetStepView(petType: selectedPetType, onComplete: { onComplete(petName, selectedPersonality, selectedPetType) })
            }
        }
        .frame(width: 800, height: 600)
    }
}

// Welcome screen 
struct WelcomeStepView: View
{
    var onNext: () -> Void

    var body: some View
    {
        VStack(spacing: 20)
        {
            Text("Welcome to Morbchi")
                .font(Theme.Font.heading(40))
                .foregroundColor(Theme.Color.textPrimary)
                .multilineTextAlignment(.center)
            Text("Your magical companion awaits")
                .font(Theme.Font.flavor(16))
                .foregroundColor(Theme.Color.textMuted)
            Image("egg")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
                .padding(.vertical, 24)
            Button("Begin") { onNext() }
                .buttonStyle(MainButtonStyle())
                .frame(width: 240)
        }
        .padding(40)
    }
}

// Pet type selection
struct PetTypeStepView: View
{
    @Binding var selected: PetType
    var onNext: () -> Void

    var body: some View
    {
        VStack(spacing: 16)
        {
            Spacer()
            Text("What kind of companion do you want?")
                .font(Theme.Font.heading(32))
                .foregroundColor(Theme.Color.textPrimary)
                .multilineTextAlignment(.center)
            Text("Choose your Morbchi")
                .font(Theme.Font.heading(18))
                .foregroundColor(Theme.Color.textMuted)
            Spacer()
            // 5 pet type cards in a horizontal row
            HStack(spacing: 16)
            {
                ForEach(PetType.allCases, id: \.self)
                { petType in
                    PetTypeCard(petType: petType, isSelected: selected == petType)
                        .onTapGesture { selected = petType }
                }
            }
            .padding(.horizontal, 40)
            Spacer()
            Button("Next") { onNext() }
                .buttonStyle(MainButtonStyle())
                .frame(width: 240)
        }
        .padding(40)
    }
}

// A single pet type card showing the mystery icon
struct PetTypeCard: View
{
    let petType: PetType
    let isSelected: Bool

    var body: some View
    {
        VStack(spacing: 12)
        {
            Text(petType.rawValue)
                .font(Theme.Font.heading(16))
                .foregroundColor(Theme.Color.textPrimary)
            Image("pet_icon_\(petType.rawValue.lowercased())")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Theme.Color.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.Color.accentCool, lineWidth: isSelected ? 2 : 1)
        )
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
            Text("What is your companion's name?")
                .font(Theme.Font.heading(32))
                .foregroundColor(Theme.Color.textPrimary)
                .multilineTextAlignment(.center)
            Spacer()
            Image("egg")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
            Spacer()
            TextField("Enter a name", text: $petName)
                .font(Theme.Font.flavor(16))
                .foregroundColor(Theme.Color.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Theme.Color.surface)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.Color.accentCool, lineWidth: 1))
                .frame(width: 340)
            Spacer()
            Button("Next") { onNext() }
                .buttonStyle(MainButtonStyle())
                .frame(width: 240)
                .disabled(petName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(40)
    }
}

// Personality selection (user picks their companion's personality)
struct PersonalityStepView: View
{
    @Binding var selected: Personality
    var onNext: () -> Void

    var body: some View
    {
        VStack(spacing: 0)
        {
            Spacer()

            // Heading
            Text("What kind of companion are you getting?")
                .font(Theme.Font.heading(32))
                .foregroundColor(Theme.Color.textPrimary)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 8)

            // Subheading
            Text("Choose your Morbchi's personality")
                .font(Theme.Font.heading(18))
                .foregroundColor(Theme.Color.textMuted)

            Spacer().frame(height: 40)

            // 5 personality cards in a horizontal row
            HStack(spacing: 12)
            {
                ForEach(Personality.allCases, id: \.self)
                { personality in
                    PersonalityCard(personality: personality, isSelected: selected == personality)
                        .onTapGesture { selected = personality }
                }
            }

            Spacer().frame(height: 40)

            Button("Next") { onNext() }
                .buttonStyle(MainButtonStyle())
                .frame(width: 240)

            Spacer()
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// A single personality card showing the name, description, and icon
struct PersonalityCard: View
{
    let personality: Personality
    let isSelected: Bool

    var body: some View
    {
        VStack(spacing: 6)
        {
            Text(personality.rawValue)
                .font(Theme.Font.heading(15))
                .foregroundColor(Theme.Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(personality.description)
                .font(Theme.Font.flavor(11))
                .foregroundColor(Theme.Color.textMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Image("personality_\(personality.rawValue.lowercased())")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 130)
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background(Theme.Color.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.Color.accentCool, lineWidth: isSelected ? 2 : 1)
        )
    }
}

// Meet screen (pet hatched. User sees them for the first time)
struct MeetStepView: View
{
    let petType: PetType
    var onComplete: () -> Void

    var body: some View
    {
        VStack(spacing: 24)
        {
            Spacer()
            Text("They're here!")
                .font(Theme.Font.heading(40))
                .foregroundColor(Theme.Color.textPrimary)
                .multilineTextAlignment(.center)
            Spacer()
            // Show the hatched version of the chosen pet type
            Image("hatched_\(petType.rawValue.lowercased())")
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 220)
            Spacer()
            Button("Meet them!") { onComplete() }
                .buttonStyle(MainButtonStyle())
                .frame(width: 240)
        }
        .padding(40)
    }
}

// Hatch Onboarding
struct HatchStepView: View
{
    @State private var isShaking = false
    var onNext: () -> Void
    var body: some View
    {
        VStack(spacing: 24)
        {
            Spacer()
            Text("Your companion is hatching . . .")
                .font(Theme.Font.heading(28))
                .foregroundColor(Theme.Color.textPrimary)
                .multilineTextAlignment(.center)
            Text("Your magical companion awaits...")
                .font(Theme.Font.flavor(15))
                .foregroundColor(Theme.Color.textMuted)
            Image("egg_hatching")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(isShaking ? 5: -5))
                .animation(.easeInOut(duration: 0.15).repeatForever(autoreverses: true), value: isShaking)
                .onAppear{ isShaking = true}
            Spacer()
            Button("Hatch") { onNext() }
                .buttonStyle(MainButtonStyle())
                .frame(maxWidth: .infinity)
        }
        .padding(40)
    }
}
