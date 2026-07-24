# Product Requirements Document (PRD)

# NanoCraft — Create, Share & Solve Nonogram Puzzles

**Version:** MVP v3.0 (Final)
**Platform:** Android (Flutter)
**Target Release:** 7–9 Weeks (solo/small-team build)

---

## 1. Vision

NanoCraft lets anyone turn an image or a short word into a playable Nonogram puzzle and share it with others.

Core loop: **create → publish → discover → solve.**
Everything not load-bearing for that loop is deferred to Phase 2 (Section 13).

---

## 2. Changelog from v2 → v3

| Area | v2 | v3 (this doc) | Reason |
|---|---|---|---|
| Text puzzles | Single word ≤5 chars only | **Restored multi-round mode**, with corrected math | It's a real differentiator vs. other Nonogram apps, and cheap to build once the capacity constraint is respected. |
| Difficulty | Manual creator selection (implied) | **Auto-calculated** from fill %, clue count, fragmentation | Removes inconsistent manual labeling. |
| Drafts | Not specified | **Added** — local Hive-backed draft saving | Cheap, real UX win for the create flow. |
| Reports | `reportCount` int on level doc | **Separate `reports` collection** | A counter can't support "who reported, what reason, when" — needed for any real moderation. |
| Architecture | Presentation/Domain/Data global layers | **Feature-first modules**, each with its own presentation/domain/data | Scales better without added MVP cost. |
| Theme | Original palette | Slightly cooler/cleaner palette | Cosmetic only. |
| Micro-interactions | Base set | **+ green flash on completed row/column** | Cheap, adds game feel. |
| Collections | — | **Not added** — deferred to Phase 2 | Real feature (creation flow + browse UI + empty states), not "free," and not required to validate the core loop. |
| Comments | — | **Not added**, not even reserved in schema | Not an MVP feature; reserving an empty collection gains nothing now. |

---

## 3. Target Audience

- Puzzle enthusiasts
- Casual mobile gamers
- Pixel-art hobbyists

---

## 4. MVP Feature Set

### Authentication
- Google Sign-In
- Guest Login (can play/browse, cannot publish/like/report)

### Home Screen
- Continue Playing
- New Levels
- Community Picks

### Bottom Navigation
```
🏠 Home    🔍 Explore    ➕ Create    👤 Profile
```

---

## 5. Puzzle Creation

### A. Image Puzzle

1. Upload JPG/PNG.
2. Resize to 15×15, convert to grayscale.
3. **Live threshold slider** with real-time grid preview — creator adjusts until the shape reads correctly, then locks it in.
4. Editor: manual cell fill/erase/undo/redo.
5. Row/column clues generate live.
6. Difficulty auto-calculated (Section 7).
7. Runs through Solvability Check (Section 8) before publish.
8. **Draft saving**: creator can exit at any point and resume later — draft state (image ref, threshold value, grid edits) persisted locally via Hive.

### B. Text Puzzle (Multi-Round, Corrected)

