# Morbchi — Design Document
> System architecture, data flow, user interactions, UI components, and API contracts.
> Single source of truth. Everything in PROJECT.md is captured and expanded here.

---

## 1. Concept

**Morbchi** is a magical creature that lives on your Mac desktop. It floats freely on screen in a transparent, frameless window — always present but never in the way. It watches what you're doing and reacts: chatty when you're idle, quiet when you're working, cozy when it's raining outside. Care for it, watch it evolve through branching life stages, decorate its room, play mini-games together, and chat with it using AI.

**Aesthetic:** Cozy gothic whimsical — warm candlelight in a witch's cottage, soft bats, moon motifs, pressed flowers, dark academia warmth.

**Future:** iOS companion app (check stats, quick interactions from phone) — post-launch.

---

## 2. Platform & Tech Stack

| Area | Technology |
|---|---|
| Platform | macOS 14+ (Sonoma) |
| Primary UI | SwiftUI |
| macOS windowing | AppKit (NSPanel, NSWindow, NSStatusBar) |
| Architecture | MVVM + Swift Concurrency (async/await) |
| Persistence | SwiftData |
| Cloud sync | CloudKit |
| Menu bar | NSStatusBarButton + SwiftUI popover |
| Audio | AVFoundation |
| Notifications | UserNotifications (macOS) |
| Weather | WeatherKit |
| AI conversation | Claude API (Anthropic) |
| Activity detection | NSWorkspace + CGEventTap |
| Version control | Git + GitHub |
| Minimum macOS | macOS 14 (Sonoma) |

---

## 3. Aesthetic Direction

### Color Palette
| Role | Hex | Description |
|---|---|---|
| Window background | transparent | pet floats directly on desktop |
| Pet ambient glow | `#9B72CF` | soft lavender |
| UI panels | `#1A1225` | deep midnight plum |
| Surface | `#2D2040` | dark violet |
| Accent warm | `#E8A87C` | amber candlelight |
| Accent cool | `#9B72CF` | soft lavender |
| Highlight | `#F4D35E` | golden moon |
| Text primary | `#F0E6FF` | pale lilac white |
| Text muted | `#8A7AA0` | dusty mauve |
| Pop | `#C97B84` | dusty rose |

### Motifs & Visual Language
- Candles, lanterns, soft glowing light
- Crescent moons, stars, constellation maps
- Mushrooms, moss, pressed botanical flowers
- Bats, black cats, moths, fireflies
- Crystal balls, spell books, potion bottles
- Cobwebs, arched windows, stained glass
- Cozy textures: velvet, wood, stone

### Typography
- Headings: slightly ornate serif (Playfair Display or similar)
- Body: rounded sans-serif (warm, not harsh)
- Flavor text: italic, slightly whimsical

### Animation Style
- Soft, bouncy, hand-drawn / pixel feel
- Idle: breathing, blinking, tail swishing, occasional yawn or stretch
- Reactions: heart pops, sparkles, sleepy z's, small rage puffs, glowing aura
- Transitions: fade + gentle float
- Pet casts a soft colored drop shadow on the desktop beneath it

### Art Direction
- Pet design: soft, round creature — small spirit with big eyes, floating or short legs, ethereal wisps or small wings, little tail
- Sprite sheets needed: idle, happy, sad, eating, sleeping, sick, playing, talking, walking (desktop wandering)
- Room assets: parallax layers (background → midground → foreground)
- UI panels have a slightly worn, handcrafted texture feel

### Audio Direction
- Ambient loops: crackling fire, rain on glass, forest night sounds
- UI sounds: soft chimes, crystal pings, page turns, potion bubbles
- Pet sounds: small chirps, purrs, grumbles, happy trills
- Music: lo-fi gothic ambient (Hollow Knight + Spiritfarer vibes)

---

## 4. User Definition

One user type: **The Caretaker** — the person who owns and cares for the Morbchi.

### Caretaker States
| State | Description |
|---|---|
| First-time | App installed, no pet exists. Needs onboarding + pet creation. |
| Daily returner | Opens app, checks on pet, does care actions, maybe plays a mini-game. |
| Passive | App running in background, pet living on desktop. No active interaction. |
| Neglectful | Away a long time. Stats have dropped. Pet is in distress. |
| Engaged | Actively playing mini-games, decorating room, chatting with pet. |

---

