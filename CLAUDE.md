# WorkPulse — Agent Working Rules

WorkPulse is a macOS time‑tracking app (SwiftUI + SwiftData). Tracks multiple "clocks", each owning a list of `TimeSegment`s. UI surfaces: main window (sidebar + detail) and a `MenuBarExtra`.

## How to work in this project

- This runs inside Xcode. Prefer the `xcode-tools` MCP server (`XcodeRead`, `XcodeGrep`, `XcodeGlob`, `XcodeRefreshCodeIssuesInFile`, `BuildProject`) over shell tools.
- For new/renamed/deleted files use `XcodeWrite`, `XcodeMV`, `XcodeRM` so the Xcode project stays in sync. Don't edit `project.pbxproj` by hand.
- Validate work with `XcodeRefreshCodeIssuesInFile` (fast diagnostics) before reaching for `BuildProject` (slow).
- Apple APIs evolve fast. If an API looks unfamiliar (Liquid Glass, FoundationModels, new SwiftUI), use `DocumentationSearch` rather than guessing.
- Limit changes to what was requested. No unrelated cleanups, no speculative refactors, no new abstractions.

## Architecture map

- `WorkPulseApp.swift` — `@main`, sets up `ModelContainer` (Clock, TimeSegment, ColorComponents), instantiates `GlobalEnvironment`, defines the `WindowGroup` and `MenuBarExtra`.
- `Models/`
  - `Clock` (`@Model`) — name, notes, `ColorComponents` relationship, cascading `timeSegments` relationship, derived `color` computed property.
  - `TimeSegment` (`@Model`) — `startTime`, optional `endTime`, `isRunning`, `note`, back‑relationship to `Clock`. `elapsedTime(refTime:)` is the time math primitive.
  - `ColorComponents` (`@Model`) — sRGB storage so `Color` survives persistence. Convert via `Color.components` in `Extensions/Color+Components.swift`.
  - `CalendarEvent` — non‑persistent struct; built from a `TimeSegment` + `Clock` for calendar views.
- `ViewModels/`
  - `GlobalEnvironment` — `@Observable @MainActor`. The single source of truth. Owns `clocks`, `activeClock`, `activeTimeSegment`, the 1‑second UI `Timer`, and a derived `elapsedTime`. Injected via `.environment(...)` and read with `@Environment(GlobalEnvironment.self)`.
  - `PersistenceManager` — `@MainActor`. Owns a 30s autosave `Timer` that runs while a segment is active; calls `modelContext.save()`. Keeps the running segment's `endTime` continuously fresh so a crash loses ≤ a tick.
  - `CalendarViewModel` — `@Observable`. Drives day/week navigation; filters events.
- `Views/`
  - `ContentView` — `NavigationSplitView` with sidebar (`SidebarSelection` enum: `.dashboard | .clock(UUID) | .settings`).
  - `MenuBarView` — compact controls in the menu bar.
  - `Dashboard/` — `DashboardView`, `ClockDetailScreen`, `Components/`, `Calendar/`, `Charts/`.
  - `Sheets/` — `AddNewClockView` (also used for editing), `RunningSegmentView`, `TimeSegmentNoteView`.
- `Styles/Theme.swift` — `Theme.Colors`, `Theme.CornerRadius`, view modifiers `cardBackground()` / `secondaryCardBackground()` / `overlayStyle()`. **Use these instead of inlining colors/radii.**
- `Extensions/` — `TimeInterval.formattedHHMMSS()`, `Date` formatters (`formattedForTimeSegment`, `hourMinuteString`, etc.). Reuse these rather than building new formatters.

## Patterns to follow

- **State**: `@Observable` classes, not `ObservableObject`. Inject with `.environment(model)`, read with `@Environment(Type.self)`. No `@StateObject`/`@EnvironmentObject`. No Combine — use `async/await`.
- **Concurrency**: anything touching the model or active timer is `@MainActor`. Timer callbacks dispatch back to the main actor via `Task { @MainActor in ... }`.
- **Time math**: always go through `TimeSegment.elapsedTime(refTime:)` / `effectiveEndTime(refTime:)`. Don't recompute durations inline.
- **Persistence**: mutate models through `GlobalEnvironment` methods (`addClock`, `deleteClock`, `updateClock`, `startTimer`, `stopTimer`, `deleteTimeSegment`, `resetClock`). They handle `modelContext` and call `persistenceManager.persistData()` where appropriate.
- **Colors**: store via `ColorComponents`; build SwiftUI `Color` through the `clock.color` accessor.
- **Formatting**: durations → `formattedHHMMSS()`; dates → the `Date` extension formatters.
- **Reading `elapsedTime` to drive UI refresh**: views that need per‑second updates touch `viewModel.elapsedTime` (sometimes as `_ = viewModel.elapsedTime`) to subscribe. Keep this pattern when adding similar views.

## Code style

- 2‑space indentation (this project uses 2 spaces, not 4 — match what's there).
- PascalCase types, camelCase members. `let` by default, `var` when needed. `@State private var` for view state.
- Prefer SwiftUI declarative composition; break large views into computed properties (`private var totalTime: some View { ... }`) or small `View` structs.
- No force unwraps. Use `guard let` / optional chaining.
- Default to no comments. Only comment non‑obvious *why*.

## Testing

- Swift Testing framework (`import Testing`, `@Test`, `#expect`) in `WorkPulseTests/`. Not XCTest.
- UI tests use XCUIAutomation in `WorkPulseUITests/`.
- Run via `RunAllTests` / `RunSomeTests` MCP tools.

## Things to be careful about

- `Item.swift` is the Xcode template leftover and is still in the schema indirectly via `ContentView`'s `@Query private var items: [Item]`. Don't add new functionality on top of `Item` — use `Clock`/`TimeSegment`.
- Don't create a second `ModelContainer`; the shared one lives in `WorkPulseApp`.
- Don't start a timer by mutating `TimeSegment.isRunning` directly — go through `GlobalEnvironment.startTimer` so the autosave timer, active references, and `activeClock` stay consistent.
- `minimumTimeSegmentDuration` (UserDefaults, default 30s) means short segments are deleted on stop — keep that behavior in mind when writing tests.
