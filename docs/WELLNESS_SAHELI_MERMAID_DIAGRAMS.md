# Wellness Saheli — Mermaid Diagram Source

Standalone copies of every diagram from `WELLNESS_SAHELI_UML_DOCUMENTATION.md`,
so they can be pasted directly into any Mermaid renderer (mermaid.live,
VS Code Mermaid preview, GitHub/GitLab markdown, Notion, etc.) without hunting
through the full doc.

---

## 1. Use Case Overview

```mermaid
flowchart TB
    User((User))

    subgraph Account
        UC1[Sign Up]
        UC2[Sign In]
        UC3[Reset Password]
        UC4[Log Out]
    end

    subgraph Cycle
        UC5[Log Period Start/End]
        UC6[Log Mood]
        UC7[Log Symptoms]
        UC8[Log Flow Intensity]
        UC9[View Cycle Dial & Phase Insight]
    end

    subgraph PCOS
        UC10[Read PCOS Information Guide]
        UC11[Run PCOS Detection Form]
        UC12[View PCOS Result & History]
    end

    subgraph Protection
        UC13[Browse Contraception Methods]
        UC14[Run Eligibility Check]
        UC15[Save "I'm using this method"]
        UC16[View Additional Info: EC, Effectiveness, ARV glossary]
    end

    subgraph Diary
        UC17[Write Free-text Diary Entry]
        UC18[Log Wellness Check-in mood/stress]
        UC19[View Unified Health Timeline]
        UC20[View Profile Summary]
    end

    subgraph AICompanion
        UC21[Quick Check-in — select concerns]
        UC22[Receive tab suggestion PCOS/Protection/Mood]
        UC23[Converse with AI Companion - planned]
    end

    subgraph Privacy
        UC24[Toggle AI Memory / Diary Access - planned]
        UC25[Clear AI Memory / Delete Diary - planned]
    end

    User --> UC1
    User --> UC2
    User --> UC3
    User --> UC4
    User --> UC5
    User --> UC6
    User --> UC7
    User --> UC8
    User --> UC9
    User --> UC10
    User --> UC11
    User --> UC12
    User --> UC13
    User --> UC14
    User --> UC15
    User --> UC16
    User --> UC17
    User --> UC18
    User --> UC19
    User --> UC20
    User --> UC21
    User --> UC22
    User --> UC23
    User --> UC24
    User --> UC25

    UC11 -.uses.-> PCOSAPI[(PCOS Prediction API)]
    UC14 -.uses.-> ELIGAPI[(Eligibility API)]
    UC1 -.uses.-> AUTHAPI[(Auth Backend)]
    UC2 -.uses.-> AUTHAPI
    UC3 -.uses.-> AUTHAPI
    UC23 -.uses.-> AIAPI[(AI/LLM Backend - planned)]
```

---

## 2. Class Diagram — Data Model Layer

