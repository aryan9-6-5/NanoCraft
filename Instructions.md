# NanoCraft — Build Instructions for Antigravity

**Reference document:** `NanoCraft_PRD_v3_FINAL.md` (same folder). Read it fully before starting Phase 0 — this file tells you *what to do and in what order*, the PRD tells you *why* and the exact specs.

**Ground rules for this build:**
1. Do not implement anything listed under PRD Section 13 (Phase 2 / Deferred). If a task seems to require a deferred feature (leaderboards, coins, collections, comments, follow), stop and flag it rather than building a stub for it.
2. Work phase by phase, in order. Do not start Phase N+1 until Phase N's acceptance criteria are met.
3. After each phase, produce a short summary of what was built, what deviated from spec (and why), and what's left before the next phase can start.
4. Prefer boring, working code over clever code. This is an MVP — correctness and shippability beat elegance.

---

## Phase 0 — Project Setup

**Tasks:**
- Initialize Flutter project targeting Android only for MVP (no iOS config needed yet).
- Add dependencies: `flutter_riverpod`, `go_router`, `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_crashlytics`, `hive`, `hive_flutter`, `image` (image processing), `image_picker`, `google_sign_in`.
- Set up Firebase project (Auth: Google provider + Anonymous for guest; Firestore; Storage; Crashlytics).
- Create the feature-first folder structure exactly as in PRD Section 15:
  ```
  lib/core, lib/config, lib/shared/{widgets,services,utils},
  lib/features/{authentication,home,explore,create,play,profile,community}
  ```
  Each feature folder gets `presentation/`, `domain/`, `data/` subfolders (and `widgets/` for `create` and `play`).
- Set up `go_router` with placeholder routes for: `/login`, `/home`, `/explore`, `/create`, `/play/:levelId`, `/profile`.
- Initialize Hive with adapters registered (empty for now, models come in Phase 4).

**Acceptance criteria:** App builds and runs on an emulator, shows a placeholder home screen, Firebase is connected (verify with a test read/write to Firestore), no dependency conflicts.

---

## Phase 1 — Authentication & Navigation Shell

