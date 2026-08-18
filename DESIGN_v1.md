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
  → drains: hunger(-0.5), happiness(-0.4), energy(-0.3), cleanliness(-0.15), social(-0.3)
  → stat interactions: low stats drain health faster (hunger<15, energy<15, cleanliness<30, happiness<15, social<15)
  → positive recovery: hunger/happiness/energy > 70 each restore health +0.1/tick
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
      → stats.hunger += 20, stats.happiness += 5, stats.health += 2
      → addXP(5)
      → save()
          → engine.recalculateMood(stats)   ← immediate mood update
          → checkAndShowThought()           ← thought bubble check
          → context.save()
```

### Sleep Action
```
User right-clicks pet → selects Sleep
  → PetViewModel.sleep()
      → currentAction = "sleep"             ← set first so sprite locks immediately
      → stats.energy += 50, stats.health += 5
      → addXP(3)
      → save()
          → engine.recalculateMood(stats)
          → checkAndShowThought()           ← returns early (suppressed during sleep)
          → context.save()
      → Task.sleep(15 min) → currentAction = nil
```

### Thought Bubble Trigger
```
checkAndShowThought():
  if currentAction == "sleep" → currentThought = nil (suppressed during nap)
  if health < 20   → show sick dialogue for pet's personality
  if hunger < 30   → show hunger dialogue
  if energy < 30   → show energy dialogue
  if happiness < 30 → show happiness dialogue
  if cleanliness < 30 → show cleanliness dialogue
  else             → currentThought = nil (bubble hides)
```

### Sprite Selection
```
petSprite computed property:
  if currentAction != nil → "[petType]_[currentAction]"   (action sprite; 2s for most, 15 min for sleep)
  else if health < 20     → "[petType]_sick"              (health state, overrides mood)
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
case hunger, energy, happiness, cleanliness, sick
```

---

## 4. UI Components

### DesktopPetView
- Hosts the floating pet sprite + thought bubble + mood badge
- `petSprite` computed property: action → sick → dirty → mood
- Idle bob: `.offset(y:)` + `.easeInOut(1.5s).repeatForever`
- Context menu: Feed, Pet, Bathe, Sleep | Open Stats | Quit

### ThoughtBubbleView
- Dark rounded rectangle (`backgroundPanel` fill + `accentCool` 1.5pt stroke)
- Italic flavor font, white text, wraps to max 300pt width
- Triangle tail below (angled point, same fill + stroke)
- Shown when `viewModel.currentThought != nil`

### MoodBadgeView (shared)
- Color dot + mood name label on surface background
- Used in both DesktopPetView (under the pet) and MenuBarPopoverView
- Dot color varies by mood

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
- Progress bar: 120pt fixed width, `accentWarm` fill, `surface` track

### OnboardingView
- 6-step flow driven by `OnboardingStep` enum
- Window: 800×600, `backgroundPanel` background
- MainButtonStyle: `surface` fill + `accentCool` 1.5pt stroke border + Playfair Display font

---

## 5. PetEngine

```
Tick interval: 30 seconds

Drain rates (per tick):
  hunger:      0.5
  happiness:   0.4
  energy:      0.3
  cleanliness: 0.15
  social:      0.3

Stat interactions (per tick):
  hunger < 15      → energy -0.3, happiness -0.3, health -0.2
  energy < 15      → health -0.2, happiness -0.2
  cleanliness < 30 → health -0.2, happiness -0.2, energy -0.15
  happiness < 15   → health -0.2
  social < 15      → health -0.2

Positive recovery (per tick):
  hunger > 70    → health +0.1
  happiness > 70 → health +0.1
  energy > 70    → health +0.1

Mood thresholds:
  health < 20    → sick
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

25 unique lines — one per stat × personality combination (5 stats × 5 personalities). Stat priority when multiple are low: sick (health < 20) → hunger → energy → happiness → cleanliness.

---

## 7. Theme

All design tokens live in `Views/Shared/Theme.swift`.

### Colors
```swift
Theme.Color.backgroundPanel  // #1A1225 deep midnight plum
Theme.Color.surface          // #2D2040 dark violet
Theme.Color.accentCool       // #9B72CF soft lavender
Theme.Color.accentWarm       // #E8A87C amber
Theme.Color.highlight        // #F4D35E golden yellow
Theme.Color.textPrimary      // #F0E6FF pale lilac white
Theme.Color.textMuted        // #8A7AA0 dusty mauve
Theme.Color.pop              // #C97B84 muted rose
Theme.Color.sage             // #7AAB5F muted green
```

### Fonts
```swift
Theme.Font.heading(_ size: CGFloat)  // Playfair Display Bold
Theme.Font.flavor(_ size: CGFloat)   // Playfair Display Italic
Theme.Font.body(_ size: CGFloat)     // system rounded
```

### Spacing
```swift
Theme.Spacing.xs  // 4pt
Theme.Spacing.sm  // 8pt
Theme.Spacing.md  // 16pt
Theme.Spacing.lg  // 24pt
Theme.Spacing.xl  // 40pt
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
- [x] Mood-driven sprite swapping (petSprite priority: action → sick → dirty → mood)
- [x] Dirty sprite logic (cleanliness < 30 → `[pet]_dirty`, bypasses mood system)
- [x] MoodBadgeView shared component (used under pet + in menu bar popover)
- [x] Health as primary wellness stat (all stats influence health positively or negatively)
- [x] Stat interaction system (neglect chains drain health faster)
- [x] Sick dialogue + thought bubble priority (health → hunger → energy → happiness → cleanliness)
- [x] Sleep nap overhaul (15 min duration, +50 energy, +5 health, thought bubbles suppressed)

### Next Up
- [ ] Coffee / water / break reminder animations (needs Figma design first)
- [ ] Wellness nudge trigger system (activity timer)

---

*Last updated: 2026-08-18*