## 5. High-Level System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        macOS System                         │
│                                                             │
│   ┌─────────────┐   ┌──────────────┐   ┌────────────────┐  │
│   │  Desktop Pet │   │  Menu Bar    │   │  Room Window   │  │
│   │  (NSPanel)  │   │  (NSStatus)  │   │  (NSWindow)    │  │
│   └──────┬──────┘   └──────┬───────┘   └───────┬────────┘  │
│          │                 │                   │            │
│          └─────────────────┼───────────────────┘            │
│                            │                                │
│                    ┌───────▼────────┐                       │
│                    │  PetViewModel  │                       │
│                    │  (MVVM brain)  │                       │
│                    └───────┬────────┘                       │
│                            │                                │
│           ┌────────────────┼──────────────────┐            │
│           │                │                  │            │
│   ┌───────▼──────┐ ┌───────▼──────┐ ┌────────▼───────┐    │
│   │  PetEngine   │ │  SwiftData   │ │    Services    │    │
│   │ (stat drain) │ │  (on-disk)   │ │ Weather/AI/    │    │
│   │              │ │              │ │ Notifications  │    │
│   └──────────────┘ └──────────────┘ └────────┬───────┘    │
└───────────────────────────────────────────────┼────────────┘
                                                │
                              ┌─────────────────┼─────────────┐
                              │   External APIs               │
                              │  ┌──────────────▼──┐          │
                              │  │   Claude API    │          │
                              │  └─────────────────┘          │
                              │  ┌─────────────────┐          │
                              │  │   WeatherKit    │          │
                              │  └─────────────────┘          │
                              └───────────────────────────────┘
```

---

## 6. Data Flow

### 6a. Stat Drain (passive, background)
```
Every 60 seconds:
PetEngine.tick()
  → drains stats (hunger, happiness, energy, cleanliness, social)
  → recalculates Mood
  → calls context.save()
  → PetViewModel publishes change
  → DesktopPetView re-renders
  → MenuBar icon updates
```

### 6b. Care Action (user triggered)
```
User opens Room window → Care tab → taps Feed
  → FeedView shows scrollable food item grid
  → User selects item
  → PetViewModel.feed(item) updates PetStats
  → PetViewModel calls context.save()
  → PetEngine recalculates mood
  → UI re-renders with new mood
  → Toast shows "+20 Hunger"
```

### 6c. AI Chat
```
User opens Talk panel → types message
  → AIService.sendMessage(text, petPersonality, currentMood, recentEvents)
  → POST to Claude API
  → Claude returns in-character response
  → Response shown in speech bubble or chat panel
  → Interaction logged to SwiftData (JournalEntry)
```

### 6d. Weather
```
App launches + every 3 hours:
WeatherService.fetchCurrent()
  → GET from WeatherKit (user location)
  → Returns condition (rain, sun, storm, snow, etc.)
  → PetViewModel applies mood modifier
  → Room window background scene updates to reflect weather
```

### 6e. Activity Monitor
```
NSWorkspace + CGEventTap running continuously:
  → Detects idle vs. active (typing/clicking)
  → Detects frontmost app name
  → Does NOT read content — only state + app name
  → PetViewModel updates desktop behavior state:
      working  → pet sits quietly
      idle     → pet wanders, finds items, leaves notes
      gaming   → pet gets excited, jumps around
      music    → pet dances
      long session → pet brings you a virtual coffee/ energy potion
      late night   → pet gets sleepy, yawns, curls up
      fullscreen   → pet shrinks to corner icon
      Open a music app   → pet dances
```

### 6f. First Launch
```
App opens → SwiftData fetch returns empty
  → Show OnboardingView
  → User enters pet name + picks personality
  → Pet + PetStats created and saved
  → PetEngine starts
  → Egg hatch animation plays
  → Desktop pet window appears
```

### 6g. Persistence
```
SwiftData (local, on device)
  └── Pet, PetStats, Items, Inventory, JournalEntries, RoomDecor, Achievements

CloudKit (iCloud, optional)
  └── Mirrors SwiftData container across user's Macs
  └── Only active if user is signed into iCloud
```

### 6h. Photo Capture
```
User opens Photo mode → pet poses
  → ScreenshotService captures pet window
  → User picks gothic frame overlay
  → Saved to in-app PhotoAlbum (SwiftData)
  → Option to export to macOS Photos or share