```mermaid
classDiagram
    class HealthProfile {
        +String userId
        +Demographics demographics
        +Lifestyle lifestyle
        +ReproductiveHistory reproductiveHistory
        +List~PcosCheckResult~ pcosHistory
        +MentalHealthFlags mentalHealth
        +List~ConversationEntry~ conversationLog
        +List~DiaryEntry~ diaryEntries
        +PrivacySettings privacySettings
        +DateTime lastUpdated
        +empty(userId) HealthProfile
        +copyWith(...) HealthProfile
        +toJson() Map
        +fromJson(json) HealthProfile
    }

    class Demographics {
        +int? ageYrs
        +double? weightKg
        +double? heightCm
        +String? maritalStatus
    }

    class Lifestyle {
        +bool? regularExercise
        +String? exerciseFrequency
        +String? dietQuality
        +bool? fastFoodFrequent
        +double? averageSleepHours
        +String? notes
    }

    class ReproductiveHistory {
        +String? cycleRegularity
        +int? cycleLengthDays
        +String? currentContraceptionMethod
        +List~ContraceptionLogEntry~ contraceptionHistory
    }

    class ContraceptionLogEntry {
        +DateTime date
        +String method
        +String? note
    }

    class PcosCheckResult {
        +DateTime date
        +String prediction
        +double pcosProbability
        +String modelUsed
    }

    class MentalHealthFlags {
        +int? selfReportedStressLevel
        +String? notes
        +DateTime? lastCheckIn
    }

    class ConversationEntry {
        +DateTime timestamp
        +String role
        +String message
        +String? sessionId
    }

    class DiaryEntry {
        +String id
        +DateTime date
        +String text
        +String? mood
        +List~String~ symptomTags
        +List~String~ tags
    }

    class PrivacySettings {
        +bool aiCanAccessDiary
        +bool aiMemoryEnabled
    }

    HealthProfile "1" *-- "1" Demographics
    HealthProfile "1" *-- "1" Lifestyle
    HealthProfile "1" *-- "1" ReproductiveHistory
    HealthProfile "1" *-- "1" MentalHealthFlags
    HealthProfile "1" *-- "1" PrivacySettings
    HealthProfile "1" *-- "many" PcosCheckResult
    HealthProfile "1" *-- "many" ConversationEntry
    HealthProfile "1" *-- "many" DiaryEntry
    ReproductiveHistory "1" *-- "many" ContraceptionLogEntry

    class HealthProfileService {
        +loadProfile() Future~HealthProfile~
        +updateProfile(mutator) Future~void~
        +appendConversationEntry(entry, sessionId) Future~void~
    }

    HealthProfileService ..> HealthProfile : reads/writes

    class CycleProvider {
        -CycleData _cycleData
        -Map~String,DailyLog~ _dailyLogs
        -bool _isLoggedIn
        -String _userName
        +currentCycleDay int
        +currentPhase String
        +daysUntilNextPeriod int
        +login(name)
        +signUp(...)
        +signIn(...)
        +resetPassword(...)
        +logout()
        +selectPeriodDate(date)
        +logMood(date, mood)
        +logSymptoms(date, symptoms)
        +logFlowIntensity(date, intensity)
    }

    class CycleData {
        +DateTime lastPeriodStart
        +int cycleLength
        +int periodDuration
        +getCurrentCycleDay() int
        +getPhase() String
        +daysUntilNextPeriod() int
    }

    class DailyLog {
        +bool isPeriodDay
        +String? mood
        +List~String~ symptoms
        +String? flowIntensity
    }

    CycleProvider "1" *-- "1" CycleData
    CycleProvider "1" *-- "many" DailyLog : keyed by date string

    class PcosApiService {
        +predict(...) Future~PcosResult~
    }

    class PcosResult {
        +String prediction
        +double pcosProbability
        +String modelUsed
    }

    class EligibilityApiService {
        +fetchConditions() Future~List~Condition~~
        +checkEligibility(ids) Future~List~MethodResult~~
    }

    class Condition {
        +String id
        +String label
    }

    class MethodResult {
        +String methodLabel
        +int category
    }

    PcosApiService ..> PcosResult
    EligibilityApiService ..> Condition
    EligibilityApiService ..> MethodResult
```

---

## 3. Screen / Widget Relationship Diagram