**Tasks:**
- Implement Google Sign-In and Guest (anonymous) login per PRD Section 4.
- Create `User` domain entity: `userId, username, email, photoUrl, createdLevels, solvedLevels, createdAt` (matches PRD Section 16 — no xp/coins/followers fields, those don't exist in this MVP).
- On first login, create the corresponding `users/{uid}` Firestore document.
- Implement guest-mode restrictions at the UI level: hide/disable Create, Like, and Report actions for guest users (per PRD Section 4). Don't just hide the button — also guard the underlying action, since a guest could otherwise hit the route directly.
- Build bottom navigation shell exactly as PRD Section 4: Home, Explore, Create, Profile (four tabs — no Leaderboard tab).

**Acceptance criteria:** A new user can sign in with Google or continue as guest, lands on Home, guest cannot access Create/Like/Report, user document is created correctly in Firestore, session persists across app restarts.

---

## Phase 2 — Data Models & the Solvability Algorithm

This is the highest-risk phase. Do not skip ahead until this is solid — everything in Create and Play depends on it.

**Tasks:**

1. Define core domain entities matching PRD Section 16 exactly:
   - `Level` (levelId, creatorId, title, type, gridSize, difficulty, likes, plays, tags, createdAt)
   - `Puzzle` (levelId, grid, rowClues, columnClues, solution)
   - `Attempt` (uid_levelId key, completionTime, mistakes, stars, completed)
   - `Report` (reportId, reporterId, levelId, reason, timestamp, status)

2. **Clue generation function**: given a boolean grid (filled/empty), produce row clues and column clues as lists of run-lengths. This is straightforward — implement and unit test against hand-computed examples (at least 5 grids of varying size/pattern).

3. **Line-solver (solvability check)** — this is the core technical risk called out in the PRD (Section 8). Implement as follows:
   - For each row and column, given its clue (list of run-lengths) and current known state (filled/empty/unknown), compute all possible placements of the runs that satisfy the clue and the currently-known cells.
   - Intersect all valid placements — any cell that is filled in *every* valid placement can be marked filled; any cell empty in *every* valid placement can be marked empty.
   - Repeat across all rows and columns (constraint propagation) until no more cells can be resolved.
   - If every cell in the grid ends up resolved (fully determined), the puzzle is solvable by pure logic → **pass**.
   - If cells remain ambiguous after propagation stalls, the puzzle has multiple valid solutions → **fail**, and return the list of unresolved row/column indices so the editor can highlight them (per PRD Section 8).
   - This does not need to implement full backtracking/guessing — pure constraint propagation is sufficient for MVP and matches what the PRD specifies ("no guessing").
   - Unit test this against: (a) a hand-built puzzle known to be uniquely solvable, (b) a hand-built puzzle known to be ambiguous, (c) an edge case like an all-empty or all-filled grid (should correctly fail per PRD Section 8 validation rule #2, which is a separate check but make sure the solver doesn't crash on it).

4. **Difficulty scoring function** per PRD Section 7 — compute fill variance, clue count, and average fragmentation from a resolved grid, and map to Easy/Medium/Hard/Expert. Don't hardcode final thresholds yet — make the weights/cutoffs easily tunable constants, since PRD Section 7 explicitly says these get tuned against real sample puzzles later in this phase.

5. Generate ~30 sample grids (mix of image-like patterns and text-bitmap patterns) and run difficulty scoring against them. Manually sanity-check the resulting labels feel right (an almost-empty simple grid shouldn't score Expert). Adjust thresholds until they do.

**Acceptance criteria:** Clue generation, line-solver, and difficulty scoring all have passing unit tests. The line-solver correctly distinguishes at least one known-unique and one known-ambiguous test grid. Difficulty thresholds have been sanity-checked against sample data, not left at arbitrary defaults.

---

## Phase 3 — Image Puzzle Creation Flow

**Tasks:**
- Image picker → load JPG/PNG.
- Resize to 15×15, convert to grayscale using the `image` package.
- Build the **threshold slider UI** (PRD Section 5A, step 3): as the user drags, re-run binary thresholding at the new value and re-render the 15×15 grid preview live. This must feel instant — no visible lag when dragging.
- On "lock in," hand the grid off to the shared puzzle editor (paint/erase/undo/redo/zoom/reset — PRD Section 6).
- Wire up live clue generation (from Phase 2) as the user edits.
- Wire up difficulty auto-calculation (from Phase 2) — recompute on every edit or on a debounce, creator's choice, but it must reflect the current grid state before publish.
- Wire up the solvability check (from Phase 2) as a gate before the Publish button is enabled. On failure, highlight the unresolved rows/columns per PRD Section 8.
- Implement draft auto-save: persist image reference, current threshold value, and current grid edit state to Hive on background/exit and periodically during editing. Implement resume-from-draft on the Create screen.

**Acceptance criteria:** A user can upload any JPG/PNG, adjust the threshold slider and see the grid update live, edit the grid manually, see live clues and difficulty, get blocked from publishing an ambiguous puzzle with useful feedback, and successfully publish a valid one. Closing the app mid-edit and reopening resumes the draft correctly.

---

## Phase 4 — Text Puzzle Creation Flow

**Tasks:**
- Text input UI, max 12 characters enforced at input time (reject longer input with the message specified in PRD Section 5B), single-word only (no spaces — clarify with product owner if multi-word should be rejected or just treated as one string; default to rejecting spaces for MVP simplicity unless told otherwise).
- Implement the bitmap font renderer for the Pixel font at the fixed 3-characters-per-10-columns capacity (PRD Section 5B).
- Implement the round-splitting logic exactly as PRD Section 5B specifies:
  - `charsPerRound = 3`, `maxRounds = 4`, `maxLength = 12`
  - length ≤ 5 → single 10×10 puzzle
  - 6 ≤ length ≤ 12 → split into `ceil(length/3)` rounds of up to 3 characters each (last round may be shorter)
  - length > 12 → reject
- Each round becomes its own `Puzzle` document with its own clues, difficulty, and solvability check (Phase 2 functions) — reuse the same editor/validation pipeline as image puzzles rather than building a parallel one.
- Implement round-locking on the play side is Phase 5's job, but confirm here that the `Level` document for a multi-round text puzzle stores enough info (e.g. an ordered list of round `levelId`/`puzzleId`s or a `roundIndex` field) for Phase 5 to enforce "finish round N to unlock round N+1."

**Acceptance criteria:** Entering "CAT" produces one 10×10 puzzle. Entering "HELLOWORLD" (10 chars) produces exactly 4 rounds of 3/3/3/1 characters (verify against PRD's HELLOWORLD example — note PRD example shows HEL/LOW/OR/LD as one valid 3-2-2-3-ish split; either even 3-char chunking or that exact split is acceptable as long as it's ≤3 chars/round and ≤4 rounds — pick one deterministic rule and stick to it). Entering 13+ characters is rejected with the specified message. Each round independently passes clue generation, difficulty scoring, and the solvability check before publish.

---

## Phase 5 — Play Flow

**Tasks:**
- Puzzle screen: render grid, fill mode / cross mode toggle, undo, hint (max 3/level), timer, pause, restart (PRD Section 9).
- On row/column completion, trigger the green flash micro-interaction (PRD Section 17).
- On full completion: confetti, compute 3-star rating from time/mistakes/hints used, write an `Attempt` document.
- For multi-round text puzzles: enforce sequential unlock — round N+1 is inaccessible until round N's `Attempt.completed == true` (uses the round-linking data structured in Phase 4).
- Offline support: downloaded/cached puzzles playable without network (Hive-cached), per PRD Section 18 non-functional requirement.

**Acceptance criteria:** A published puzzle can be played start to finish with correct star rating computed, multi-round text puzzles gate progression correctly, and a cached puzzle is playable in airplane mode.

---

## Phase 6 — Explore, Community, Profile

**Tasks:**
- Home: Continue Playing, New Levels, Community Picks sections (PRD Section 4) — pull from Firestore, no trending/recommendation logic needed for MVP.
- Explore: filters (New, Most Played, Easy/Medium/Hard/Expert) and search by Creator/Title/Tags (PRD Section 11).
- Community actions: Like, Share, Report (PRD Section 10).
  - Like: increment/decrement on the `Level` doc, guarded against guest users and duplicate likes from the same user.
  - Report: write to the `reports` collection (not a counter — PRD Section 16), auto-hide the level from Explore/Home once 3 open reports accumulate.
  - Build the minimal manual review surface (a basic screen or documented Firestore console query is acceptable for MVP — do not build a full admin panel).
- Profile: avatar, username, levels created, levels solved (PRD Section 12 — no xp/coins/badges fields).
- Creator page: avatar, username, published levels, total plays, total likes (PRD Section 10).

**Acceptance criteria:** Explore filters and search return correct results, liking/reporting work and are guest-restricted, a level auto-hides after 3 reports, profile and creator pages show accurate counts pulled from real data.

---

## Phase 7 — Polish & Non-Functional Requirements

**Tasks:**
- Verify against PRD Section 18: app launch <2s, puzzle generation (incl. solver) <1s on a mid-range test device, 60fps during gameplay, offline playback works, UI is responsive on both 6" and 7" screen sizes.
- Confirm all animations/haptics from PRD Section 17 are implemented: cell fill, haptic on fill/cross, green flash on line completion, confetti on full completion, skeleton loading, smooth transitions.
- Crashlytics wired up and verified to actually report a test crash.
- Full run-through of both create flows (image and text) and both play flows (single and multi-round) end to end, on a physical device if possible, not just emulator.

**Acceptance criteria:** All non-functional requirements measured and met (not assumed). A tester unfamiliar with the build can go from cold app launch through creating a puzzle, publishing it, and someone else solving it, with no crashes and no confusing dead ends.

---

## Explicit Non-Goals (Do Not Build)

Per PRD Section 13 — if any of these come up as "obvious next steps" during the build, do not implement them without new instructions:

- Leaderboards, Daily Challenge, XP/coins, Achievements
- Follow system
- Collections
- Comments (not even a reserved empty Firestore collection)
- Custom grid sizes beyond 10×10/15×15
- Multiplayer, collaborative creation, friend challenges
- Web version, iOS support
- Creator analytics, cloud draft sync, puzzle version history
- AI-assisted image simplification beyond the threshold-slider approach specified in Phase 3

---

## Reporting Back

After each phase, report:
1. What was built, mapped to that phase's acceptance criteria (explicitly confirm each criterion, don't just say "done").
2. Any spec ambiguity encountered and how it was resolved (e.g., the HELLOWORLD split-rule choice in Phase 4).
3. Anything discovered that should change the PRD (e.g., if the line-solver in Phase 2 turns out too slow for the <1s requirement, or the 3-chars-per-round font constraint doesn't actually fit at 10 columns with the chosen font).