# Morbchi — Project Document v1
> Reflects the actual first working version of the app. For the original full vision, see PROJECT.md.

---

## Concept

**Morbchi** is a magical creature that lives on your Mac desktop. It floats freely on your screen in a transparent, frameless window — always present but never in the way. Inspired by classic desktop pets and Tamagotchi-style care mechanics, it blends stat management, personality-driven dialogue, and care animations with a cozy gothic whimsical aesthetic.

---

## Platform & Tech Stack

| Area | Technology |
|---|---|
| Platform | macOS 14+ (Sonoma) |
| Primary UI | SwiftUI |
| macOS windowing | AppKit (NSPanel, NSWindow, NSStatusBar) |
| Architecture | MVVM |
| Persistence | SwiftData |
| Version Control | Git + GitHub |
| Minimum macOS | macOS 14 (Sonoma) |

---

## Aesthetic Direction

**Cozy Gothic Whimsical**

### Color Palette
| Role | Hex | Description |
|---|---|---|
| UI panels | `#1A1225` | deep midnight plum |
| Surface | `#2D2040` | dark violet |
| Accent warm | `#E8A87C` | amber candlelight |
| Accent cool | `#9B72CF` | soft lavender |
| Text primary | `#F0E6FF` | pale lilac white |
| Text muted | `#8A7AA0` | dusty mauve |

### Typography
- Headings: Playfair Display (ornate serif)
- Flavor text: italic, slightly whimsical

---

## What's Built (v1)

### Desktop Pet Window
- Floating transparent `NSPanel` (400×300), always on top, never steals focus
- Pet sprite renders based on current mood or active action
- Idle bob animation (gentle float up/down on repeat)
- Right-click context menu: Feed, Pet, Bathe, Sleep, Open Stats, Quit
- Position saved between sessions

### Pet Sprites
5 pet types × 11 states each:

| Pet | States |
|---|---|
| Rabbit | idle, feed, bath, pet, sleep, dirty, excited, sad, sick, curious, magical |
| Cat | idle, feed, bath, pet, sleep, dirty, excited, sad, sick, curious, magical |
| Fox | idle, feed, bath, pet, sleep, dirty, excited, sad, sick, curious, magical |
| Snake | idle, feed, bath, pet, sleep, dirty, excited, sad, sick, curious, magical |
| Koala | idle, feed, bath, pet, sleep, dirty, excited, sad, sick, curious, magical |

Sprite naming convention: `[petType]_[state]` (e.g. `rabbit_idle`, `fox_dirty`)

### Sprite Priority Order
When choosing which sprite to show, the priority is:
1. Active action (feed, bath, pet, sleep) — overrides everything
2. Health < 20 → `[pet]_sick`
3. Cleanliness < 30 → `[pet]_dirty`
4. Current mood → mood sprite

### Care Actions & Animations
| Action | Sprite shown | Stat changed |
|---|---|---|
| Feed | `[pet]_feed` for 2s | Hunger +20, Happiness +5, Health +2 |
| Pet/Cuddle | `[pet]_pet` for 2s | Happiness +10, Social +10, Health +2 |
| Bathe | `[pet]_bath` for 2s | Cleanliness → 100, Happiness +5, Health +40 |
| Sleep | `[pet]_sleep` for 15 min | Energy +50, Health +5 |

### Mood System
Mood recalculates every 30 seconds and immediately after any care action.

| Mood | Trigger | Sprite |
|---|---|---|
| excited | Happiness > 80 + Energy > 60 | `[pet]_excited` |
| happy | Happiness > 60 | `[pet]_idle` |
| curious | Default / none match | `[pet]_curious` |
| magical | Magic > 80 | `[pet]_magical` |
| sleepy | Energy < 30 | `[pet]_sleep` |
| hungry | Hunger < 30 | `[pet]_feed` |
| sad | Happiness < 30 or Social < 30 | `[pet]_sad` |
| sick | Health < 20 | `[pet]_sick` |

