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
- Right-click context menu: Feed, Pet, Bathe, Sleep, Quit
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

### Care Actions & Animations
| Action | Sprite shown | Stat changed |
|---|---|---|
| Feed | `[pet]_feed` for 2s | Hunger +20, Happiness +5 |
| Pet/Cuddle | `[pet]_pet` for 2s | Happiness +10, Social +10 |
| Bathe | `[pet]_bath` for 2s | Cleanliness → 100, Happiness +5 |
| Sleep | `[pet]_sleep` for 2s | Energy → 100 |

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
| sick | Health < 30 | `[pet]_sick` |

> **Note:** `dirty` is a sprite state (shown when cleanliness < 30) but is not a `Mood` enum case — it's handled separately in the sprite selection logic, not via the mood system.

### Sleep Action
Sleep is an instant stat restore (Energy → 100) triggered from the context menu. The `[pet]_sleep` sprite shows for 2 seconds then returns to idle. A full sleep cycle (room dims, ambient sounds, night animation) is planned for a future version.

### Thought Bubble
- Appears above the pet when a stat drops below 30
- Dark rounded rectangle + lavender border + angled triangle tail
- Personality-driven dialogue — each of the 5 personalities has unique lines for hunger, energy, happiness, and cleanliness
- Priority order: hunger → energy → happiness → cleanliness

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
| Hunger | 2.0 |
| Happiness | 1.5 |
| Energy | 1.0 |
| Cleanliness | 0.5 |
| Social | 1.0 |

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
| Health | Only from neglect | (future: heal potions) |
| Cleanliness | Yes (slow) | Bathe |
| Social | Yes | Cuddle, Talk |
| Magic | No — grows with leveling | Level up |
| Knowledge | No — grows from games | (future: mini-games) |

---

## Current Focus (active development)

- [ ] Mood-driven sprite swapping in DesktopPetView
- [ ] Mood badge under the pet (matching menu bar style)
- [ ] Coffee / water / break reminder animations
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
│       └── Theme.swift
├── Services/
│   └── PetEngine.swift
└── Assets.xcassets
```

---

## Scaled Back (future versions)

These features are planned but not being built in v1:
- Room window (care hub)
- Shop & coin system
- Mini-games
- Stats window (standalone)
- AI chat (Claude API)
- Weather reactions (WeatherKit)
- Activity monitoring
- Journal / diary
- Photo capture
- CloudKit sync
- Sound & audio
- Evolution branching
- Seasonal events

---

*Last updated: 2026-08-17*
