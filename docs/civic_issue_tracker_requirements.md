# Civic Issue Tracker - Feature Requirements & Technical Design

## 📋 Overview
A Flutter application to help citizens report civic issues to appropriate government bodies with a simple, accessible interface suitable for all age groups.

---

## 🎯 User Stories

### US-1: Lodge a Civic Issue
**As a** citizen
**I want to** report civic problems in my area
**So that** the appropriate government body can address them

**Acceptance Criteria:**
- User can access issue reporting form
- User can submit issue with all required details
- User receives confirmation after submission
- Issue appears in the feed immediately after submission

### US-2: View Community Issues Feed
**As a** citizen
**I want to** view all reported issues in my community
**So that** I can stay informed about local civic problems

**Acceptance Criteria:**
- User can view a scrollable feed of all reported issues
- Each issue displays: reporter name, government body, location, zone, direction, and image
- Feed updates immediately when new issues are reported

---

## 🏗️ Architecture

### Clean Architecture Layers

```
lib/
├── domain/
│   ├── models/              # Domain entities
│   │   ├── issue_report.dart
│   │   ├── government_body.dart
│   │   ├── location_direction.dart
│   │   └── zone.dart
│   └── repositories/        # Abstract repository interfaces
│       └── issue_repository.dart
├── data/
│   └── repositories/        # Repository implementations
│       └── in_memory_issue_repository.dart
├── presentation/
│   ├── issue_form/
│   │   ├── bloc/
│   │   │   ├── issue_form_bloc.dart
│   │   │   ├── issue_form_event.dart
│   │   │   └── issue_form_state.dart
│   │   └── view/
│   │       └── issue_form_page.dart
│   ├── issue_feed/
│   │   ├── bloc/
│   │   │   ├── issue_feed_bloc.dart
│   │   │   ├── issue_feed_event.dart
│   │   │   └── issue_feed_state.dart
│   │   └── view/
│   │       ├── issue_feed_page.dart
│   │       └── widgets/
│   │           └── issue_card.dart
│   └── home/
│       └── civic_home_page.dart
└── core/
    └── utils/
        └── image_picker_helper.dart
```

---

## 📦 Domain Models

### 1. IssueReport
```dart
class IssueReport {
  final String id;
  final String reporterName;
  final GovernmentBody governmentBody;
  final String address;
  final LocationDirection direction;
  final Zone zone;
  final String? imagePath;  // Local file path
  final DateTime reportedAt;
}
```

### 2. GovernmentBody (Enum)
- Water Bodies
- Roads Body
- Public Infrastructure
- Sanitation Department
- Electricity Board
- Parks & Recreation

### 3. LocationDirection (Enum)
- North
- South
- East
- West

### 4. Zone (Enum)
- Z1, Z2, Z3, Z4, Z5, Z6

---

## 🎨 UI/UX Design Principles

### Material 3 Guidelines
- **Color Scheme**: Use Material 3 color schemes with proper contrast
- **Typography**: Large, readable fonts (minimum 16sp for body text)
- **Touch Targets**: Minimum 48x48 logical pixels for interactive elements
- **Spacing**: Generous padding and margins (16dp, 24dp)

### Accessibility Features
- **Semantic Labels**: All interactive widgets properly labeled
- **Screen Reader Support**: Full Semantics widget implementation
- **High Contrast**: Material 3 color roles for readability
- **Clear Visual Hierarchy**: Cards, elevation, and proper grouping
- **Error States**: Clear error messages with icons

### Form Design (Issue Form Page)
```
┌─────────────────────────────┐
│  Report Civic Issue         │
│                             │
│  [TextField: Your Name]     │
│                             │
│  [Dropdown: Govt Body]      │
│                             │
│  [TextField: Address]       │
│    (Multi-line)             │
│                             │
│  [Dropdown: Direction]      │
│                             │
│  [Dropdown: Zone]           │
│                             │
│  [Image Picker Button]      │
│  [Preview if selected]      │
│                             │
│  [Submit Button - Primary]  │
└─────────────────────────────┘
```

### Feed Design (Issue Feed Page)
```
┌─────────────────────────────┐
│  Community Issues           │
│                             │
│  ┌───────────────────────┐  │
│  │ [Issue Card]          │  │
│  │ Image                 │  │
│  │ Reporter: Name        │  │
│  │ Body: Roads Body      │  │
│  │ Zone: Z2 - North      │  │
│  │ Address: ...          │  │
│  │ Reported: 2 hours ago │  │
│  └───────────────────────┘  │
│                             │
│  [FAB: + Report Issue]      │
└─────────────────────────────┘
```

---

## 🔄 BLoC State Management

### Issue Form BLoC

**Events:**
- `IssueFormNameChanged(String name)`
- `IssueFormBodyChanged(GovernmentBody body)`
- `IssueFormAddressChanged(String address)`
- `IssueFormDirectionChanged(LocationDirection direction)`
- `IssueFormZoneChanged(Zone zone)`
- `IssueFormImageSelected(String? imagePath)`
- `IssueFormSubmitted()`
- `IssueFormReset()`

**States:**
```dart
class IssueFormState {
  final String name;
  final GovernmentBody? governmentBody;
  final String address;
  final LocationDirection? direction;
  final Zone? zone;
  final String? imagePath;
  final FormStatus status; // initial, loading, success, error
  final String? errorMessage;
  final bool isValid;
}
```

### Issue Feed BLoC

**Events:**
- `IssueFeedLoaded()`
- `IssueAdded(IssueReport issue)`