> **Note:** `dirty` is a sprite state (shown when cleanliness < 30) but is not a `Mood` enum case — it's handled separately in the sprite selection logic, not via the mood system.

### Sleep
Sleep restores Energy +50 and Health +5, triggered from the context menu. The `[pet]_sleep` sprite shows for 15 minutes then returns to idle. Thought bubbles are suppressed for the full duration of the nap.

### Thought Bubble
- Appears above the pet when a stat is critically low
- Dark rounded rectangle + lavender border + angled triangle tail
- Personality-driven dialogue — each of the 5 personalities has unique lines for sick, hunger, energy, happiness, and cleanliness (25 lines total)
- Priority order: sick (health < 20) → hunger → energy → happiness → cleanliness
- Suppressed during sleep

### Personality Dialogue
| Personality | Tone |
|---|---|
| Mischievous | Playful, sarcastic, teasing |
| Gentle | Soft, warm, apologetic |
| Sage | Wise, cryptic |
| Wild | Loud, chaotic, energetic |
| Dramatic | Over-the-top, theatrical |

### Stat Engine (PetEngine)
- Timer ticks every 30 seconds
- Drain rates per tick:

| Stat | Drain per tick |
|---|---|
| Hunger | 0.5 |
| Happiness | 0.4 |
| Energy | 0.3 |
| Cleanliness | 0.15 |
| Social | 0.3 |

### Stat Interactions
Stats influence each other every tick:
- Hunger < 15: energy, happiness, and health drain faster
- Energy < 15: health and happiness drain faster
- Cleanliness < 30: health, happiness, and energy drain faster
- Happiness < 15: health drains faster
- Social < 15: health drains faster

**Positive recovery:** When hunger, happiness, or energy exceeds 70, health slowly recovers (+0.1 per tick each).

### Menu Bar
- Status bar icon
- Popover with: pet name, mood badge (color dot + label), stat rows (hunger, happy, energy, health) with custom icons and progress bars

### Onboarding (6 screens)
1. Welcome — egg image + tagline + Begin button
2. Pet Type — 5 pet type cards (Rabbit, Cat, Fox, Snake, Koala)
3. Personality — 5 personality cards with icons and descriptions
4. Name — styled text field
5. Hatch — shaking egg animation + Hatch button
6. Meet — hatched pet reveal + Meet them! button

---

## Stats (8 core stats)

| Stat | Drains | Restored by |
|---|---|---|
| Hunger | Yes | Feed |
| Happiness | Yes | Pet/Cuddle |
| Energy | Yes | Sleep |
| Health | From neglect (low stats drain it) | High stats restore it slowly |
| Cleanliness | Yes (slow) | Bathe |
| Social | Yes | Cuddle |
| Magic | No — grows with leveling | Level up |
| Knowledge | No — grows from games | (future: mini-games) |

---

## Current Focus (active development)

- [ ] Coffee / water / break reminder animations (needs Figma design first)
- [ ] Wellness nudge system (remind user to take breaks)

---

## Xcode Project Structure (actual)

```
Morbchi/
├── App/
│   ├── MorbchiApp.swift
│   └── AppDelegate.swift
├── Windows/
│   ├── PetWindowController.swift
│   └── MenuBarController.swift
├── Models/
│   ├── Pet.swift
│   ├── PetStats.swift
│   └── PetDialogue.swift
├── ViewModels/
│   └── PetViewModel.swift
├── Views/
│   ├── Desktop/
│   │   ├── DesktopPetView.swift
│   │   └── ThoughtBubbleView.swift
│   ├── MenuBar/
│   │   └── MenuBarPopoverView.swift
│   ├── Onboarding/
│   │   └── OnboardingView.swift
│   └── Shared/
│       ├── Theme.swift
│       └── MoodBadgeView.swift
├── Services/
│   └── PetEngine.swift
└── Assets.xcassets
```

---

*Last updated: 2026-08-18*