```mermaid
classDiagram
    class HomeShell {
        -int _tabIndex
        +_navigateToTab(tabName)
    }
    class HomeScreen {
        +onNavigateToTab callback
    }
    class AiCheckinScreen {
        +onNavigateToTab callback
        -Set~String~ _selected
        -_computeSuggestion() Suggestion
    }
    class PcosScreen
    class ProtectionScreen
    class EndoScreen
    class OvulationScreen
    class LearnScreen
    class SettingsScreen
    class HealthDiaryScreen

    class WellnessCheckInDialog {
        <<function>>
        showWellnessCheckInDialog(context, current, onSaved)
    }
    class DiaryEntryDialog {
        <<function>>
        showDiaryEntryDialog(context, onSaved)
    }

    HomeShell "1" o-- "8" HomeScreen
    HomeShell o-- AiCheckinScreen
    HomeShell o-- PcosScreen
    HomeShell o-- ProtectionScreen
    HomeShell o-- EndoScreen
    HomeShell o-- OvulationScreen
    HomeShell o-- LearnScreen
    HomeShell o-- SettingsScreen

    HomeScreen ..> HealthDiaryScreen : navigates to (book icon)
    HomeScreen ..> AiCheckinScreen : banner switches tab

    PcosScreen ..> WellnessCheckInDialog : after positive result
    ProtectionScreen ..> WellnessCheckInDialog : after eligibility results
    HealthDiaryScreen ..> WellnessCheckInDialog : Wellbeing section
    HealthDiaryScreen ..> DiaryEntryDialog : "Write in your diary"
    AiCheckinScreen ..> WellnessCheckInDialog : mood suggestion

    WellnessCheckInDialog ..> HealthProfileService
    DiaryEntryDialog ..> HealthProfileService
    PcosScreen ..> HealthProfileService
    ProtectionScreen ..> HealthProfileService
    HealthDiaryScreen ..> HealthProfileService
    AiCheckinScreen ..> HealthProfileService
```

---

## 4. Sequence Diagram — PCOS Detection → Diary Timeline

```mermaid
sequenceDiagram
    actor User
    participant PcosScreen
    participant PcosApiService
    participant PCOSAPI as PCOS Prediction API
    participant HealthProfileService
    participant WellnessDialog as showWellnessCheckInDialog

    User->>PcosScreen: Fill form, tap "Run PCOS Detection"
    PcosScreen->>PcosScreen: Validate form fields
    PcosScreen->>PcosApiService: predict(ageYrs, weightKg, ..., regularExercise)
    PcosApiService->>PCOSAPI: HTTP request
    PCOSAPI-->>PcosApiService: prediction, probability, modelUsed
    PcosApiService-->>PcosScreen: PcosResult
    PcosScreen->>PcosScreen: setState(_result), render result card
    alt result is positive (PCOS Detected)
        PcosScreen->>User: Show "How are you feeling about this result?" button
        User->>PcosScreen: Tap button
        PcosScreen->>HealthProfileService: loadProfile()
        HealthProfileService-->>PcosScreen: HealthProfile
        PcosScreen->>WellnessDialog: show(context, profile, onSaved)
        User->>WellnessDialog: Set stress slider, optional note, Save
        WellnessDialog->>HealthProfileService: updateProfile(mentalHealth.copyWith(...))
        HealthProfileService-->>WellnessDialog: success
    end
```

---

## 5. Sequence Diagram — Eligibility Check → Fire-and-Forget Diary Logging

```mermaid
sequenceDiagram
    actor User
    participant ProtectionScreen
    participant EligibilityApiService
    participant ELIGAPI as Eligibility API
    participant HealthProfileService

    User->>ProtectionScreen: Select conditions, tap "Check my eligibility"
    ProtectionScreen->>ProtectionScreen: Filter to backend-known condition IDs
    alt no valid IDs
        ProtectionScreen-->>User: Inline error: "not supported yet"
    else valid IDs present
        ProtectionScreen->>EligibilityApiService: checkEligibility(validIds)
        EligibilityApiService->>ELIGAPI: HTTP request
        ELIGAPI-->>EligibilityApiService: List of MethodResult (method, category)
        EligibilityApiService-->>ProtectionScreen: List~MethodResult~
        ProtectionScreen->>User: Render result cards (color-coded by category)
        par fire-and-forget, does not block UI
            ProtectionScreen->>HealthProfileService: updateProfile(append ContraceptionLogEntry per result)
            HealthProfileService-->>ProtectionScreen: (silent; errors swallowed)
        end
        ProtectionScreen->>User: Show "How are you feeling about these results?" button
    end
```