```

### 6i. Progression & Evolution
```
XP earned from: care actions, mini-games, conversations, daily rituals
  → Level increases when XP threshold met
  → Magic stat grows +5 per level
  → Evolution check runs on level up:
      Evaluate: care habits, games played, time-of-day patterns, food given
      → Determines which branch pet evolves into
      → Evolution animation plays
      → New sprite set loads

Coins earned from: mini-games, daily rituals, achievements
  → Spent in Shop on food, potions, decor, accessories, scrolls
```

### 6j. Daily Rituals & Weekly Events
```
Morning greeting (first interaction of the day) → bonus XP
Evening tuck-in (sleep action after 8pm) → bonus XP + happiness

Weekly moon phase events:
  New Moon    → Mystery Box available in shop
  Full Moon   → Magic stat drain paused, bonus magic XP
  Waxing      → Happiness drain slowed
  Waning      → Spooky desktop decorations appear
```

---

## 7. Desktop Pet Window

### Window Technical Specs
| Property | Value |
|---|---|
| Window type | `NSPanel` |
| Style | `.nonActivatingPanel` — never steals focus from active work |
| Background | `NSWindowStyleMask.borderless` + fully transparent |
| Level | `NSWindow.Level.floating` — above normal windows, below system UI |
| Position | Saved to `UserDefaults` on drag release, restored on next launch |

### Snap Behavior
When the user drags the pet near a screen edge or corner, the window snaps to align with it. Snap zones:
- All 4 corners
- Top, bottom, left, right edges (centered)
- Threshold: within ~20pt of edge triggers snap

### Pet Desktop States
| State | Trigger | Behavior |
|---|---|---|
| Active | User typing/clicking | Sits quietly, small idle animation only |
| Idle | No input for ~3 min | Gets curious, wanders screen, leaves notes/items |
| Night mode | System clock after ~10pm | Gets sleepy, yawns, eventually curls up |
| Focus mode | Fullscreen app detected | Shrinks to small corner icon |
| Break reminder | Active session > ~90 min | Taps foot impatiently, shows nudge bubble |

---

## 8. User Interaction Map

### Desktop Pet (always visible)
```
Left-click          → poke/cuddle animation
Right-click         → context menu:
                         Open Room
                         ─────────
                         Quit Morbchi
Drag                → moves window, snaps to edges/corners, saves position on release
Double-click        → opens Room window
Hover               → speech bubble shows mood one-liner from pet
```
> Note: All care actions (Feed, Bathe, Sleep, etc.) live inside the Room window.
> The right-click menu is for navigation only.

### Menu Bar
```
Click icon          → popover opens:
                         Pet name + mood badge
                         Mini stat bars (hunger, happiness, energy)
                         One-liner quip from pet
                         [ Quick Feed ] button  ← convenience shortcut, no need to open Room
                         [ Open Room ] button
                         [ Hide / Show pet ] toggle
```

### Room Window
```
Sidebar navigation:
  🍄 Care           → CareTabView (Feed, Bathe, Sleep, Heal, Gift, Talk)
  📊 Stats          → StatsPanelView (all 8 gauges)
  🎮 Play           → MiniGameLauncherView (6 games)
  🛒 Shop           → ShopView (by category)
  📖 Journal        → JournalView (daily diary)
  📷 Photos         → PhotoAlbumView
  🏆 Grimoire       → AchievementsView
  ⚙️ Settings       → SettingsView

Room scene:
  Fireplace, bookshelf, arched window, rug, bed, cauldron
  Click furniture   → inspect / interact
  Drag decor        → rearrange
  Time-of-day       → candles glow brighter at night
  Weather window    → reflects real current weather
```

### Care Actions (inside Room → Care tab)
| Action | Description | Stats affected |
|---|---|---|
| Feed | Opens FeedView — scrollable food item grid | Hunger +, Happiness + |
| Bathe | Bubble animation, cleanses pet | Cleanliness → 100 |
| Sleep | Room dims, fire/rain sounds, time-lapse night | Energy → 100 |
| Heal | Use potion from inventory | Health + |
| Gift | Wrap an item, pet has reaction animation | Happiness +, Social + |
| Talk | Opens AI chat panel | Social +, logged to Journal |

### Onboarding (first launch only)
```
Screen 1: Welcome + app intro
Screen 2: Name your Morbchi (text input + live preview)
Screen 3: Pick personality (5 cards: Mischievous, Gentle, Sage, Wild, Dramatic)
Screen 4: Egg hatch animation
Screen 5: Pet appears on desktop for the first time
```

---

## 9. Pet System

### Life Stages — Branching Evolution Tree
```
Egg
 └─ Sprout (baby)
     ├─ Wisp (neutral path)
     ├─ Briar (nature path)
     └─ Shade (shadow path)
         ├─ Familiar (teen — base form)
         ├─ Warden (protector)
         └─ Specter (ethereal)
             ├─ Elder Familiar
             ├─ Archmage
             └─ Ascended (max rarity)
