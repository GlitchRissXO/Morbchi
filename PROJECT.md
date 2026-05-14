# Morbchi Project Document
A macOS desktop pet companion app. Tamagotchi on steroids with cozy gothic whimsical vibes.

---

## Concept

**Morbchi** is a magical creature that lives on your Mac desktop. It floats freely on your screen in a transparent, frameless window always present but never in the way. Inspired by classic desktop pets and Tamagotchi-style care mechanics, it blends stat management, branching evolution, AI-powered conversation, mini-games, and deep macOS integration. The pet watches what you're doing and reacts: chatty when you're idle, quiet when you're working, cozy when it's raining outside.

The aesthetic is **cozy gothic whimsical** warm candlelight in a witch's cottage, soft bats, moon motifs, pressed flowers, dark academia warmth.


**Future update idea:** iOS companion app (check stats, quick interactions from phone)


---

## Platform & Tech Stack

| Area | Technology |
|---|---|
| Platform | macOS 14+ (Sonoma) |
| Primary UI | SwiftUI |
| macOS windowing | AppKit (NSPanel, NSWindow, NSStatusBar) |
| Architecture | MVVM + Swift Concurrency (async/await) |
| Persistence | SwiftData |
| Cloud Sync | CloudKit |
| Menu bar | NSStatusBarButton + SwiftUI popover |
| Audio | AVFoundation |
| Notifications | UserNotifications (macOS) |
| Weather | WeatherKit |
| AI Conversation | Claude API (Anthropic) |
| Activity detection | NSWorkspace + CGEventTap |
| Version Control | Git + GitHub |
| Minimum macOS | macOS 14 (Sonoma) |

---

## Aesthetic Direction

**Cozy Gothic Whimsical**

### Color Palette
- Background/window: fully transparent (pet floats directly on desktop)
- Pet ambient glow: `#9B72CF` (soft lavender)
- UI panels: `#1A1225` (deep midnight plum)
- Surface: `#2D2040` (dark violet)
- Accent warm: `#E8A87C` (amber candlelight)
- Accent cool: `#9B72CF` (soft lavender)
- Highlight: `#F4D35E` (golden moon)
- Text primary: `#F0E6FF` (pale lilac white)
- Text muted: `#8A7AA0` (dusty mauve)
- Pop color: `#C97B84` (dusty rose)

### Motifs & Visual Language
- Candles, lanterns, soft glowing light
- Crescent moons, stars, constellation maps
- Mushrooms, moss, pressed botanical flowers
- Bats, black cats, moths, fireflies
- Crystal balls, spell books, potion bottles
- Cobwebs, arched windows, stained glass
- Cozy textures: velvet, wood, stone

### Typography
- Headings: slightly ornate serif (e.g., Playfair Display or similar)
- Body: rounded sans (warm, not harsh)
- Flavor text: italic, slightly whimsical

### Animation Style
- Soft, bouncy, hand-drawn/ pixel feel
- Idle: breathing, blinking, tail swishing, occasional yawn or stretch
- Reactions: heart pops, sparkles, sleepy z's, small rage puffs, glowing aura
- Transitions: fade + gentle float
- Pet casts a soft drop shadow on the desktop beneath it

---

## Desktop Pet Window

This is the heart of the app — how the pet actually lives on your screen.

### Window Behavior
- **NSPanel** with `.nonActivatingPanel` style, never steals focus from your work
- `NSWindowStyleMask.borderless` + fully transparent background
- `NSWindow.Level.floating` stays above normal windows, below system UI
- Draggable — click and drag the pet anywhere on screen
- Position saved between sessions (remembers where you left it)
- Snaps to edges/corners if you drag it near them
- Right-click on pet → context menu (Feed, Sleep, Open Menu, Settings)

