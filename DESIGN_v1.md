# Morbchi — Design Document v1
> System architecture, data flow, UI components, and implementation details for the first working version.
> For the original full vision, see DESIGN.md.

---

## 1. Architecture Overview

```
┌────────────────────────────────────────────┐
│                 macOS System               │
│                                            │
│  ┌──────────────┐     ┌─────────────────┐  │
│  │ Desktop Pet  │     │    Menu Bar     │  │
│  │  (NSPanel)   │     │  (NSStatusBar)  │  │
│  └──────┬───────┘     └───────┬─────────┘  │
│         │                    │             │
│         └──────────┬─────────┘             │
│                    │                       │
│            ┌───────▼────────┐              │
│            │  PetViewModel  │              │
│            └───────┬────────┘              │
│                    │                       │
│         ┌──────────┼──────────┐            │
│         │          │          │            │
│  ┌──────▼──────┐ ┌─▼────────┐ │            │
│  │  PetEngine  │ │SwiftData │ │            │
│  │ (30s timer) │ │(on-disk) │ │            │
│  └─────────────┘ └──────────┘ │            │
└───────────────────────────────┼────────────┘
```

---

## 2. Data Flow

### Stat Drain (passive)
```
Every 30 seconds:
PetEngine.tick()
  → drains: hunger(-2.0), happiness(-1.5), energy(-1.0), cleanliness(-0.5), social(-1.0)
  → recalculateMood(stats)
  → onSave() → context.save()
  → PetViewModel publishes change
  → DesktopPetView re-renders
```

### Care Action (user triggered)
```
User right-clicks pet → selects Feed
  → PetViewModel.feed()
      → currentAction = "feed"
      → Task.sleep(2s) → currentAction = nil
      → stats.hunger += 20, stats.happiness += 5
      → addXP(5)
      → save()
          → engine.recalculateMood(stats)   ← immediate mood update
          → checkAndShowThought()           ← thought bubble check
          → context.save()
```

### Thought Bubble Trigger
```
checkAndShowThought():
  if hunger < 30   → show hunger dialogue for pet's personality
  if energy < 30   → show energy dialogue
  if happiness < 30 → show happiness dialogue
  if cleanliness < 30 → show cleanliness dialogue
  else             → currentThought = nil (bubble hides)
```

### Sprite Selection
```
petSprite computed property:
  if currentAction != nil → "[petType]_[currentAction]"   (action sprite, 2s)
  else if cleanliness < 30 → "[petType]_dirty"            (not a Mood case — checked separately)
  else → mood → sprite mapping:
      excited  → "[petType]_excited"
      happy    → "[petType]_idle"
      curious  → "[petType]_curious"
      magical  → "[petType]_magical"
      sleepy   → "[petType]_sleep"
      hungry   → "[petType]_feed"
      sad      → "[petType]_sad"
      sick     → "[petType]_sick"
```

### First Launch / Onboarding
```
App opens → SwiftData fetch returns empty
  → OnboardingView shown (800×600 window)
  → Step 1: Welcome
  → Step 2: Pick pet type (Rabbit/Cat/Fox/Snake/Koala)
  → Step 3: Pick personality (Mischievous/Dramatic/Wild/Sage/Gentle)
  → Step 4: Name the pet
  → Step 5: Hatch (shaking egg animation)
  → Step 6: Meet (hatched pet reveal)
  → onComplete(name, personality, petType)
      → Pet + PetStats created and saved to SwiftData
      → PetEngine starts
      → Onboarding window closes
      → Desktop pet window appears
```

---

## 3. Data Models

### Pet
| Field | Type | Notes |
|---|---|---|
| name | String | set during onboarding |
| personality | Personality | permanent, set at creation |
| petType | PetType | permanent, set at creation |
| lifeStage | LifeStage | starts as .egg |
| xp | Int | earned from care actions |
| level | Int | increases with xp |
| coins | Int | starts at 10 |
| createdAt | Date | |
| lastInteractedAt | Date | |
| stats | PetStats | cascade delete |

### PetStats
| Field | Type | Notes |
|---|---|---|
| hunger | Double | 0–100, starts 80 |
| happiness | Double | 0–100, starts 80 |
| energy | Double | 0–100, starts 100 |
| health | Double | 0–100, starts 100 |
| cleanliness | Double | 0–100, starts 100 |
| social | Double | 0–100, starts 80 |
| magic | Double | 0–100, grows with level |
| knowledge | Double | 0–100, grows from games |
| mood | Mood | recalculated each tick + after every action |
| lastUpdated | Date | |

### Personality (enum)
```swift
case mischievous, dramatic, wild, sage, gentle
```
Order matches left-to-right layout on onboarding screen.

### PetType (enum)
```swift
case rabbit, cat, fox, snake, koala
```

### Mood (enum)
```swift
case happy, excited, sleepy, hungry, sad, sick, playful, curious, grumpy, magical, ascended
```
Currently triggered: happy, excited, sleepy, hungry, sad, sick, curious, magical
Not yet triggered: playful, grumpy, ascended

### LowStat (enum — for dialogue system)
```swift
case hunger, energy, happiness, cleanliness
```