```

**What influences evolution:**
- Care habits (how often fed, bathed, slept)
- Which mini-games are played most
- Time-of-day activity patterns (night owl vs. morning)
- What food is given (nature foods → Briar, shadow foods → Shade)

### Stats (8 core stats)
| Stat | Icon | Drain | Restored by |
|---|---|---|---|
| Hunger | 🍄 | Fastest | Feeding |
| Happiness | ✨ | Moderate | Play, social, gifts |
| Energy | 🕯️ | Moderate | Sleep |
| Health | 🫀 | Only from neglect/illness | Heal potions |
| Cleanliness | 🌿 | Slow | Bathe |
| Social | 🦋 | Moderate | Talk, cuddle, gifts |
| Magic | 🔮 | Does not drain | Levels up, mini-games |
| Knowledge | 📖 | Does not drain | Mini-games, puzzles |

### Moods (12 states)
| Mood | Trigger condition |
|---|---|
| Happy | Happiness > 60 |
| Excited | Happiness > 80 + Energy > 60 |
| Sleepy | Energy < 20 |
| Hungry | Hunger < 20 |
| Sad | Happiness < 20 |
| Sick | Health < 20 |
| Playful | After mini-game |
| Curious | Default / none of the above |
| Grumpy | Multiple stats low |
| Lonely | Social < 20 |
| Magical | Magic > 80 |
| Ascended | Max evolution stage |

Each mood changes: idle animation, desktop behavior, dialogue style, ambient sound.

### AI Personality (set at creation, permanent)
| Personality | Tone |
|---|---|
| Mischievous | Playful, sarcastic, teasing |
| Gentle | Soft, warm, encouraging |
| Sage | Wise, cryptic, thoughtful |
| Wild | Energetic, chaotic, excitable |
| Dramatic | Over-the-top, theatrical, emotional |

---

## 10. Mini-Games

All 6 games launch from Room → Play tab.

| Game | Description | Stats boosted | Stats risked |
|---|---|---|---|
| Tarot Pull | Flip cards, reveal daily fortune | Happiness, Magic | — |
| Potion Brew | Match ingredients in timed sequence | Knowledge, Magic | — |
| Star Map | Connect constellations before time runs out | Knowledge, Happiness | — |
| Moth Chase | Click flying moths (reaction test) | Happiness | Energy (drains) |
| Crystal Sing | Rhythm tap game with glowing crystals | Happiness, Social | — |
| Shadow Duel | Turn-based combat vs shadow creatures | Magic | Health (risk/reward) |

---

## 11. Shop

Categories:
| Category | Contents |
|---|---|
| Food & Potions | Mushroom soup, moon cake, starberry jam, healing potions, energy tonics |
| Decor & Furniture | Room items: rugs, candles, bookshelves, cauldrons, plants |
| Outfits & Accessories | Hats, capes, bows, collars for the pet |
| Spell Scrolls | One-use items that grant stat boosts or special effects |
| Mystery Box | Random item, available during New Moon weekly event |

Coins earned from: mini-games, daily rituals, achievements.

---

## 12. Data Models

### Pet
| Field | Type | Notes |
|---|---|---|
| id | UUID | auto |
| name | String | user-set at creation |
| personality | Personality (enum) | permanent |
| lifeStage | LifeStage (enum) | changes on evolution |
| xp | Int | earned through interactions |
| level | Int | increases with xp |
| coins | Int | earned, spent in shop |
| createdAt | Date | |
| lastInteractedAt | Date | neglect detection |
| stats | PetStats | one-to-one |
| inventory | [Item] | owned items |
| journalEntries | [JournalEntry] | daily diary |
| achievements | [Achievement] | unlocked milestones |
| photos | [PetPhoto] | captured moments |

### PetStats
| Field | Type | Notes |
|---|---|---|
| hunger | Double | 0–100 |
| happiness | Double | 0–100 |
| energy | Double | 0–100 |
| health | Double | 0–100 |
| cleanliness | Double | 0–100 |
| social | Double | 0–100 |
| magic | Double | 0–100, grows with level |
| knowledge | Double | 0–100, grows from games |
| mood | Mood (enum) | recalculated each tick |
| lastUpdated | Date | timestamp of last tick |

### Item
| Field | Type | Notes |
|---|---|---|
| id | UUID | |
| name | String | "Moon Cake", "Starberry Jam" |
| type | ItemType (enum) | food, potion, decor, accessory, scroll |
| effect | [StatEffect] | which stats it changes and by how much |
| cost | Int | shop price in coins |
| iconName | String | asset name |
| description | String | flavor text |
| evolutionInfluence | EvolutionPath? | e.g. nature foods nudge toward Briar |

### JournalEntry
| Field | Type | Notes |
|---|---|---|
| id | UUID | |
| date | Date | one per day |
| content | String | AI-generated diary text |
| mood | Mood | mood at time of writing |
| highlightEvent | String? | notable thing that happened |

### RoomDecor
| Field | Type | Notes |
|---|---|---|
| id | UUID | |
| itemName | String | |
| positionX | Double | saved room position |
| positionY | Double | |
| isPlaced | Bool | in room vs. in inventory |

### Achievement
| Field | Type | Notes |
|---|---|---|
| id | UUID | |
| title | String | "First Feeding", "Level 10", etc. |
| description | String | flavor text / lore |
| unlockedAt | Date? | nil if not yet unlocked |
| rewardCoins | Int | coins granted on unlock |
| rewardDecor | String? | decor item unlocked |

### PetPhoto
| Field | Type | Notes |
|---|---|---|
| id | UUID | |
| imageData | Data | screenshot |
| frameStyle | String | gothic frame overlay name |
| capturedAt | Date | |
| mood | Mood | pet's mood at capture time |

### EvolutionPath (tracks what influences evolution)
| Field | Type | Notes |
|---|---|---|
| id | UUID | |
| natureFoodCount | Int | nudges toward Briar |
| shadowFoodCount | Int | nudges toward Shade |
| nightActivityScore | Int | late-night interactions |
| morningActivityScore | Int | |
| gamesPlayed | [String: Int] | game name → times played |

---

## 13. External API Contracts

### Claude API — Pet Chat
**When:** User opens Talk panel and sends a message.

**POST** to Claude API
```
Input:
{
  system_prompt: "You are [name], a [personality] creature.
                  Current mood: [mood].
                  Recent events: [last 3 journal highlights].
                  Speak in character. Max 2 sentences.",
  user_message: "[what the user typed]"
}