---

## 6. Sequence Diagram — Diary Entry: Write and Persist

```mermaid
sequenceDiagram
    actor User
    participant HealthDiaryScreen
    participant DiaryEntryDialog as showDiaryEntryDialog
    participant HealthProfileService

    User->>HealthDiaryScreen: Tap "Write in your diary"
    HealthDiaryScreen->>DiaryEntryDialog: show(context, onSaved: _load)
    User->>DiaryEntryDialog: Enter text, optional mood chip, optional symptom chips
    User->>DiaryEntryDialog: Tap Save
    DiaryEntryDialog->>DiaryEntryDialog: Build DiaryEntry(id, date, text, mood, symptomTags)
    DiaryEntryDialog->>HealthProfileService: updateProfile(diaryEntries += entry)
    HealthProfileService-->>DiaryEntryDialog: success
    DiaryEntryDialog->>HealthDiaryScreen: onSaved() callback
    HealthDiaryScreen->>HealthProfileService: loadProfile() (reload)
    HealthProfileService-->>HealthDiaryScreen: updated HealthProfile
    HealthDiaryScreen->>User: Timeline re-renders with new 📝 entry
```

---

## 7. Sequence Diagram — AI Check-in: Concern Selection → Tab Suggestion

```mermaid
sequenceDiagram
    actor User
    participant HomeScreen
    participant HomeShell
    participant AiCheckinScreen
    participant WellnessDialog as showWellnessCheckInDialog

    User->>HomeScreen: Tap "Want a quick check-in?" banner
    HomeScreen->>HomeShell: onNavigateToTab('checkin')
    HomeShell->>HomeShell: setState(_tabIndex = checkin index)
    HomeShell-->>User: IndexedStack shows AiCheckinScreen (state preserved)

    User->>AiCheckinScreen: Select concern chips
    User->>AiCheckinScreen: Tap "See what's useful for me"
    AiCheckinScreen->>AiCheckinScreen: _computeSuggestion() → pcos | protection | mood | none

    alt suggestion = pcos or protection
        AiCheckinScreen-->>User: Suggestion card with "Take me there"
        User->>AiCheckinScreen: Tap "Take me there"
        AiCheckinScreen->>HomeShell: onNavigateToTab('pcos' | 'protection')
        HomeShell->>HomeShell: setState(_tabIndex = target index)
    else suggestion = mood
        AiCheckinScreen-->>User: Suggestion card with "Log how I'm feeling"
        User->>AiCheckinScreen: Tap button
        AiCheckinScreen->>WellnessDialog: show(context, profile, onSaved)
    else suggestion = none
        AiCheckinScreen-->>User: Informational card, no action
    end
```

---

## 8. Sequence Diagram — Authentication (Sign In)

```mermaid
sequenceDiagram
    actor User
    participant SignInScreen as "Sign-in UI (unreviewed)"
    participant CycleProvider
    participant AuthBackend as "Auth Backend (PythonAnywhere)"
    participant SharedPreferences

    User->>SignInScreen: Enter email, password, submit
    SignInScreen->>CycleProvider: signIn(email, password)
    CycleProvider->>AuthBackend: POST /signin {email, password}
    alt success
        AuthBackend-->>CycleProvider: 200 {name}
        CycleProvider->>CycleProvider: login(name)
        CycleProvider->>SharedPreferences: setBool(isLoggedIn, true), setString(userName, name)
        CycleProvider-->>SignInScreen: null (no error)
        SignInScreen-->>User: Navigate to HomeShell
    else failure
        AuthBackend-->>CycleProvider: non-200 {detail}
        CycleProvider-->>SignInScreen: error message string
        SignInScreen-->>User: Show error
    else network failure
        CycleProvider-->>SignInScreen: "Could not reach the server..."
    end
```