---

## 4. UI Components

### DesktopPetView
- Hosts the floating pet sprite + thought bubble + mood label
- `petSprite` computed property maps mood/action → asset name
- Idle bob: `.offset(y:)` + `.easeInOut(1.5s).repeatForever`
- Context menu: Feed, Pet, Bathe, Sleep | Open Stats | Quit

### ThoughtBubbleView
- Dark rounded rectangle (`backgroundPanel` fill + `accentCool` 1.5pt stroke)
- Italic flavor font, white text, wraps to max 300pt width
- Triangle tail below (angled point, same fill + stroke)
- Shown when `viewModel.currentThought != nil`

### PetWindowController (NSPanel)
- Size: 400×300
- `.borderless`, `.nonActivatingPanel`
- `isOpaque = false`, `backgroundColor = .clear`
- `level = .floating`
- `isMovableByWindowBackground = true`
- Position persisted in UserDefaults

### MenuBarPopoverView
- Pet name + mood badge (color dot + mood name)
- Stat rows: hunger, happy, energy, health — each with custom icon + progress bar
- Progress bar: 120pt fixed width, `accentCool` fill, `surface` track

### OnboardingView
- 6-step flow driven by `OnboardingStep` enum
- Window: 800×600, `backgroundPanel` background
- MainButtonStyle: `surface` fill + `accentCool` 1.5pt stroke border + Playfair Display font

---

## 5. PetEngine

```
Tick interval: 30 seconds

Drain rates (per tick):
  hunger:      2.0
  happiness:   1.5
  energy:      1.0
  cleanliness: 0.5
  social:      1.0

Mood thresholds:
  health < 30    → sick
  hunger < 30    → hungry
  energy < 30    → sleepy
  social < 30    → sad
  happiness < 30 → sad
  magic > 80     → magical
  happiness > 80 + energy > 60 → excited
  happiness > 60 → happy
  default        → curious
```

`recalculateMood` is called:
- Every tick (passive drain)
- Immediately after every care action (via `save()` in PetViewModel)

---

## 6. PetDialogue

Located at `Models/PetDialogue.swift`

`PetDialogue.message(for: LowStat, personality: Personality) -> String`

20 unique lines — one per stat × personality combination. Stat priority when multiple are low: hunger → energy → happiness → cleanliness.

---

## 7. Theme

All design tokens live in `Views/Shared/Theme.swift`.

### Colors
```swift
Theme.Color.backgroundPanel  // #1A1225 deep midnight plum
Theme.Color.surface          // #2D2040 dark violet
Theme.Color.accentCool       // #9B72CF soft lavender
Theme.Color.accentWarm       // #E8A87C amber
Theme.Color.textPrimary      // #F0E6FF pale lilac white
Theme.Color.textMuted        // #8A7AA0 dusty mauve
```

### Fonts
```swift
Theme.Font.heading(_ size: CGFloat)  // Playfair Display
Theme.Font.flavor(_ size: CGFloat)   // italic flavor font
```

### Spacing
```swift
Theme.Spacing.xs  // 4pt
Theme.Spacing.sm  // 8pt
Theme.Spacing.md  // 16pt
```

### MainButtonStyle
Surface fill + accentCool stroke border + heading font. Used on all primary onboarding buttons.

---

## 8. Asset Naming Convention

Sprites: `[petType]_[state]`

| petType | state options |
|---|---|
| rabbit, cat, fox, snake, koala | idle, feed, bath, pet, sleep, dirty, excited, sad, sick, curious, magical |

Stat icons: `icon_hunger`, `icon_happy`, `icon_energy`, `icon_health`
Personality icons: `personality_[name]` (e.g. `personality_mischievous`)
Pet type icons: `pet_icon_[type]` (e.g. `pet_icon_rabbit`)
Onboarding: `egg`, `egg_hatching`, `hatched_[petType]`, `logo`

---

## 9. Current Build Checklist

### Done
- [x] SwiftData models: Pet, PetStats
- [x] PetEngine (30s tick, stat drain, mood recalculation)
- [x] Floating NSPanel (400×300, transparent, draggable)
- [x] DesktopPetView with idle bob animation
- [x] Care actions: Feed, Pet, Bathe, Sleep (sprite swap + stat update)
- [x] Thought bubble with personality-driven dialogue
- [x] Menu bar item + popover (stats + mood badge)
- [x] Full 6-step onboarding (pet type, personality, name, hatch, meet)
- [x] All 5 pet types × 11 mood/action sprites
- [x] Egg shake animation on hatch screen

### In Progress
- [ ] Mood-driven sprite swapping in DesktopPetView (wiring mood enum → correct sprite)
- [ ] Dirty sprite logic (cleanliness < 30 → `[pet]_dirty`, bypasses mood system)
- [ ] Mood badge under the pet (matching menu bar style)
- [ ] Coffee / water / break reminder animations + wellness nudge system

### Next Up
- [ ] Design coffee, water, break sprites in Figma
- [ ] Wellness nudge trigger system (activity timer)

---

*Last updated: 2026-08-17*