Response:
{
  content: "[in-character reply]"
}
```
Reply shown in speech bubble or chat panel. Logged to JournalEntry.

---

### WeatherKit — Current Conditions
**When:** App launch + every 3 hours.

**GET** current weather for device location
```
Returns:
  condition: sunny | cloudy | rainy | stormy | snowy | windy
  temperature: Double
  isDaytime: Bool

Mood modifiers applied:
  sunny   → happiness +5/hr bonus
  rainy   → energy drain -50%, cozy bonus
  stormy  → happiness -10, fear state possible
  snowy   → seasonal winter decorations trigger
```

---

## 14. Services

| Service | File | Responsibility |
|---|---|---|
| PetEngine | `PetEngine.swift` ✓ | Stat drain timer, mood recalculation, context.save |
| AIService | `AIService.swift` | Claude API calls, prompt construction |
| WeatherService | `WeatherService.swift` | WeatherKit fetch, condition → mood modifier |
| NotificationService | `NotificationService.swift` | macOS notifications in pet's personality voice |
| ActivityMonitor | `ActivityMonitor.swift` | NSWorkspace idle/active, frontmost app, Finder events |
| CloudSyncService | `CloudSyncService.swift` | CloudKit sync, conflict resolution |
| SoundService | `SoundService.swift` | AVFoundation ambient loops + UI sounds |
| ScreenshotService | `ScreenshotService.swift` | Capture pet window, apply frame overlay |

---

## 15. ViewModels

| ViewModel | Responsibility |
|---|---|
| `PetViewModel` ✓ | Pet data, care actions, XP/leveling, context.save |
| `RoomViewModel` | Room scene state, time-of-day lighting, weather display |
| `ShopViewModel` | Item catalog, purchase logic, coin transactions |
| `GamesViewModel` | Mini-game launch, result handling, stat rewards |

---

## 16. UI Components

### Shared / Design System
- `Theme.swift` ✓ — colors, fonts, spacing constants
- `GothicButton` — styled button with worn-texture feel
- `StatGaugeView` — single stat bar (icon + label + fill bar)
- `StatsPanelView` — all 8 stats displayed together
- `MoodBadgeView` — small pill showing current mood
- `SpeechBubbleView` — floating dialogue bubble above pet
- `ToastView` — brief overlay ("Fed! +20 Hunger")

### Desktop Layer
- `DesktopPetView` ✓ — floating pet, right-click menu (Open Room + Quit only)
- Pet sprite system — replaces emoji placeholder with sprite sheet
- Idle animation loop
- Reaction animations (hearts, sparkles, z's, rage puffs, glow)

### Menu Bar
- `MenuBarController` — NSStatusBar item setup
- `MenuBarPopoverView` — pet name, mood, mini stats, one-liner, Open Room, Hide toggle

### Onboarding
- `OnboardingView` — welcome screen
- `NameInputView` — text field + live preview
- `PersonalityPickerView` — 5 personality cards
- `HatchAnimationView` — egg crack → pet reveal

### Room Window
- `RoomView` — main container (scene + sidebar navigation)
- `RoomSceneView` — parallax background art, furniture, weather window, time-of-day lighting
- `CareTabView` — Feed, Bathe, Sleep, Heal, Gift, Talk action buttons
- `FeedView` — scrollable food item grid
- `BatheView` — bubble animation
- `SleepView` — room dims, ambient sound, night cycle animation
- `HealView` — potion selection from inventory
- `GiftView` — item wrapping + pet reaction
- `ChatView` — AI conversation panel
- `StatsPanelView` — full 8-stat gauges
- `ShopView` — item grid by category (Food, Decor, Outfits, Scrolls, Mystery Box)
- `JournalView` — leather book UI, daily AI-written entries with small vignettes
- `PhotoAlbumView` — captured pet moments with gothic frame overlays
- `AchievementsView` — Grimoire of unlocked achievements + lore entries
- `MiniGameLauncherView` — 6 game cards with description + stat preview
- `SettingsView` — name, notifications, sound, iCloud toggle

### Mini-Game Views
- `TarotView`
- `PotionBrewView`
- `StarMapView`
- `MothChaseView`
- `CrystalSingView`
- `ShadowDuelView`

---

## 17. Xcode Project Structure

```
Morbchi/
├── App/
│   ├── MorbchiApp.swift
│   ├── AppDelegate.swift
│   └── AppState.swift
├── Windows/
│   ├── PetWindowController.swift
│   ├── RoomWindowController.swift
│   └── MenuBarController.swift
├── Models/
│   ├── Pet.swift
│   ├── PetStats.swift
│   ├── EvolutionPath.swift
│   ├── Item.swift
│   ├── JournalEntry.swift
│   ├── RoomDecor.swift
│   ├── Achievement.swift
│   └── PetPhoto.swift
├── ViewModels/
│   ├── PetViewModel.swift
│   ├── RoomViewModel.swift
│   ├── ShopViewModel.swift
│   └── GamesViewModel.swift
├── Views/
│   ├── Desktop/
│   │   ├── DesktopPetView.swift
│   │   └── SpeechBubbleView.swift
│   ├── MenuBar/
│   │   └── MenuBarPopoverView.swift
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   │   ├── NameInputView.swift
│   │   ├── PersonalityPickerView.swift
│   │   └── HatchAnimationView.swift
│   ├── Room/
│   │   ├── RoomView.swift
│   │   ├── RoomSceneView.swift
│   │   └── CareTabView.swift
│   ├── Care/
│   │   ├── FeedView.swift
│   │   ├── BatheView.swift
│   │   ├── SleepView.swift
│   │   ├── HealView.swift
│   │   ├── GiftView.swift
│   │   └── ChatView.swift
│   ├── Games/
│   │   ├── MiniGameLauncherView.swift
│   │   ├── TarotView.swift
│   │   ├── PotionBrewView.swift
│   │   ├── StarMapView.swift
│   │   ├── MothChaseView.swift
│   │   ├── CrystalSingView.swift
│   │   └── ShadowDuelView.swift
│   ├── Shop/
│   │   └── ShopView.swift
│   ├── Journal/
│   │   └── JournalView.swift
│   ├── Photos/
│   │   └── PhotoAlbumView.swift
│   ├── Achievements/
│   │   └── AchievementsView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── Shared/
│       ├── Theme.swift
│       ├── GothicButton.swift
│       ├── StatGaugeView.swift
│       ├── StatsPanelView.swift
│       ├── MoodBadgeView.swift
│       ├── ToastView.swift
│       └── SpeechBubbleView.swift
├── Services/
│   ├── PetEngine.swift
│   ├── AIService.swift
│   ├── WeatherService.swift
│   ├── NotificationService.swift
│   ├── ActivityMonitor.swift
│   ├── CloudSyncService.swift
│   ├── SoundService.swift
│   └── ScreenshotService.swift
├── Utilities/
│   └── Extensions.swift
└── Assets.xcassets
```

---

## 18. Build Order

### Phase 1 — Pet is alive on desktop (v0.1)
- [x] Xcode project + GitHub setup
- [x] SwiftData models: Pet, PetStats
- [x] PetEngine stat drain + mood recalculation
- [x] Floating NSPanel window (PetWindowController)
- [x] DesktopPetView placeholder
- [ ] Fix persistence — store ModelContext in PetViewModel, call save() after every action and every tick
- [x] Onboarding flow — NameInputView + PersonalityPickerView + HatchAnimationView
- [x] MenuBar item — MenuBarController + MenuBarPopoverView
- [ ] Strip care actions from right-click menu (Open Room + Quit only)
- [ ] Real pet sprite replacing emoji placeholder

### Phase 2 — Room + core loop (v0.2)
- [ ] RoomWindowController + RoomView + RoomSceneView
- [ ] StatsPanelView (all 8 gauges)
- [ ] CareTabView with all 6 actions
- [ ] FeedView — scrollable food item grid
- [ ] BatheView, SleepView, HealView, GiftView
- [ ] ShopViewModel + ShopView (5 food items to start)
- [ ] Coin system
- [ ] Evolution stage 1 → 2 (Egg → Sprout)
- [ ] macOS notifications (NotificationService)
- [ ] ActivityMonitor (idle vs. active detection)

### Phase 3 — Depth (v0.3)
- [ ] All 6 mini-games
- [ ] Full branching evolution (all 7 stages)
- [ ] Full shop (all categories)
- [ ] Room customization + decor placement
- [ ] AIService + ChatView (Claude API)
- [ ] JournalView with AI-written entries
- [ ] WeatherService + mood modifiers + room scene weather
- [ ] Desktop pet reactions to specific apps
- [ ] Night mode behavior
- [ ] Achievement system + AchievementsView (Grimoire)
- [ ] PhotoAlbumView + ScreenshotService
- [ ] Daily rituals + moon phase weekly events
- [ ] SoundService — ambient loops + UI sounds

### Phase 4 — Launch (v1.0)
- [ ] CloudSyncService (iCloud via CloudKit)
- [ ] Seasonal events — desktop decorations + special items for Halloween, Thanksgiving, Christmas, New Year's, Valentine's Day, Easter, 4th of July
- [ ] Full audio design + music
- [ ] App Store assets + notarization + submission

---

## 19. GitHub Workflow

### Branch Strategy
```
main        — stable releases only
develop     — active development
feature/*   — individual features
fix/*       — bug fixes
design/*    — UI/asset work
```

### Suggested First Feature Branches
- `feature/pet-window` — NSPanel floating transparent window, drag + snap behavior
- `feature/pet-model` — SwiftData models for Pet, Stats, Items
- `feature/stat-engine` — stat drain timers, mood calculation
- `feature/room-view` — Room window, care actions UI
- `feature/menubar` — NSStatusBar item + popover

### Releases
Semantic versioning:
- `v0.1.0` — MVP: pet on desktop
- `v0.2.0` — Room + core loop
- `v0.3.0` — Depth: mini-games, AI, weather, evolution
- `v1.0.0` — Full launch

---

## 20. Reference Projects
- [Windows VPet](https://parreirao2.itch.io/windows-vpet) — desktop pet + activity awareness inspo
- Spiritfarer — emotional care mechanics, cozy gothic art
- Hollow Knight — dark but beautiful atmosphere
- Cozy Grove — daily ritual loop, journal mechanic
- Stardew Valley — progression pacing, shop/crafting
- Shimeji — desktop pet wandering behavior model
- Tamagotchi Smart — modern hardware integration ideas

---

*Last updated: 2026-05-14*