**States:**
```dart
class IssueFeedState {
  final List<IssueReport> issues;
  final FeedStatus status; // loading, loaded, error
  final String? errorMessage;
}
```

---

## 📋 Implementation Checklist

### Phase 1: Domain Layer
- [ ] Create `IssueReport` model
- [ ] Create `GovernmentBody` enum
- [ ] Create `LocationDirection` enum
- [ ] Create `Zone` enum
- [ ] Create `IssueRepository` abstract class

### Phase 2: Data Layer
- [ ] Implement `InMemoryIssueRepository`

### Phase 3: Presentation - Form
- [ ] Create Issue Form BLoC (events, states, bloc)
- [ ] Create Issue Form Page UI
- [ ] Implement form validation
- [ ] Add image picker functionality
- [ ] Add semantic labels

### Phase 4: Presentation - Feed
- [ ] Create Issue Feed BLoC (events, states, bloc)
- [ ] Create Issue Feed Page UI
- [ ] Create Issue Card widget
- [ ] Add time formatting (e.g., "2 hours ago")

### Phase 5: Integration
- [ ] Create Civic Home Page with navigation
- [ ] Wire up repository with both BLoCs
- [ ] Add navigation between form and feed
- [ ] Test complete flow

### Phase 6: Polish
- [ ] Material 3 theme configuration
- [ ] Accessibility testing
- [ ] UI/UX refinements

---

## 🔧 Dependencies Required

```yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  image_picker: ^1.0.4
  intl: ^0.18.1  # For date formatting
  uuid: ^4.0.0   # For generating IDs
```

---

## 📱 Key Features

### Form Validation
- Name: Required, minimum 2 characters
- Government Body: Required
- Address: Required, minimum 10 characters
- Direction: Required
- Zone: Required
- Image: Optional but recommended

### Feed Features
- Reverse chronological order (newest first)
- Empty state when no issues reported
- Pull-to-refresh (optional enhancement)
- Card-based design for easy scanning

---

## 🎯 SOLID Principles Application

1. **Single Responsibility**: Each BLoC handles one feature, models are focused
2. **Open/Closed**: Repository pattern allows extension without modification
3. **Liskov Substitution**: Repository interface allows different implementations
4. **Interface Segregation**: Focused repository methods
5. **Dependency Inversion**: BLoCs depend on repository abstraction, not implementation

---

## 🧪 Testing Strategy

- Unit tests for BLoCs
- Widget tests for UI components
- Integration tests for complete flows
- Accessibility tests using Flutter's semantics

---

## 📊 File Changeset Summary

### New Files to Create (25 files)

**Domain Layer (5 files):**
1. `lib/domain/models/issue_report.dart`
2. `lib/domain/models/government_body.dart`
3. `lib/domain/models/location_direction.dart`
4. `lib/domain/models/zone.dart`
5. `lib/domain/repositories/issue_repository.dart`

**Data Layer (1 file):**
6. `lib/data/repositories/in_memory_issue_repository.dart`

**Presentation - Issue Form (4 files):**
7. `lib/presentation/issue_form/bloc/issue_form_bloc.dart`
8. `lib/presentation/issue_form/bloc/issue_form_event.dart`
9. `lib/presentation/issue_form/bloc/issue_form_state.dart`
10. `lib/presentation/issue_form/view/issue_form_page.dart`

**Presentation - Issue Feed (6 files):**
11. `lib/presentation/issue_feed/bloc/issue_feed_bloc.dart`
12. `lib/presentation/issue_feed/bloc/issue_feed_event.dart`
13. `lib/presentation/issue_feed/bloc/issue_feed_state.dart`
14. `lib/presentation/issue_feed/view/issue_feed_page.dart`
15. `lib/presentation/issue_feed/view/widgets/issue_card.dart`
16. `lib/presentation/issue_feed/view/widgets/empty_feed_widget.dart`

**Presentation - Home (1 file):**
17. `lib/presentation/civic_home/civic_home_page.dart`

**Core Utilities (2 files):**
18. `lib/core/utils/image_picker_helper.dart`
19. `lib/core/utils/date_formatter.dart`

**Theme (1 file):**
20. `lib/core/theme/civic_theme.dart`

**Modified Files (2 files):**
21. `lib/app/view/app.dart` - Add civic tracker route and theme
22. `pubspec.yaml` - Add new dependencies

**Documentation (1 file):**
23. `docs/civic_issue_tracker_requirements.md` (this file)

---

## 🚀 Implementation Timeline

**Total Estimated Development: ~6-8 hours**

1. Domain Models & Repository Interface: 30 min
2. In-Memory Repository Implementation: 20 min
3. Issue Form BLoC: 45 min
4. Issue Form UI: 1.5 hours
5. Issue Feed BLoC: 30 min
6. Issue Feed UI: 1.5 hours
7. Home Page & Navigation: 30 min
8. Theme & Accessibility: 1 hour
9. Testing & Refinement: 1-2 hours

---

## 📝 Notes

- Using in-memory storage means data won't persist between app restarts
- Images will be stored as local file paths
- Future enhancements could include:
  - Local database persistence (Hive/SQLite)
  - Backend API integration
  - Image compression and optimization
  - Location picker with maps
  - Issue status tracking (Pending/In Progress/Resolved)
  - User authentication
  - Push notifications

---

**Document Version**: 1.0
**Last Updated**: 2026-04-13
**Author**: Civic Issue Tracker Team