**Capacity constraint (the actual limiting factor):** a 10×10 grid, using the pixel bitmap font, fits a fixed number of characters legibly per round — **3 characters per round** for MVP (matches the font's bitmap width + inter-letter spacing at 10 columns).

**Logic:**
```
charsPerRound = 3        // fixed by font bitmap width, not arbitrary
maxRounds = 4
maxLength = charsPerRound * maxRounds   // = 12 characters

if length <= 5:
    → single 10×10 puzzle (word rendered as one bitmap block)
elif length <= maxLength (12):
    rounds = ceil(length / charsPerRound)   // capped at 4 by maxLength
    split string into `rounds` chunks of up to charsPerRound chars,
    last chunk gets the remainder (may be shorter)
else:
    reject — show "Please shorten your text to 12 characters or fewer"
```

Example — `HELLOWORLD` (10 chars):
```
rounds = ceil(10 / 3) = 4
Round 1: HEL   Round 2: LOW   Round 3: OR   Round 4: LD
```

Player must finish one round to unlock the next. Each round is a standalone 10×10 puzzle with its own clues and solvability check.

Supported font: Pixel (single font for MVP).

---

## 6. Puzzle Editor

- Paint / Erase / Undo / Redo / Zoom / Reset
- Live row & column clue updates
- Preview before publish
- Auto-save to draft every N seconds or on background/exit

---

## 7. Difficulty Auto-Detection

No manual creator input. Computed from:

- **Filled percentage** — very low or very high fill % tends toward Easy; balanced fill tends toward Medium/Hard.
- **Clue count** — total number of clue groups across rows + columns.
- **Clue fragmentation** — average number of separate runs per line (e.g., `2 4 1` is more fragmented than `7`).

```
score = weighted_sum(fill_variance, clue_count, avg_fragmentation)

score → Easy    (low)
score → Medium
score → Hard
score → Expert  (high)
```

Exact thresholds tuned after testing against a sample set of ~30 generated puzzles (image + text) during Phase 3 of the build — see instructions.md.

---

## 8. Puzzle Validation (Before Publish)

1. Correct dimensions (15×15 or 10×10)
2. At least one filled cell, not completely filled
3. Valid clue generation
4. **Solvability**: line-solver (row/column constraint propagation — the same deduction logic a human uses from clues alone, no guessing). If the solver cannot fully resolve the grid, flag as ambiguous, return to editor, and highlight the unresolved rows/columns.

If any check fails: return to editor, block publish.

---

## 9. Gameplay

- Fill mode / Cross mode
- Undo
- Hint (3 per level)
- Timer, Pause, Restart
- 3-star rating based on time, mistakes, hint usage

---

## 10. Community

- Like, Share, Report

**Report handling:**
- Each report is its own document in a `reports` collection (reporter, levelId, reason, timestamp) — not a simple counter, so there's an actual audit trail.
- A level auto-hides from Explore/Home once it accumulates 3 open reports.
- Manual review queue for MVP (Firestore console or a minimal admin screen) — no need to over-build moderation tooling before there's real content volume.

Creator page: Avatar, Username, Published levels, Total Plays, Total Likes.

---

## 11. Explore

Filters: New, Most Played, Easy, Medium, Hard, Expert
Search: Creator, Title, Tags

---

## 12. Profile

- Avatar, Username
- Levels Created, Levels Solved

---

## 13. Phase 2 (Deferred, Not Cut)

- Leaderboards, Daily Challenge, XP/coin economy, Achievements
- Follow system
- **Collections** (Pokémon / Animals / Alphabet-style groupings) — real feature, needs its own creation + browse flow, deferred until there's enough published content to organize
- **Comments** — not reserved in schema yet; add when actually building it
- Custom puzzle sizes (20×20+)
- Multiplayer race mode, collaborative creation, friend challenges
- Web version, iOS support
- Creator analytics (views, completion rate, avg solve time)
- Cloud sync for drafts (MVP drafts are local-only via Hive)
- Puzzle version history
- AI-assisted image simplification (smarter-than-threshold segmentation)

---

## 14. Tech Stack

**Frontend:** Flutter, Dart, Riverpod, Go Router
**Backend:** Firebase Auth, Cloud Firestore, Firebase Storage, Firebase Crashlytics
**Image Processing:** Flutter `image` package — resize, grayscale, adjustable binary threshold, pixel extraction. No external AI service.
**Local Storage:** Hive — offline progress, cached puzzles, drafts, preferences.

---

## 15. Architecture — Feature-First Modules

```
lib/
  core/
  config/
  shared/
    widgets/
    services/
    utils/
  features/
    authentication/
      presentation/ domain/ data/
    home/
      presentation/ domain/ data/
    explore/
      presentation/ domain/ data/
    create/
      presentation/ domain/ data/ widgets/
    play/
      presentation/ domain/ data/ widgets/
    profile/
      presentation/ domain/ data/
    community/
      presentation/ domain/ data/
  main.dart
```

Each feature owns its own domain (entities, use cases) and data layer (repositories, services) rather than sharing one global domain/data layer — scales better as features grow, no added MVP cost.

---

## 16. Firestore Structure

```
users/
    {uid}: username, email, photoUrl, createdLevels, solvedLevels, createdAt

levels/
    {levelId}: creatorId, title, type, gridSize, difficulty,
               likes, plays, tags, createdAt

puzzles/
    {levelId}: grid, rowClues, columnClues, solution

attempts/
    {uid_levelId}: completionTime, mistakes, stars, completed

reports/
    {reportId}: reporterId, levelId, reason, timestamp, status
```

*(`comments` intentionally not reserved — see Section 13.)*

---

## 17. UI Theme

**Colors:**
- Primary `#2563EB`
- Background `#F5F7FA` (light) / `#0F172A` (dark)
- Filled Cell `#1E293B`
- Empty Cell `#FFFFFF`
- Hint `#F59E0B`
- Success `#10B981`
- Error `#EF4444`

**Typography:** Poppins (headings/buttons/body), Roboto Mono (numbers)

**Animations:**
- Cell fill (~80ms)
- Light haptic on fill/cross
- **Green flash on row/column completion** (new)
- Confetti only on full puzzle completion
- Skeleton loading, smooth page transitions

---

## 18. Non-Functional Requirements

- App launch time < 2 seconds
- Puzzle generation (incl. solver check) < 1 second for 15×15 on mid-range devices
- 60 FPS gameplay
- Offline support for downloaded puzzles
- Responsive UI across Android 6"–7" devices

---

## 19. User Flow

```
                 Launch App
                      │
              Login / Guest
                      │
                Home Dashboard
      ┌───────────────┼───────────────┐
      │               │               │
  Play Levels      Explore       Create Puzzle
      │                                │
      │                  ┌─────────────┴─────────────┐
      │                  │                            │
      │            Upload Image                Enter Text (≤12 chars)
      │                  │                            │
      │       Threshold Slider + Preview      Split into rounds (if >5)
      │                  │                            │
      │            Edit Puzzle                  Preview Rounds
      │                  │                            │
      │       Difficulty Auto-Calculated              │
      │                  │                            │
      │            Solvability Check ───(fail)───► back to Editor
      │                  │
      └──────────► Publish ◄──────────┘
                         │
                  Community Feed
                         │
              Like • Share • Report • Solve
```

---

## 20. MVP Success Metrics

- **Core loop completion:** % of creators who reach "publish" after starting (target >50%)
- **Generation quality:** % of image puzzles passing solvability check without editor rework
- **Text mode engagement:** % of created puzzles that are text vs. image (tells you if the differentiator is actually used)
- **Engagement:** Avg puzzles solved per session
- **Stability:** Crash-free sessions above 99%