### Pet States on Desktop
- **Active (you're working):** pet sits quietly, small idle animation, no interruption
- **Idle (you step away):** pet gets curious, walks around, leaves little notes or items
- **Night mode (late hours):** pet gets sleepy, yawns, eventually curls up
- **Focus mode (fullscreen app detected):** pet minimizes to a tiny icon in corner
- **Break reminder:** after long work sessions, pet taps its foot impatiently

### Activity Awareness (NSWorkspace + CGEventTap)
- Detects idle time vs. active typing/clicking
- Knows which app is frontmost (can react to specific apps)
- Does NOT read content, only detects activity/idle state and app names
- Examples:
  - Open a game → pet gets excited, jumps around
  - Long coding session → pet brings you a virtual coffee/potion
  - Open music app → pet dances
  - Long idle → pet wanders, finds items, writes in journal

---

## The Room (Secondary Window)

A separate, openable window showing your pet's cozy gothic room — the care & management hub.

- Opens from menu bar or right-click pet
- Full room scene: fireplace, bookshelf, window (shows real weather + time of day), rug, bed, cauldron
- Furniture and decor unlockable via shop
- Time-of-day lighting (candles glow brighter at night)
- This is where you access: feeding, bathing, shop, mini-games, journal, stats

---

## Menu Bar Integration

- Small status bar icon (pet mood emoji or tiny sprite)
- Click → popover with: current stats, quick feed button, mood, one-liner from pet
- Option to hide/show desktop pet from here
- Launches Room window

---

## Pet System

### Life Stages (7 stages, branching)
```
Egg
 └─ Sprout (baby)
     ├─ Wisp (neutral)
     ├─ Briar (nature path)
     └─ Shade (shadow path)
         ├─ Familiar (teen — base form)
         ├─ Warden (protector)
         └─ Specter (ethereal)
             ├─ Elder Familiar
             ├─ Archmage
             └─ Ascended (max rarity)
```
Evolution influenced by: care habits, mini-games played, time-of-day patterns, what you feed it.

### Stats (8 core stats)
| Stat | Icon | Description |
|---|---|---|
| Hunger | 🍄 | Depletes over time, feed to restore |
| Happiness | ✨ | Raised by play, social, gifts |
| Energy | 🕯️ | Drains with activity, restored by sleep |
| Health | 🫀 | Affected by neglect, illness, or healing potions |
| Cleanliness | 🌿 | Drops passively, bathe to restore |
| Social | 🦋 | Needs interaction, drops if ignored |
| Magic | 🔮 | Grows with leveling, unlocks spells |
| Knowledge | 📖 | Grows from puzzles, reading, mini-games |

### Moods (12 states)
Happy, Excited, Sleepy, Hungry, Sad, Sick, Playful, Curious, Grumpy, Lonely, Magical, Ascended

Each mood changes idle animation, desktop behavior, dialogue style, and ambient sound.

### AI Personality
- Personality type at creation: *Mischievous*, *Gentle*, *Sage*, *Wild*, or *Dramatic*
- Conversations adapt to mood + personality + what's happened recently
- Pet remembers interactions (SwiftData)
- Claude API for dynamic, in-character responses
- Can chat via a small speech bubble on the desktop or a dedicated chat window

---

## Core Features

### Care Actions (in Room window)
- **Feed** — browse food items (mushroom soup, moon cake, starberry jam, etc.)
- **Bathe** — bubble animation, cleanliness restored
- **Sleep** — tuck in, room dims, ambient fire/rain sounds, time-lapse night cycle
- **Heal** — use potions from inventory
- **Play** — launches a mini-game
- **Talk** — opens AI chat (speech bubble or panel)
- **Gift** — wrap an item, pet has a reaction animation

### Mini-Games (6 planned, in Room window)
| Game | Description | Stats boosted |
|---|---|---|
| Tarot Pull | Flip cards, reveal daily fortune | Happiness, Magic |
| Potion Brew | Match ingredients in timed sequence | Knowledge, Magic |
| Star Map | Connect constellations before time runs out | Knowledge, Happiness |
| Moth Chase | Click flying moths (reaction test) | Happiness (drains Energy) |
| Crystal Sing | Rhythm tap game with glowing crystals | Happiness, Social |
| Shadow Duel | Turn-based combat vs shadow creatures | Magic (risk/reward) |

### Progression
- XP from care, games, conversations → levels up pet
- Coins earned → spent in Shop
- Achievements / Grimoire entries unlock lore and decor
- Daily rituals (morning greeting, evening tuck-in) give bonus XP
- Weekly events tied to moon phases

### Shop
Categories: Food & Potions, Decor & Furniture, Outfits & Accessories, Spell Scrolls, Mystery Box

### Journal / Diary
Pet writes a short entry each day (Claude API, based on actual events). Shown in a leather-bound journal UI panel. Illustrated with small vignettes.

### Photo Capture
- Screenshot your pet on your desktop in a chosen pose
- Decorative gothic frame overlays
- Saved to a photo album in-app

---

## macOS-Specific "On Steroids" Features

| Feature | Description |
|---|---|
| Desktop pet window | Floating, transparent, non-focus-stealing NSPanel |
| Activity awareness | Reacts to idle vs. active, detects frontmost app |
| Menu bar item | Quick stats + actions without opening Room window |
| Work break nudges | Pet gets impatient after long sessions, encourages breaks |
| Weather reactions | WeatherKit rainy = cozy sleepy, sunny = energetic, storm = scared |
| macOS notifications | Pet sends personality-voiced system notifications |
| Night mode behavior | Pet gets sleepy as the hour gets late |
| Seasonal events | Desktop decorations for Halloween, Thanksgiving, Christmas, New Year's, Valentine's Day, Easter, 4th of July |
| iCloud sync | CloudKit pet syncs if you have multiple Macs |
| Finder integration | Pet reacts when you move files around (celebration for big downloads, etc.) |

---

## GitHub Workflow

### Branch Strategy
```
main          — stable releases only
develop       — active development
feature/*     — individual features
fix/*         — bug fixes
design/*      — UI/asset work
```

### Suggested First Feature Branches
- `feature/pet-window` — NSPanel floating transparent window, drag to move
- `feature/pet-model` — SwiftData models for Pet, Stats, Items
- `feature/stat-engine` — stat drain timers, mood calculation
- `feature/room-view` — Room window, care actions UI
- `feature/menubar` — NSStatusBar item + popover

### Releases
Semantic versioning: `v0.1.0` (MVP pet on desktop), `v0.2.0` (mini-games + room), `v1.0.0` (full launch)

---

## Xcode Project Structure

```
Morbchi/
├── App/
│   ├── MorbchiApp.swift         # NSApplicationDelegate, window setup
│   └── AppState.swift
├── Windows/
│   ├── PetWindowController.swift  # NSPanel setup, floating pet window
│   ├── RoomWindowController.swift # Room/care hub window
│   └── MenuBarController.swift    # NSStatusBar item
├── Models/                        # SwiftData models
│   ├── Pet.swift
│   ├── PetStats.swift
│   ├── EvolutionPath.swift
│   ├── Item.swift
│   ├── JournalEntry.swift
│   └── RoomDecor.swift
├── ViewModels/
│   ├── PetViewModel.swift
│   ├── RoomViewModel.swift
│   ├── ShopViewModel.swift
│   └── GamesViewModel.swift
├── Views/
│   ├── Desktop/
│   │   ├── DesktopPetView.swift    # The floating pet on screen
│   │   └── SpeechBubbleView.swift
│   ├── MenuBar/
│   │   └── MenuBarPopoverView.swift
│   ├── Room/
│   │   ├── RoomView.swift
│   │   ├── StatsPanelView.swift
│   │   └── CareActionsView.swift
│   ├── Care/
│   │   ├── FeedView.swift
│   │   ├── BatheView.swift
│   │   └── SleepView.swift
│   ├── Games/
│   │   ├── TarotView.swift
│   │   ├── PotionBrewView.swift
│   │   └── StarMapView.swift
│   ├── Shop/
│   │   └── ShopView.swift
│   ├── Journal/
│   │   └── JournalView.swift
│   └── Shared/
│       ├── GothicButton.swift
│       ├── StatGaugeView.swift
│       └── Theme.swift
├── Services/
│   ├── PetEngine.swift             # stat drain, mood calc, evolution checks
│   ├── ActivityMonitor.swift       # NSWorkspace idle/active detection
│   ├── WeatherService.swift
│   ├── NotificationService.swift
│   ├── AIService.swift             # Claude API calls
│   └── CloudSyncService.swift
├── Utilities/
│   └── Extensions.swift
└── Assets.xcassets
```

---

## Development Phases

### Phase 1 — MVP (v0.1) Pet on Your Desktop
- [ ] Xcode project setup (macOS App target), GitHub repo init
- [ ] NSPanel floating transparent window with draggable pet
- [ ] SwiftData models: Pet, PetStats
- [ ] Stat drain engine (background Timer/async)
- [ ] Basic pet sprite with idle animation
- [ ] 5 basic moods
- [ ] Right-click context menu on pet
- [ ] Menu bar status item with popover (stats + quick feed)

### Phase 2 — Core Loop (v0.2)
- [ ] Room window (full care hub)
- [ ] All 8 stats + 12 moods
- [ ] Core care actions: feed, sleep, bathe, heal
- [ ] Basic shop (coins, 5 items)
- [ ] 2 mini-games (Moth Chase + Crystal Sing)
- [ ] Evolution stage 1 → 2 (Egg → Sprout)
- [ ] macOS notifications (pet voice)
- [ ] Activity monitor (idle vs. active detection)

### Phase 3 — Polish & Depth (v0.3)
- [ ] Full branching evolution (all 7 stages)
- [ ] Remaining 4 mini-games
- [ ] Room customization + decor shop
- [ ] AI chat via Claude API
- [ ] Weather reactions (WeatherKit)
- [ ] Journal with daily AI-written entries
- [ ] Desktop pet reactions to specific apps
- [ ] Night mode behavior

### Phase 4 — Launch (v1.0)
- [ ] iCloud sync (CloudKit)
- [ ] Seasonal events (Halloween, Thanksgiving, Christmas, New Year's, Valentine's Day, Easter, 4th of July)
- [ ] Full audio design
- [ ] Photo capture + album
- [ ] App Store / Notarization

---

## Audio Direction
- Ambient loops: crackling fire, rain on glass, forest night sounds
- UI sounds: soft chimes, crystal pings, page turns, potion bubbles
- Pet sounds: small chirps, purrs, grumbles, happy trills
- Music: lo-fi gothic ambient 

---

## Art Direction Notes
- Pet design: soft, round creature, small spirit with big eyes, floating or short legs, ethereal wisps or small wings, little tail
- Sprite sheets: idle, happy, sad, eating, sleeping, sick, playing, talking, walking (for desktop wandering)
- Desktop pet casts a soft colored glow/shadow beneath it
- Room assets: parallax layers (background → midground → foreground)
- UI panels have slightly worn, handcrafted texture feel

---

## Reference Projects & Games
- [Windows VPet](https://parreirao2.itch.io/windows-vpet) Desktop pet inspo
- [Spiritfarer](https://thunderlotusgames.com/games/spiritfarer/) Emotional care, cozy gothic art direction
- [Hollow Knight](https://www.hollowknight.com/) Dark but beautiful atmosphere
- [Cozy Grove](https://cozygrovegame.com/) Daily ritual loop, journal mechanic
- [Stardew Valley](https://www.stardewvalley.net/) progression pacing, shop/crafting feel
- [Shimeji Browser Extension](https://shimejis.xyz/) Pet behavior model
- [Tamagotchi Smart](https://tamagotchi-official.com/gb/) Modern hardware integration

---

*Last updated: 2026-05-13*
