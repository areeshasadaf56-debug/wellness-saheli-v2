# 🌸 Wellness Saheli

> **Your personal women's health companion** — cycle tracking, PCOS detection, contraception guidance, and an AI check-in, all in one privacy-first app.



---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Frontend Setup (Flutter)](#frontend-setup-flutter)
  - [Backend Setup (Python)](#backend-setup-python)
  - [Environment Variables](#environment-variables)
- [API Reference](#api-reference)
- [Architecture](#architecture)
- [Known Issues & Fixes](#known-issues--fixes)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

Wellness Saheli is a Flutter mobile app paired with a Python backend that helps women track their reproductive health, understand their cycle phases, screen for PCOS risk, explore contraception options, and check in with an AI wellness companion — all while keeping their data private and under their control.

The app is designed with South Asian users in mind, offering culturally sensitive language and locally relevant health guidance.

---

## Features

### 🩸 Cycle Tracking
- Log period start/end, mood, symptoms, and flow intensity
- Visual cycle dial showing current phase
- Fertility window and ovulation day predictions
- Detailed phase-by-phase educational content (Menstrual → Follicular → Ovulation → Luteal)

### 🔬 PCOS Detection
- Symptom-based risk screening form
- ML-powered prediction via backend API
- Full result history with probability scores
- Informational guide on PCOS symptoms, causes, and management

### 🛡️ Contraception & Protection
- Browse all major contraception methods with detailed descriptions
- WHO Medical Eligibility Criteria (MEC) checker — enter your health conditions, get category ratings per method
- "I'm using this method" tracker
- Emergency contraception, effectiveness rates, and ARV interaction glossary

### 🤖 AI Wellness Companion (Saheli)
- Conversational AI check-in powered by your backend LLM
- Remembers past sessions (with user-controlled privacy toggle)
- Detects crisis signals and shows appropriate support resources
- Suggests relevant app sections (PCOS tab, Protection tab) based on conversation
- Chat history with session management

### 📓 Health Diary
- Free-text personal journal entries
- Mood and symptom tagging
- Unified health timeline combining cycle logs, PCOS results, eligibility checks, and diary entries
- Wellness check-in (stress slider + notes)

### 🔒 Privacy Controls
- Toggle AI memory on/off
- Toggle diary access for AI on/off
- All data stored locally + your own backend — no third-party data sharing

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile Frontend | Flutter (Dart) |
| State Management | Provider |
| Fonts | Google Fonts (Playfair Display + DM Sans) |
| HTTP Client | `package:http` |
| Local Storage | SharedPreferences |
| Backend | Python (Flask / FastAPI) |
| ML Model | Scikit-learn (PCOS prediction) |
| Auth | Custom Python backend (PythonAnywhere) |
| Hosting | PythonAnywhere |

---

## Project Structure

```
wellness_saheli/                  ← Flutter frontend
├── lib/
│   ├── main.dart                 ← App entry point
│   ├── config/
│   │   └── api_config.dart       ← Base URL and API constants
│   ├── models/
│   │   ├── health_profile.dart   ← All data models (single source of truth)
│   │   └── ai_response.dart      ← AI response model
│   ├── providers/
│   │   └── cycle_provider.dart   ← Cycle state + auth logic
│   ├── services/
│   │   ├── health_profile_service.dart  ← Load/save health profile
│   │   ├── ai_service.dart              ← AI chat API calls
│   │   ├── pcos_api_service.dart        ← PCOS prediction API calls
│   │   └── eligibility_api_service.dart ← MEC eligibility API calls
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── home_screen.dart
│   │   ├── ai_checkin_screen.dart
│   │   ├── pcos_screen.dart
│   │   ├── protection_screen.dart
│   │   ├── ovulation_screen.dart
│   │   ├── health_diary_screen.dart
│   │   └── settings_screen.dart
│   └── theme/
│       └── app_theme.dart        ← Colors, text styles, theme

wellness-saheli-server/           ← Python backend
├── app.py / server.py            ← Main server file
├── pcos_model/                   ← ML model files
├── requirements.txt
└── .env                          ← API keys and config
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.0.0
- Dart ≥ 3.0.0
- Python ≥ 3.9
- An Android emulator / iOS simulator, or a physical device
- (Optional) A [PythonAnywhere](https://www.pythonanywhere.com/) account for hosting the backend

---

### Frontend Setup (Flutter)

1. **Clone the repository**
   ```bash
   git clone https://github.com/areeshasadaf56-debug/wellness-saheli-app.git
   cd wellness-saheli-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure the API base URL**

   Open `lib/config/api_config.dart` and set your backend URL:
   ```dart
   class ApiConfig {
     static const String baseUrl = 'https://your-backend.pythonanywhere.com';
   }
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

---

### Backend Setup (Python)

1. **Clone the backend repository**
   ```bash
   git clone https://github.com/areeshasadaf56-debug/wellness-saheli-server.git
   cd wellness-saheli-server
   ```

2. **Create a virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate       # macOS/Linux
   venv\Scripts\activate          # Windows
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up environment variables**

   Create a `.env` file in the root:
   ```env
   OPENAI_API_KEY=your_openai_key_here
   SECRET_KEY=your_secret_key_here
   ```

5. **Run the server locally**
   ```bash
   python app.py
   ```
   The server will start at `http://localhost:5000`.

---

### Environment Variables

| Variable | Description | Required |
|---|---|---|
| `OPENAI_API_KEY` | OpenAI API key for the AI companion | ✅ |
| `SECRET_KEY` | Flask secret key for session signing | ✅ |

---

## API Reference

### Authentication

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/signup` | Register a new user |
| `POST` | `/signin` | Sign in, returns `{ name }` |
| `POST` | `/reset-password` | Request password reset |

**Sign In Request:**
```json
{
  "email": "user@example.com",
  "password": "yourpassword"
}
```
**Sign In Response (200):**
```json
{ "name": "Areesha" }
```

---

### PCOS Detection

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/predict-pcos` | Run PCOS risk prediction |

**Request:**
```json
{
  "age": 25,
  "weight_kg": 65,
  "height_cm": 162,
  "cycle_regularity": "Irregular",
  "regular_exercise": false
}
```
**Response:**
```json
{
  "prediction": "PCOS Detected",
  "pcos_probability": 0.73,
  "model_used": "RandomForest_v2"
}
```

---

### Eligibility Check (WHO MEC)

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/conditions` | List all supported medical conditions |
| `POST` | `/eligibility` | Check contraception eligibility |

**Eligibility Request:**
```json
{
  "condition_ids": ["hypertension", "migraine_with_aura"]
}
```
**Eligibility Response:**
```json
[
  { "method_label": "Combined Pill", "category": 4 },
  { "method_label": "Progestogen-only Pill", "category": 2 },
  { "method_label": "Copper IUD", "category": 1 }
]
```
*Categories follow WHO MEC: 1 = No restriction, 2 = Advantages outweigh risks, 3 = Risks outweigh advantages, 4 = Unacceptable health risk.*

---

### AI Companion Chat

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/chat` | Send a message to Saheli AI |

**Request:**
```json
{
  "message": "I've been feeling really stressed lately",
  "history": [
    { "role": "assistant", "message": "Hi! How have you been feeling?" }
  ],
  "profile_context": {
    "demographics": { "age_yrs": 24 },
    "lifestyle": { "average_sleep_hours": 5.5 }
  }
}
```
**Response:**
```json
{
  "reply": "I'm sorry to hear that. Stress can really affect your cycle too...",
  "suggested_tab": "pcos",
  "suggested_tab_reason": "Some of your symptoms may be worth checking.",
  "crisis_concern": false,
  "medical_emergency_concern": false,
  "profile_updates": {
    "mental_health": { "self_reported_stress_level": 4 }
  }
}
```

---

## Architecture

### Data Flow

```
User Action
    │
    ▼
Flutter Widget (Screen)
    │
    ├── Provider (CycleProvider) — cycle state, auth
    │
    ├── Service Layer
    │     ├── HealthProfileService — local profile persistence
    │     ├── AiService           — POST /chat
    │     ├── PcosApiService      — POST /predict-pcos
    │     └── EligibilityService  — POST /eligibility
    │
    └── Python Backend
          ├── Auth endpoints
          ├── PCOS ML model
          ├── WHO MEC eligibility logic
          └── LLM-powered AI chat
```

### Key Design Decisions

- **Single health profile model** — `HealthProfile` in `health_profile.dart` is the single source of truth shared across all tabs. The AI companion, PCOS tab, and Protection tab all read from and write to the same profile, so data from one screen is visible in another without re-asking the user.

- **Session-based AI chat** — Each conversation is grouped by `sessionId` (a timestamp string). Past sessions are stored in the profile's `conversationLog` and browsable from the chat history sheet.

- **Privacy by design** — The AI companion checks two user-controlled toggles before sending data: `aiMemoryEnabled` (whether to send conversation history) and `aiCanAccessDiary` (whether to include diary entries as context).

- **Fire-and-forget diary logging** — When the Protection tab runs an eligibility check, the result is silently written to the health diary in the background without blocking the UI or showing errors to the user.

---

## Known Issues & Fixes

### ✅ Fixed: `missing_required_argument: children` (17 errors in `ai_checkin_screen.dart`)

**Cause:** `lib/theme/app_theme.dart` had an accidental `required List<Expanded> children` parameter on the `AppTextStyles.sans()` method. Since `sans()` is called throughout the entire app, every call site reported a missing `children` argument.

**Fix:** Remove that parameter from `sans()`:
```dart
// ❌ Before (broken)
static TextStyle sans({
  double size = 14,
  FontWeight weight = FontWeight.normal,
  Color color = AppColors.textPrimary,
  required List<Expanded> children,   // ← delete this line
}) { ... }

// ✅ After (fixed)
static TextStyle sans({
  double size = 14,
  FontWeight weight = FontWeight.normal,
  Color color = AppColors.textPrimary,
}) { ... }
```

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m "Add: your feature description"`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Open a Pull Request

Please make sure `flutter analyze` passes with no errors before submitting a PR.

---

## License

This project is for educational and personal use. All health information provided by the app is for informational purposes only and does not constitute medical advice. Always consult a qualified healthcare professional for medical decisions.

---

*Built with 💜 by Areesha — because women deserve better health tools.*