# MoodMirror++ Feature Documentation

> **Status:** ✅ Complete
> **Version:** 1.0.0
> **Last Updated:** 2026-04-11
> **Entry Point:** `lib/ui/mood_mirror/views/mood_mirror_page.dart`

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Data Models](#data-models)
4. [Interpretation Engine](#interpretation-engine)
5. [BLoC Implementation](#bloc-implementation)
6. [UI Components](#ui-components)
7. [Feature Specifications](#feature-specifications)
8. [File Structure](#file-structure)
9. [Testing & Debugging](#testing--debugging)
10. [Future Enhancements](#future-enhancements)

---

## Overview

**MoodMirror++** is a lightweight reflection app where users log small moments during the day. Each entry is automatically analyzed and transformed into:
- A derived weather state (Clear, Cloudy, Windy, Stormy, Foggy)
- A derived intensity level (Low, Medium, High)
- A derived reflection flag (Stable, Mixed, Overloaded, Recovering, Unclear)

The app generates live day summaries with natural language insights based on all entries.

### Key Features
- ✅ Entry creation with mood, context, energy, and note
- ✅ Automatic text analysis with 179+ keywords
- ✅ Weather derivation with contradiction detection
- ✅ Intensity calculation with weighted scoring
- ✅ Reflection analysis for signal alignment
- ✅ Day summary with natural language sentences
- ✅ Filtering (All, High Intensity, Contradictory, By Context)
- ✅ In-memory state management (no persistence)

---

## Architecture

### Pattern: BLoC (Business Logic Component)

```
UI Layer
└── MoodMirrorPage (BlocProvider)
    └── MoodMirrorView (BlocBuilder)
        ├── DaySummaryCard
        ├── EntryForm
        ├── FilterBar
        └── EntryCard (list)

BLoC Layer
└── MoodMirrorBloc
    ├── Events (AddEntry, DeleteEntry, ApplyFilter, ClearFilter)
    ├── States (MoodMirrorState)
    └── Event Handlers

Business Logic Layer (Utils)
├── TextAnalyzer
├── WeatherDerivationEngine
├── IntensityCalculator
├── ReflectionAnalyzer
└── SummaryGenerator

Data Layer
├── Models (MoodEntry, TextAnalysisResult, DaySummary, FilterOptions)
└── Enums (MoodType, ContextType, WeatherState, IntensityLevel, ReflectionFlag, FilterType)
```

### State Management

**Storage Strategy:** In-memory only
- All entries stored in `MoodMirrorState.entries` (List<MoodEntry>)
- Data resets on app restart
- No database, SharedPreferences, or file I/O
- Filtered view maintained separately in `MoodMirrorState.filteredEntries`

---

## Data Models

### Core Enums

#### MoodType
```dart
enum MoodType {
  calm,
  tense,
  happy,
  drained,
  focused
}
```

#### ContextType
```dart
enum ContextType {
  work,
  family,
  health,
  social,
  alone
}
```

#### WeatherState
```dart
enum WeatherState {
  clear,    // ☀️
  cloudy,   // ☁️
  windy,    // 💨
  stormy,   // ⛈️
  foggy     // 🌫️
}
```

#### IntensityLevel
```dart
enum IntensityLevel {
  low,
  medium,
  high
}
```

#### ReflectionFlag
```dart
enum ReflectionFlag {
  stable,
  mixed,
  overloaded,
  recovering,
  unclear
}
```

#### FilterType
```dart
enum FilterType {
  all,
  highIntensity,
  contradictory,
  byContext
}
```

### Data Classes

#### MoodEntry
```dart
class MoodEntry {
  final String id;              // UUID
  final DateTime timestamp;
  final String note;
  final int energyLevel;        // 1-5
  final MoodType mood;
  final ContextType context;
  final WeatherState derivedWeather;
  final IntensityLevel derivedIntensity;
  final ReflectionFlag derivedReflection;
  final TextAnalysisResult textAnalysis;
}
```

#### TextAnalysisResult
```dart
class TextAnalysisResult {
  final int positiveKeywordCount;
  final int negativeKeywordCount;
  final int stressKeywordCount;
  final int recoveryKeywordCount;
  final double punctuationDensity;   // 0-1
  final int repeatedWordCount;
  final int noteLength;
  final double sentimentScore;       // -1 to 1
}
```

#### DaySummary
```dart
class DaySummary {
  final DateTime date;
  final int totalEntries;
  final WeatherState? mostFrequentWeather;
  final double averageEnergy;
  final ContextType? mostCommonContext;
  final int highIntensityCount;
  final int contradictoryCount;
  final String derivedSentence;
  final Map<WeatherState, int> weatherDistribution;
}
```

#### FilterOptions
```dart
class FilterOptions {
  final FilterType filterType;
  final ContextType? selectedContext;
}
```

---

## Interpretation Engine

### 1. TextAnalyzer

**File:** `lib/ui/mood_mirror/utils/text_analyzer.dart`

#### Keyword Dictionaries (179 total)

**Positive Keywords (57):**
```
good, great, happy, excited, amazing, wonderful, productive,
accomplished, progress, success, win, love, enjoy, fun, yay,
nice, awesome, fantastic, excellent, brilliant, perfect,
beautiful, lovely, joy, blessed, grateful, thankful, appreciative,
satisfied, content, peaceful, relaxed, calm, energized, motivated,
inspired, confident, proud, optimistic, hopeful, positive, better,
improved, achieved, completed, done, finished, victory, succeed,
thrilled, delighted, pleased, comfortable, easy, smooth, clear, bright
```

**Negative Keywords (55):**
```
bad, terrible, awful, hate, angry, sad, failed, mistake, wrong,
regret, disappointed, frustrated, annoyed, upset, difficult, hard,
horrible, worst, miserable, unhappy, depressed, lonely, hurt, pain,
suffering, struggle, problem, issue, trouble, worry, concern, fear,
scared, afraid, nervous, uncomfortable, weak, tired, exhausted,
drained, empty, lost, confused, stuck, hopeless, helpless, failure,
loss, defeat, setback, disaster, mess, chaos, broken, damaged, ruined
```

**Stress Keywords (44):**
```
overwhelmed, anxious, stress, stressed, pressure, worried, panic,
deadline, rush, urgent, crisis, exhausted, burnout, can't, cannot,
impossible, too much, overloaded, swamped, buried, drowning,
suffocating, tense, tight, strained, demanding, hectic, chaotic,
frantic, racing, burden, weight, heavy, intense, critical, emergency,
hurry, late, behind, struggling, barely, hanging, breaking, cracking
```

**Recovery Keywords (23):**
```
better, improving, recovery, healing, rest, rested, recharged,
refreshed, renewed, restored, bouncing back, getting better,
on the mend, recovering, progress, improvement, upward, rising,
climbing, comeback, resilient, stronger, rebuilding
```

#### Analysis Functions

1. **Keyword Counting**
   - Uses whole-word regex matching (`\bkeyword\b`)
   - Case-insensitive matching
   - Returns count per category

2. **Punctuation Density**
   - Formula: `(exclamation_marks + question_marks + ellipsis*3) / text_length`
   - Clamped to 0-1 range
   - Higher density = more emotional intensity

3. **Repeated Words**
   - Only counts words >3 characters
   - Returns count of words appearing more than once

4. **Sentiment Score**
   - Formula: `(positive*1.0 + recovery*0.5 - negative*1.0 - stress*0.7) / total_keywords`
   - Range: -1 (very negative) to 1 (very positive)
   - Returns 0 if no keywords found

---

### 2. WeatherDerivationEngine

**File:** `lib/ui/mood_mirror/utils/weather_derivation_engine.dart`

#### Derivation Logic (Priority Order)

**1. Check Contradictions First → Windy**
```
Mood-Energy contradictions:
- Happy/Focused + energy ≤2
- Drained/Tense + energy ≥4
- Calm + energy extremes (1 or 5)

Mood-Text contradictions:
- Positive mood + negative sentiment (<-0.3)
- Negative mood + positive sentiment (>0.3)
- Calm + high punctuation (>0.15)
```

**2. Stormy Conditions**
```
- Tense mood + stress keywords
- Stress count ≥2 + punctuation >0.1
- Strongly negative sentiment (<-0.5) + low energy (≤2)
```

**3. Foggy Conditions**
```
- Drained + low energy (≤2) + negative sentiment
- Energy = 1 + negative keywords
- Neutral sentiment + moderate energy + drained mood
```

**4. Clear Conditions**
```
- Happy + high energy (≥4) + positive sentiment (>0.2)
- Calm + positive sentiment + no stress keywords
- Focused + high energy (≥4) + no negative keywords
```

**5. Cloudy (Default)**
```
- Focused + moderate energy (2-4)
- Calm + moderate energy (≥2)
- Neutral sentiment (±0.3)
```

---

### 3. IntensityCalculator

**File:** `lib/ui/mood_mirror/utils/intensity_calculator.dart`

#### Weighted Scoring System

```
Total Score =
  (energy / 5) * 0.4 +                    // 40% weight
  (punctuation_density) * 0.3 +           // 30% weight
  (|sentiment_score|) * 0.2 +             // 20% weight
  (mood_intensity) * 0.1                  // 10% weight

Mood Intensity Mapping:
- Tense:   1.0
- Happy:   0.8
- Focused: 0.7
- Drained: 0.6
- Calm:    0.3
```

#### Level Mapping
```
Score < 0.4  → Low
Score < 0.7  → Medium
Score ≥ 0.7  → High
```

---

### 4. ReflectionAnalyzer

**File:** `lib/ui/mood_mirror/utils/reflection_analyzer.dart`

#### Contradiction Scoring Matrix

**Mood-Energy Contradictions:**
```
Happy/Focused + energy ≤2         → +0.7
Drained/Tense + energy ≥4         → +0.7
Calm + energy extremes (1 or 5)   → +0.5
```

**Mood-Text Contradictions:**
```
Positive mood + negative sentiment (<-0.3)  → +0.8
Negative mood + positive sentiment (>0.3)   → +0.7
Calm + high punctuation (>0.15)             → +0.6
Happy + stress keywords                      → +0.7
```

**Energy-Text Contradictions:**
```
High energy (≥4) + negative sentiment (<-0.2)  → +0.5
Low energy (≤2) + high punctuation (>0.1)      → +0.6
```

#### Flag Assignment Logic

**Recovering:**
```
- Contradiction score >0.5 + low energy (≤2) + positive sentiment (>0.2)
- Recovery keywords present + low/moderate energy (≤3)
- Drained mood + positive text (>0.3)
```

**Overloaded:**
```
- Stress keywords ≥2 + contradiction score >1.0
- Focused + energy=1 + negative sentiment
- Drained + low energy (≤2) + high punctuation (>0.12)
```

**Unclear:**
```
- Very neutral sentiment (<0.15) + low punctuation (<0.05) + short note (<20 chars)
- No keywords + contradiction score <0.3
```

**Contradiction Score Mapping:**
```
Score < 0.5   → Stable
Score < 1.5   → Mixed
Score ≥ 1.5   → Overloaded (unless recovering pattern)
```

---

### 5. SummaryGenerator

**File:** `lib/ui/mood_mirror/utils/summary_generator.dart`

#### Statistics Calculated

1. **Weather Distribution** - Count per weather state
2. **Most Frequent Weather** - Mode of weather distribution
3. **Average Energy** - Mean of all energy levels
4. **Most Common Context** - Mode of context distribution
5. **High Intensity Count** - Count of entries with `IntensityLevel.high`
6. **Contradictory Count** - Count of entries with `ReflectionFlag.mixed` or `ReflectionFlag.overloaded`

#### Natural Language Sentence Generation

**Template Structure:**
```
[Weather Pattern] + [Energy Assessment] + [Context Focus] + [Contradiction Assessment] + [Recovery Signal]
```

**Weather Pattern Templates:**
```
Clear  → "Your day appears mostly positive and clear"
Cloudy → "Your day shows moderate and steady patterns"
Windy  → "Your day appears emotionally inconsistent"
Stormy → "Your day shows signs of stress and tension"
Foggy  → "Your day reflects confusion or low energy"
```

**Energy Assessment:**
```
Average < 2.5 → "with notably low energy levels"
Average > 3.5 → "with strong energy levels"
```

**Context Focus:**
```
If high_intensity_count > total/2:
  → "Most high-intensity moments are {context}-related"
Else:
  → "with focus on {context}"
```

**Contradiction Assessment:**
```
Contradictory > 60% → "Inputs show significant contradictions"
Contradictory > 30% → "with some mixed signals"
Contradictory = 0   → "Signals are mostly stable and aligned"
```

**Recovery Signal:**
```
If recovering_count > 0:
  → "but signals suggest recovery"
```

**Example Outputs:**
```
"Your day appears mostly positive and clear, with strong energy levels, with focus on work."

"Your day shows signs of stress and tension, with notably low energy levels. Signals are mostly stable and aligned."

"Your day appears emotionally inconsistent. Most high-intensity moments are work-related. Inputs show significant contradictions."
```

---

## BLoC Implementation

### Events

**File:** `lib/ui/mood_mirror/bloc/mood_mirror_event.dart`

```dart
sealed class MoodMirrorEvent extends Equatable

class AddEntry extends MoodMirrorEvent {
  final String note;
  final int energy;
  final MoodType mood;
  final ContextType context;
}

class DeleteEntry extends MoodMirrorEvent {
  final String id;
}

class ApplyFilter extends MoodMirrorEvent {
  final FilterOptions filterOptions;
}

class ClearFilter extends MoodMirrorEvent
```

### State

**File:** `lib/ui/mood_mirror/bloc/mood_mirror_state.dart`

```dart
class MoodMirrorState extends Equatable {
  final List<MoodEntry> entries;           // All entries
  final List<MoodEntry> filteredEntries;   // Currently displayed
  final DaySummary? daySummary;
  final FilterOptions currentFilter;
}
```

### Event Handlers

**File:** `lib/ui/mood_mirror/bloc/mood_mirror_bloc.dart`

#### AddEntry Flow
```
1. Analyze text with TextAnalyzer
2. Derive weather with WeatherDerivationEngine
3. Calculate intensity with IntensityCalculator
4. Analyze reflection with ReflectionAnalyzer
5. Create MoodEntry with UUID and timestamp
6. Add to entries list (newest first)
7. Generate day summary
8. Apply current filter
9. Emit updated state
```

#### DeleteEntry Flow
```
1. Remove entry from list by ID
2. Regenerate day summary
3. Reapply current filter
4. Emit updated state
```

#### ApplyFilter Flow
```
1. Filter entries based on FilterType:
   - all: Return all entries
   - highIntensity: Filter by IntensityLevel.high
   - contradictory: Filter by ReflectionFlag.mixed/overloaded
   - byContext: Filter by selected ContextType
2. Update currentFilter
3. Emit updated state
```

#### ClearFilter Flow
```
1. Set filter to FilterType.all
2. Set filteredEntries = entries
3. Emit updated state
```

---

## UI Components

### 1. MoodMirrorPage

**File:** `lib/ui/mood_mirror/views/mood_mirror_page.dart`

#### Structure
```dart
BlocProvider<MoodMirrorBloc>
└── MoodMirrorView
    └── Scaffold
        └── CustomScrollView (Slivers)
            ├── DaySummaryCard
            ├── EntryForm
            ├── FilterBar
            ├── Entries Header
            └── Entry List or Empty State
```

#### Layout Strategy
- Uses `CustomScrollView` with Slivers for performance
- `SliverToBoxAdapter` for static widgets
- `SliverList` for entry cards
- `SliverFillRemaining` for empty state

---

### 2. EntryForm

**File:** `lib/ui/mood_mirror/views/widgets/entry_form.dart`

#### Components
```
TextField (note)
  - Multi-line (maxLines: 3)
  - Border: OutlineInputBorder

Slider (energy)
  - Min: 1, Max: 5
  - Divisions: 4
  - Label shows current value

DropdownButtonFormField (mood)
  - 5 options from MoodType enum
  - OutlineInputBorder

DropdownButtonFormField (context)
  - 5 options from ContextType enum
  - OutlineInputBorder

FilledButton (submit)
  - Full width
  - Validates empty note
  - Shows SnackBar on success
  - Clears form after submission
```

#### Validation
- Note cannot be empty/whitespace
- Shows SnackBar error if validation fails

---

### 3. EntryCard

**File:** `lib/ui/mood_mirror/views/widgets/entry_card.dart`

#### Layout
```
Card
└── Padding
    ├── Row (timestamp + delete button)
    ├── Text (note)
    ├── Wrap (user input chips)
    │   ├── Mood chip
    │   ├── Context chip
    │   └── Energy chip
    ├── Divider
    ├── "Derived Analysis" header
    └── Wrap (derived chips)
        ├── Weather chip (with emoji + color)
        ├── Intensity chip (color-coded)
        └── Reflection chip (color-coded)
```

#### Color Coding

**Intensity:**
```
Low    → secondaryContainer
Medium → tertiaryContainer
High   → errorContainer
```

**Reflection:**
```
Stable     → primaryContainer
Recovering → tertiaryContainer
Mixed      → errorContainer
Overloaded → errorContainer
Unclear    → surfaceContainerHighest
```

---

### 4. DaySummaryCard

**File:** `lib/ui/mood_mirror/views/widgets/day_summary_card.dart`

#### Layout
```
Card (primaryContainer background)
└── Padding
    ├── Header (icon + "Day Summary")
    ├── Derived sentence (italic)
    ├── Divider
    └── Stats Grid (Wrap)
        ├── Total Entries
        ├── Avg Energy
        ├── Top Weather
        ├── Main Context
        ├── High Intensity count
        └── Contradictory count
```

#### Empty State
```
When no entries:
  - Icon (insights)
  - "No entries yet"
  - "Start logging your moments to see insights"
```

---

### 5. FilterBar

**File:** `lib/ui/mood_mirror/views/widgets/filter_bar.dart`

#### Components
```
Card
└── Column
    ├── Header Row ("Filter" + Clear button)
    ├── FilterChip Wrap
    │   ├── All
    │   ├── High Intensity
    │   └── Mixed/Contradictory
    └── DropdownButtonFormField (context filter)
        ├── All Contexts (null)
        └── 5 context options
```

#### Behavior
- Only one FilterChip can be selected at a time
- Context dropdown can be used independently
- Clear button appears when filter is active
- Filter persists across state updates

---

## Feature Specifications

### Entry Creation Flow

1. User fills form (note, energy, mood, context)
2. Clicks "Add Entry" button
3. Form validates note is not empty
4. BLoC receives `AddEntry` event
5. **Derivation Pipeline Executes:**
   - Text analysis
   - Weather derivation
   - Intensity calculation
   - Reflection analysis
6. Entry created with UUID and timestamp
7. Added to state (newest first)
8. Summary regenerated
9. Filter reapplied
10. UI updates
11. SnackBar confirmation
12. Form resets

### Filtering Flow

**All Entries:**
- Shows all entries in reverse chronological order

**High Intensity Only:**
- Shows only entries where `derivedIntensity == IntensityLevel.high`

**Mixed/Contradictory:**
- Shows only entries where `derivedReflection == ReflectionFlag.mixed || ReflectionFlag.overloaded`

**By Context:**
- User selects context from dropdown
- Shows only entries matching selected context
- Selecting "All Contexts" clears filter

### Delete Flow

1. User clicks delete icon on entry card
2. BLoC receives `DeleteEntry` event with entry ID
3. Entry removed from state
4. Summary regenerated
5. Filter reapplied
6. UI updates

---

## File Structure

```
lib/
├── domain/
│   └── data/
│       └── model/
│           ├── mood_type.dart                    # Enum
│           ├── context_type.dart                 # Enum
│           ├── weather_state.dart                # Enum (with emojis)
│           ├── intensity_level.dart              # Enum
│           ├── reflection_flag.dart              # Enum
│           ├── filter_type.dart                  # Enum
│           ├── text_analysis_result.dart         # Data class
│           ├── mood_entry.dart                   # Data class
│           ├── day_summary.dart                  # Data class
│           └── filter_options.dart               # Data class
│
└── ui/
    └── mood_mirror/
        ├── bloc/
        │   ├── mood_mirror_bloc.dart             # Main BLoC
        │   ├── mood_mirror_event.dart            # Events (part of)
        │   └── mood_mirror_state.dart            # State (part of)
        │
        ├── utils/
        │   ├── text_analyzer.dart                # 179 keywords
        │   ├── weather_derivation_engine.dart    # Rule-based weather
        │   ├── intensity_calculator.dart         # Weighted scoring
        │   ├── reflection_analyzer.dart          # Contradiction detection
        │   └── summary_generator.dart            # NLP sentence generation
        │
        └── views/
            ├── mood_mirror_page.dart             # Entry point
            └── widgets/
                ├── entry_form.dart               # Form widget
                ├── entry_card.dart               # Entry display
                ├── day_summary_card.dart         # Summary display
                └── filter_bar.dart               # Filter controls
```

**Total Files Created:** 20 new files
**Total Lines of Code:** ~2,500 lines

---

## Testing & Debugging

### Manual Test Scenarios

#### 1. Happy Path - Clear Weather
```
Input:
- Note: "Great day! Accomplished so much work."
- Energy: 5
- Mood: Happy
- Context: Work

Expected Output:
- Weather: Clear ☀️
- Intensity: High
- Reflection: Stable
```

#### 2. Contradiction - Windy Weather
```
Input:
- Note: "stressed!!! deadline urgent!!!"
- Energy: 3
- Mood: Calm
- Context: Work

Expected Output:
- Weather: Windy 💨 (contradiction: calm mood + high stress text)
- Intensity: High (punctuation density)
- Reflection: Mixed
```

#### 3. Low Energy - Foggy Weather
```
Input:
- Note: "terrible day, feel lost and confused"
- Energy: 1
- Mood: Drained
- Context: Alone

Expected Output:
- Weather: Foggy 🌫️
- Intensity: Low
- Reflection: Stable or Mixed
```

#### 4. Recovery Pattern
```
Input:
- Note: "getting better, feeling recharged and refreshed"
- Energy: 2
- Mood: Drained
- Context: Health

Expected Output:
- Weather: Windy 💨 (contradiction: drained + positive text)
- Intensity: Low/Medium
- Reflection: Recovering
```

#### 5. High Stress - Stormy Weather
```
Input:
- Note: "overwhelmed!! can't handle this pressure, panic!!!"
- Energy: 2
- Mood: Tense
- Context: Work

Expected Output:
- Weather: Stormy ⛈️
- Intensity: High
- Reflection: Overloaded
```

### Filter Testing

1. **Add 5+ entries** with varying intensities
2. **Test "High Intensity Only"** - should show only high-intensity entries
3. **Test "Mixed/Contradictory"** - should show only mixed/overloaded entries
4. **Test "By Context"** - select Work, should show only work entries
5. **Test "Clear"** button - should reset to all entries

### Summary Testing

1. **Empty state** - no entries should show "No entries yet"
2. **Single entry** - should show basic stats
3. **Multiple entries** - verify:
   - Most frequent weather is correct
   - Average energy calculation is correct
   - Most common context is correct
   - High intensity count is accurate
   - Contradictory count is accurate
   - Derived sentence makes sense

### Edge Cases

1. **Empty note submission** - should show error SnackBar
2. **Very long note (500+ chars)** - should handle gracefully
3. **Special characters in note** - should not crash
4. **Emojis in note** - should not crash
5. **Delete all entries** - should show empty state
6. **Apply filter with no matches** - should show "no matches" empty state
7. **Rapid successive adds** - should maintain order

---

## Future Enhancements

### Potential Features

#### 1. Data Persistence
```
- Integrate SqfliteStorage for local persistence
- Add "Clear All Data" option
- Export entries to JSON/CSV
```

#### 2. Advanced Analytics
```
- Weekly/monthly summaries
- Mood trends over time (charts)
- Context distribution pie chart
- Weather distribution bar chart
- Energy level timeline
```

#### 3. Insights & Recommendations
```
- "You tend to feel drained after work contexts"
- "Your energy peaks around [time]"
- "Consider rest when you see 3+ stormy days"
```

#### 4. Enhanced Filtering
```
- Date range filter
- Weather state filter
- Multiple context selection
- Combined filters (AND/OR logic)
- Search by note text
```

#### 5. UI/UX Improvements
```
- Animations for entry addition/deletion
- Swipe to delete gesture
- Pull to refresh
- Dark mode enhancements
- Custom themes per weather state
```

#### 6. Text Analysis Enhancements
```
- Emoji sentiment analysis
- Capitalization as intensity signal
- Word repetition patterns
- Phrase detection (multi-word keywords)
- Language detection and multilingual support
```

#### 7. Notifications & Reminders
```
- Daily reminder to log entry
- Weekly summary notification
- Alert on overloaded pattern (3+ in a row)
```

#### 8. Social Features
```
- Anonymous sharing of summaries
- Compare with aggregated user trends
- Community insights
```

---

## Known Limitations

### Current Constraints

1. **No Persistence**
   - Data lost on app restart
   - Cannot view historical data beyond current session

2. **English-Only Keywords**
   - Text analysis only supports English
   - Non-English text will have neutral sentiment

3. **Simple NLP**
   - Keyword-based only, no context understanding
   - Cannot detect sarcasm or irony
   - No negation handling ("not good" treated as positive)

4. **Basic Contradiction Logic**
   - Rule-based, not ML-driven
   - May miss nuanced contradictions
   - Weighted scores are manually tuned

5. **Single Day Summary**
   - No historical trend analysis
   - Cannot compare across days
   - No weekly/monthly aggregations

6. **No User Accounts**
   - No multi-user support
   - No cloud sync
   - No cross-device access

---

## Quick Reference

### Common Tasks

#### Adding a New Keyword Category

1. Add keyword list to `TextAnalyzer`:
```dart
static const newCategoryKeywords = ['word1', 'word2', ...];
```

2. Update `TextAnalysisResult` model:
```dart
final int newCategoryKeywordCount;
```

3. Add counting in `analyze()` method:
```dart
final newCategoryCount = _countKeywords(cleanedNote, newCategoryKeywords);
```

4. Update derivation engines to use new category

#### Modifying Weather Rules

1. Edit `WeatherDerivationEngine`
2. Update rule methods (`_isStormy`, `_isClear`, etc.)
3. Test with various entry combinations
4. Update documentation

#### Adjusting Intensity Weights

1. Edit `IntensityCalculator.calculate()` method
2. Modify weight percentages:
```dart
final totalScore =
  energyScore * 0.4 +      // Change this
  punctuationScore * 0.3 + // Or this
  sentimentScore * 0.2 +   // Or this
  moodScore * 0.1;         // Or this
```
3. Test across entry types
4. Update documentation

#### Adding New Filter Type

1. Add to `FilterType` enum
2. Update `FilterBar` widget with new UI
3. Add case to `_applyFilter()` in BLoC
4. Create new event if needed
5. Test filtering logic

---

## Troubleshooting

### Common Issues

#### Issue: Entries not showing
**Solution:** Check BLoC state in debugger, verify `filteredEntries` is not empty

#### Issue: Summary not updating
**Solution:** Ensure `_summaryGenerator.generate()` is called after state changes

#### Issue: Filter not working
**Solution:** Verify `_applyFilter()` logic and check filter state in debugger

#### Issue: Sentiment always neutral
**Solution:** Check keyword matching, verify text is lowercase in analysis

#### Issue: Weather always Cloudy
**Solution:** Review weather derivation rules, check if conditions are too strict

---

## Developer Notes

### Architecture Decisions

1. **Why In-Memory Only?**
   - Simplifies implementation
   - Faster development iteration
   - Focus on core logic over persistence
   - Easy to add persistence later

2. **Why Weighted Scoring?**
   - More nuanced than binary rules
   - Allows fine-tuning without code changes
   - Handles edge cases gracefully
   - Mimics human judgment

3. **Why BLoC Pattern?**
   - Already established in codebase
   - Clean separation of concerns
   - Testable business logic
   - Reactive state management

4. **Why Part Files?**
   - Follows existing codebase pattern
   - Keeps related code together
   - Reduces import boilerplate

### Code Style

- **Naming:** Use descriptive names (e.g., `derivedWeather` not `weather`)
- **Immutability:** All models are immutable with final fields
- **Null Safety:** Use nullable types appropriately (`WeatherState?` in summary)
- **Const:** Use const constructors where possible
- **Equatable:** All data classes extend Equatable for value equality

---

## Contact & Support

For questions, issues, or enhancement requests related to MoodMirror++:

- **Developer:** Gaurav
- **Project:** Flutter Base Assessment
- **Last Updated:** 2026-04-11

---

**End of Documentation**
