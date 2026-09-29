# Wellness Saheli — Software Requirements Specification (SRS)

**Version:** 2.0 (fully expanded)
**Date:** 13 September 2026
**Status:** Derived from and verified against the live codebase
**Repositories:**
- Frontend: `github.com/areeshasadaf56-debug/wellness-saheli-app` (Flutter/Dart)
- Backend: `github.com/areeshasadaf56-debug/wellness-saheli-server` (Python/Flask)
- Deployed backend: `https://areeshasadaf56.pythonanywhere.com`

---

## 0. Document Control

### 0.1 Purpose of this document
This SRS is written to be handed directly to a developer or an AI coding agent as the authoritative specification of the system. Every requirement below is traceable to a specific file, class, function, or endpoint in the existing codebase. Where a requirement describes something not yet built, it is explicitly marked **[NOT IMPLEMENTED]**.

### 0.2 Corrections to v1.0 of the requirements document
The previous requirements document contained statements that no longer match the implemented system. These are corrected throughout and listed here for visibility:

| v1.0 statement | Reality in code | Corrected in |
|---|---|---|
| "backed by a Python/FastAPI service" | Backend is **Flask** (`main_flask.py`), native WSGI. FastAPI was the original design but was replaced for PythonAnywhere free-tier compatibility (no ASGI bridge needed). A vestigial `app_backend/main.py` and a `Procfile` referencing `uvicorn` remain in the repo but are **not** what runs. | §1, §13 |
| FR-04: "shall allow app usage without an account, using a locally generated anonymous device ID" | Sign-in is **required**. `splash_screen.dart` gates all screens behind auth. The device ID (`health_profile_device_id`) survives only as a local-only fallback identifier when no account session exists — it cannot sync to the backend, because every `/profile` route now requires a Bearer token. | FR-04 (revised) |
| SEC "Known gap: `/profile/{user_id}` is not currently authenticated" | **Resolved.** `health_profile_api.py` now applies `@require_auth` to GET/PUT/DELETE and additionally enforces `g.current_user_id == user_id` (ownership check, returns 403 on mismatch). | §11 |
| AC-03: "a category (1–4) for each of the **10** listed methods" | There are **9** methods in `METHODS` (chc, pop, inj, imp, lng_iud, cu_iud, barrier, lam, sterilization). The separate `EFFECTIVENESS` list has 14 entries — that is a different list and is not what `/eligibility` returns. | AC-03, FR-12 |
| §5 lists 18 conditions implicitly | `CONDITIONS` contains **60** conditions across three expansion rounds. | FR-12 |
| "Multi-language support beyond English/Urdu (if completed)" — Urdu framed as hypothetical | Urdu toggle is **implemented** end-to-end (UI toggle, persisted preference, `language` field in the `/chat` request, backend system-prompt injection). | §9, FR-22 |

### 0.3 Terminology
- **Profile / diary**: the `HealthProfile` JSON document — the single per-user record holding demographics, lifestyle, reproductive history, PCOS history, eligibility history, mental-health flags, conversation log, diary entries, and privacy settings.
- **Screening**, not diagnosis: the app never asserts a medical condition exists.
- **Category (1–4)**: WHO Medical Eligibility Criteria safety category for a contraceptive method given a condition.

---

## 1. Project Overview

Wellness Saheli is a women's reproductive-health application consisting of:

1. A **Flutter** client (Android, iOS, Web from one codebase) — 18 screens, 9 reusable widgets, 4 data models, 5 API service classes, 1 state provider.
2. A **Flask** backend deployed on PythonAnywhere's free tier, exposing 13 HTTP endpoints across 3 blueprints, backed by 3 SQLite databases and one pre-trained scikit-learn model artifact.

It provides: menstrual cycle tracking, ovulation/fertility estimation, ML-based PCOS risk screening, WHO-MEC-based contraceptive eligibility checking, a bilingual (English/Urdu) AI check-in companion with voice input and file attachments, educational content, and a unified health diary synced across devices.

---

## 2. Problem Statement

Women, particularly in under-resourced settings, lack a single accessible tool combining cycle tracking, PCOS screening, contraceptive guidance, and supportive conversation without requiring a clinic visit for basic informational needs. Existing apps typically cover only one of these areas in isolation, and few provide any Urdu-language support.

---

## 3. Project Objectives

| ID | Objective | Satisfied by |
|---|---|---|
| OBJ-01 | Provide accurate menstrual cycle and ovulation tracking | FR-05 … FR-08 |
| OBJ-02 | Provide ML-based PCOS risk screening (screening, not diagnosis) | FR-09, FR-10 |
| OBJ-03 | Provide contraceptive eligibility guidance per WHO MEC | FR-11 … FR-13 |
| OBJ-04 | Provide supportive, non-diagnostic AI check-in with crisis handling | FR-14 … FR-17 |
| OBJ-05 | Consolidate all health data into one synced cross-device diary | FR-18, FR-19 |
| OBJ-06 | Make the AI usable by Urdu-speaking users | FR-22 |
| OBJ-07 | Allow users to bring in outside material (lab reports, documents) | FR-23, FR-24 |

---

## 4. Target Users and Roles

### 4.1 Users
- **Primary:** Women of reproductive age seeking cycle tracking and reproductive-health information.
- **Secondary:** Users evaluating contraceptive options wanting a quick eligibility reference before consulting a provider.
- **Tertiary:** Urdu-first speakers who cannot comfortably use an English-only health app.

### 4.2 Roles
| Role | Description | Capabilities |
|---|---|---|
| Registered User | Email/password account with a server-issued `user_id` and session token | All features; cross-device sync |
| Local-only User | A device where a profile cache exists but no valid session | Read/write local cache only; **no** backend calls, no sync |

There is **no** admin or clinician role. There is no mechanism for any user to view another user's data.

---

## 5. Functional Requirements

### 5.1 Authentication & Accounts

| ID | Requirement | Implementation |
|---|---|---|
| FR-01 | The system shall allow account creation with name, email, and password. Password minimum length: **6 characters**. Email is normalized (trimmed, lowercased) before storage and comparison. | `POST /signup`; `sign_up_screen.dart` |
| FR-01a | Signup shall return `{name, user_id, token, expires_at}`. `user_id` is a 32-hex-char value from `secrets.token_hex(16)`. | `main_flask.py::signup` |
| FR-01b | Attempting to sign up with an email that already exists shall return **409** with a message directing the user to sign in. | `main_flask.py::signup` |
| FR-01c | Signup shall be rate limited to **5 attempts per 600 seconds** per client IP. Exceeding returns **429**. | `auth_utils.check_rate_limit` |
| FR-02 | The system shall allow sign-in with email and password, returning `{name, user_id, token, expires_at}`. | `POST /signin`; `sign_in_screen.dart` |
| FR-02a | Sign-in shall be rate limited to **8 attempts per 300 seconds**, keyed per `(IP, email)` pair. A successful sign-in clears that key's counter. | `auth_utils` |
| FR-03 | The system shall allow a password reset given `{email, new_password}`. | `POST /reset_password`; `forgot_password_screen.dart` |
| FR-03a | Password reset shall return an identical generic `{"status":"ok"}` whether or not the email exists, preventing account enumeration. | `main_flask.py::reset_password` |
| FR-03b | A successful password reset shall invalidate **all** existing sessions for that account, forcing re-authentication everywhere. | `invalidate_all_sessions_for_account` |
| FR-03c | Password reset shall be rate limited to **5 attempts per 900 seconds** per `(IP, email)`. | `auth_utils` |
| FR-03d | **[KNOWN LIMITATION]** With no email-verification step, reset cannot confirm the caller owns the account. Rate limiting is the only mitigation. A production fix requires an emailed one-time code or link. | documented in `main_flask.py` |
| FR-04 | *(Revised from v1.0)* The system shall require a signed-in account for all cloud-backed features. A locally generated anonymous device ID shall exist **only** as a fallback identifier for the on-device cache when no session is present; it shall never be used to authenticate against the backend. | `health_profile_service.dart::getDeviceId` |
| FR-04a | The device ID shall be a UUID-v4-shaped string generated from `Random.secure()`, persisted under SharedPreferences key `health_profile_device_id`. | same |
| FR-05 | The system shall allow logout, invalidating the server-side session on a best-effort basis and always clearing local state regardless of server response. | `POST /logout`; `cycle_provider.dart::logout` |
| FR-06 | Sessions shall expire **30 days** after issue (`SESSION_TTL_DAYS = 30`). | `auth_utils` |
| FR-07 | The client shall persist `authToken` and `accountUserId` in SharedPreferences and attach `Authorization: Bearer <token>` to every request touching personal data. | `cycle_provider.dart`, all services |

### 5.2 Cycle Tracking

| ID | Requirement | Implementation |
|---|---|---|
| FR-08 | The system shall record last period start date, average cycle length (default **28** days), and period duration (default **5** days). | `CycleData`; `cycle_data_screen.dart` |
| FR-09 | The system shall compute the current cycle day as `((today − lastPeriodStart).inDays % cycleLength) + 1`, 1-based. | `CycleData.getCurrentCycleDay()` |
| FR-10 | The system shall derive a phase label: **Menstrual** (day ≤ periodDuration), **Follicular** (day ≤ floor(cycleLength/2)), **Ovulation** (day ≤ floor(cycleLength/2)+2), **Luteal** (otherwise). | `CycleData.getPhase()` |
| FR-11 | The system shall compute days until next period as `cycleLength − currentDay + 1`. | `CycleData.daysUntilNextPeriod()` |
| FR-12 | The system shall estimate the fertile window and ovulation day from cycle data and display them. | `ovulation_screen.dart` |
| FR-13 | The system shall allow per-day logging of: period-day flag, mood, symptom list, and flow intensity. | `DailyLog`; `month_calendar.dart` |
| FR-14 | Cycle data and daily logs shall persist locally via SharedPreferences and survive app restart. | `cycle_provider.dart::_saveCycleData`, `_saveDailyLogs` |
| FR-15 | The system shall provide a month calendar view supporting date selection and visual indication of logged days. | `month_calendar.dart` |
| FR-16 | The system shall support a reminders on/off toggle, persisted locally. | `cycle_provider.dart::toggleReminders` |

### 5.3 PCOS Screening

| ID | Requirement | Implementation |
|---|---|---|
| FR-17 | The system shall accept exactly **22** clinical/lifestyle fields and return `{prediction, pcos_probability, model_used}`. | `POST /predict` |
| FR-17a | The 22 required field keys are: `age_yrs, weight_kg, height_cm, cycle_regularity, cycle_length_days, prl, vit_d3, prg, rbs, bp_systolic, bp_diastolic, follicle_no_l, follicle_no_r, avg_f_size_l, avg_f_size_r, endometrium, weight_gain, hair_growth, skin_darkening, hair_loss, pimples, fast_food, regular_exercise`. | `REQUIRED_FIELDS` |
| FR-17b | BMI shall be **derived server-side** as `weight_kg / (height_cm/100)²` — it is a model feature but is never sent by the client. | `build_feature_vector` |
| FR-17c | Features shall be assembled in the exact order given by `model_metadata.json::feature_order` (22 entries, BMI at index 1), then scaled with the persisted scaler before prediction. | same |
| FR-17d | `cycle_regularity` shall encode as Regular→**2**, Irregular→**4** (not 0/1 — this matches the training dataset's encoding). | `CYCLE_ENCODING` |
| FR-17e | All Yes/No fields shall encode via `BINARY_ENCODING` (Yes→1, No→0), case-insensitively via `.capitalize()`. | `encode_binary` |
| FR-17f | Missing fields shall return **422** naming every missing field. Invalid categorical values shall return **422** naming the offending field and the value received. | `predict()` |
| FR-17g | Model/library exceptions shall return a **500** with a generic user-facing message; internal details shall never be leaked in the response. | `predict()` |
| FR-18 | The system shall report which trained model produced the prediction (`model_metadata.json::model_name` — currently **RandomForest**, calibrated). | `/predict` response |
| FR-19 | Prediction output labels shall be exactly `"PCOS Detected"` / `"No PCOS Detected"`; probability shall be the class-1 probability rounded to 4 decimals. | `predict()` |
| FR-20 | Each completed PCOS check shall be appended to `pcosHistory` in the user's profile with date, prediction, probability, and model name. | `appendPcosResult` |
| FR-21 | **[BUG — MUST FIX]** The PCOS form collects age, weight, height, cycle regularity, and cycle length, but `_runDetection()` currently saves **only** the result — never these input values. Consequently `Demographics` and parts of `ReproductiveHistory` remain permanently "Not set" in the Profile view no matter how many checks are run. The form's inputs **shall** be written back to `profile.demographics` and `profile.reproductiveHistory` on each successful run. | `pcos_screen.dart::_runDetection` |
| FR-22 | The PCOS form shall pre-populate age/weight/height from the stored profile when those fields are empty and profile values exist. | `pcos_screen.dart` (lines ~82–93) |

### 5.4 Contraceptive Eligibility

| ID | Requirement | Implementation |
|---|---|---|
| FR-23 | The system shall expose the selectable condition list (**60** conditions, each `{id, label}`). | `GET /conditions` |
| FR-24 | The system shall expose the **9** WHO-modeled methods: Combined hormonal contraceptives (`chc`), Progestogen-only pills (`pop`), Progestogen-only injectables (`inj`), Implants (`imp`), Levonorgestrel IUD (`lng_iud`), Copper IUD (`cu_iud`), Barrier methods (`barrier`), Lactational amenorrhoea method (`lam`), Female sterilization (`sterilization`). | `GET /methods_reference` |
| FR-25 | The system shall expose typical-use failure rates for **14** methods with practical usage notes. This list is distinct from the 9-method eligibility list and includes methods not in it (Vasectomy, Patch & ring, Male/Female condom, Withdrawal, Fertility awareness, Spermicides, Diaphragm). | `GET /effectiveness` |
| FR-26 | Given selected condition IDs, the system shall return a category (1–4) for each of the 9 methods. | `POST /eligibility` |
| FR-26a | Where multiple conditions are selected, the returned category per method shall be the **most restrictive (numerically highest)** across all selected conditions — the standard clinical approach for multiple comorbidities. Default when a condition has no entry for a method: **1**. | `check_eligibility` |
| FR-26b | Category semantics: **1** = use in any circumstance; **2** = generally use; **3** = use with caution / not usually recommended unless no better option; **4** = should not be used. | documented in `main_flask.py` |
| FR-27 | Requests containing unrecognized condition IDs shall return **422** naming every unknown ID. | `check_eligibility` |
| FR-28 | Each completed eligibility check shall be appended to `eligibilityHistory` with date, the conditions selected, and the per-method results. | `appendEligibilityCheck` |
| FR-29 | The user shall be able to record a current contraception method, appended to `contraceptionHistory` with date and optional note. | `ContraceptionLogEntry`; `protection_screen.dart` |

### 5.5 AI Check-In

| ID | Requirement | Implementation |
|---|---|---|
| FR-30 | The system shall provide a conversational AI check-in covering lifestyle, mood, sleep, stress, and reproductive health. | `POST /chat`; `ai_checkin_screen.dart` |
| FR-31 | The AI shall use the Groq Chat Completions API (OpenAI-compatible shape), model `openai/gpt-oss-120b`, `max_tokens=800`. | `chat_api.py` |
| FR-31a | The model **must** support tool/function calling. If the model is changed, the replacement must also support tools (verify via Groq's `/models` endpoint, `supported_features` includes `tools`). The previous model `llama-3.3-70b-versatile` is no longer available on this account. | `chat_api.py` |
| FR-32 | The API key shall be read from environment variable `GROQ_API_KEY` and never hardcoded. Absence shall produce a clear **500** with setup instructions. | `_get_client()` |
| FR-32a | On PythonAnywhere (no env-var UI), the key shall be set in the WSGI file via `os.environ["GROQ_API_KEY"] = ...` before importing the app. | documented |
| FR-33 | The AI shall reply conversationally in 2–4 sentences, asking **one** question at a time. | `SYSTEM_PROMPT` rule 3 |
| FR-34 | The AI shall call the `record_checkin_insights` tool when — and only when — concrete structured signal is available, returning any of: `lifestyle{regular_exercise, exercise_frequency, diet_quality, fast_food_frequent, average_sleep_hours}`, `mental_health{self_reported_stress_level (1–5), notes}`, `reproductive_history{cycle_regularity, cycle_length_days}`, plus `suggested_tab`, `suggested_tab_reason`, `crisis_concern`. | `INSIGHTS_TOOL` |
| FR-35 | `suggested_tab` shall be restricted to `"pcos"` or `"protection"` and set only where a genuine, specific reason exists tied to what the user said. | `SYSTEM_PROMPT` rule 6 |
| FR-36 | **Empty-reply mitigation:** when the model returns a tool call with empty `message.content`, the backend shall issue a **follow-up completion** (replaying the assistant tool-call turn plus a `role:"tool"` result) so the user never sees a blank bubble. If that follow-up itself fails, a short fallback acknowledgement shall be returned. | `chat_api.py` |
| FR-37 | Conversation history shall be sent from the client as `[{role, message}]` and converted server-side to OpenAI message format, with the system prompt prepended as the first message. | `_history_to_messages` |
| FR-38 | Each user and assistant turn shall be appended to the profile's `conversationLog` with timestamp, role, message, and session ID. | `appendConversationEntry` |
| FR-39 | The user shall be able to start a new chat session (new `sessionId`) and browse prior sessions from history. | `ai_checkin_screen.dart::_startNewChat`, `_openHistory` |
| FR-40 | When `privacySettings.aiMemoryEnabled` is false, prior history shall **not** be sent to the model; the conversation shall start fresh each turn. | `ai_checkin_screen.dart` |
| FR-41 | The `/chat` endpoint shall require authentication (`@require_auth`), preventing anonymous consumption of the API key quota. | `chat_api.py` |

### 5.6 Bilingual Support (English / Urdu)

| ID | Requirement | Implementation |
|---|---|---|
| FR-42 | The chat screen shall provide a language toggle in the header, displaying `EN` or `اردو` with a translate icon. | `ai_checkin_screen.dart::_toggleLanguage` |
| FR-43 | The selected language shall persist across app restarts under SharedPreferences key `ai_checkin_language`. | same |
| FR-44 | The client shall send `language: "en" \| "ur"` in the `/chat` request body. | `ai_service.dart::sendMessage` |
| FR-45 | When `language == "ur"`, the backend shall append an instruction to the system prompt directing the model to reply in natural, warm, conversational Urdu **for the entire conversation, regardless of the language the user writes in**, unless the user explicitly asks to switch back to English. | `_language_instruction` |
| FR-46 | When Urdu is selected, the message input field shall render right-to-left and display an Urdu placeholder (`سہیلی کو پیغام بھیجیں…`). | `_inputBar()` |
| FR-47 | Language switching shall require no app restart and shall not clear the existing conversation. | by design |
| FR-48 | **[NOT IMPLEMENTED]** Urdu localisation of the remaining 17 screens (labels, buttons, educational content). Only the AI chat is bilingual today. | — |

### 5.7 Voice Input

| ID | Requirement | Implementation |
|---|---|---|
| FR-49 | The chat screen shall provide a microphone button performing live speech-to-text into the message field. | `speech_to_text: ^7.0.0` |
| FR-50 | Recognition locale shall follow the language toggle: `ur_PK` when Urdu, `en_US` when English. | `_toggleListening` |
| FR-51 | Recognized words shall stream into the text field as the user speaks, with the caret kept at the end; the user reviews and edits before sending. Voice shall **not** auto-send. | same |
| FR-52 | While listening, the mic icon shall change to a filled state in the alert colour and the placeholder shall read "Listening…". | `_inputBar()` |
| FR-53 | Availability shall be checked at init; if unsupported (non-Chromium browser), tapping shall show a clear message rather than failing silently. | `_initSpeech` |
| FR-54 | Recognition errors and status changes (`done`, `notListening`) shall reset the listening state and surface the error text. | same |
| FR-55 | Any active recognition shall be stopped in `dispose()`. | same |

### 5.8 Attachments

| ID | Requirement | Implementation |
|---|---|---|
| FR-56 | The chat screen's "+" button shall open a file picker restricted to: `png, jpg, jpeg, gif, webp, pdf, doc, docx, txt`. | `file_picker: ^8.1.2` |
| FR-57 | Files shall be read with `withData: true` (required for web) and rejected with a clear message if bytes are unreadable. | `_pickAttachment` |
| FR-58 | Attachments shall be limited to **8 MB**; larger files shall be rejected by name with a clear message. | same |
| FR-59 | A staged attachment shall render as a removable chip above the input bar, with a distinct icon for images vs documents, before it is sent. | `_attachmentChip` |
| FR-60 | The attachment shall be transmitted as `attachment: {file_name, mime_type, data_base64}` in the `/chat` body. | `ChatAttachment.toJson` |
| FR-61 | A message may consist of an attachment with no text; in that case the chat bubble shall display `📎 <filename>` and the model shall receive `"(no text, see attachment)"`. | `_sendMessage` |
| FR-62 | The backend shall extract text from PDFs via `pypdf` and from `.doc/.docx` via `python-docx`, truncated to **6000 characters** (`MAX_ATTACHMENT_CHARS`). | `_extract_attachment_text` |
| FR-63 | Plain-text and unknown types shall be UTF-8 decoded; undecodable content shall be reported as an unsupported format rather than raising. | same |
| FR-64 | Extraction libraries shall be imported inside `try/except ImportError`, so a missing dependency degrades to a helpful message rather than a 500 on every chat request. | `chat_api.py` top |
| FR-65 | **Images:** the current model is text-only and cannot read image pixels. The backend shall pass a note instructing the assistant to acknowledge receipt honestly and ask the user to describe the image, rather than hallucinating contents. | `_extract_attachment_text` |
| FR-66 | Extracted content shall be folded into the **same** user turn as the typed message (not a separate message), preserving conversational coherence. | `chat()` |
| FR-67 | **[FUTURE]** Real image understanding requires switching to a vision-capable Groq model (e.g. a `llama-3.2-*-vision` variant) and sending image content blocks instead of the text note. | — |

### 5.9 Input Ergonomics

| ID | Requirement | Implementation |
|---|---|---|
| FR-68 | Pressing **Enter** on a physical keyboard shall send the message. | `_handleKey` |
| FR-69 | Pressing **Shift+Enter** shall insert a newline instead of sending. | same |
| FR-70 | The input field shall auto-grow between **1 and 4** lines. | `_inputBar()` |
| FR-71 | While a send is in flight, the send button shall be replaced by a progress indicator and further sends shall be blocked. | `_sending` guard |

### 5.10 Health Diary & Profile

| ID | Requirement | Implementation |
|---|---|---|
| FR-72 | The system shall persist a full `HealthProfile` server-side as a single JSON document keyed by `user_id`. | `PUT /profile/<user_id>` |
| FR-73 | The profile payload shall be capped at **300,000 bytes**; larger payloads return **413**. | `MAX_PROFILE_BYTES` |
| FR-74 | A `user_id` present in the body that contradicts the URL shall return **422**. The URL is authoritative and is force-written into the stored body. | `save_profile` |
| FR-75 | GET on a user with no stored profile shall return **404**, and the client shall fall back to a blank local profile rather than erroring. | `get_profile`, `loadProfile` |
| FR-76 | Saves shall be **upserts** (`ON CONFLICT DO UPDATE`), replacing the whole document — partial-merge logic lives client-side in `updateProfile()`. | `save_profile` |
| FR-77 | **Load order shall be local-cache-first.** The local cache is authoritative for "what this device just did"; the backend is fetched in the background only to pick up changes from other devices. | `loadProfile` |
| FR-78 | A backend copy shall be adopted **only** if `remote.lastUpdated.isAfter(local.lastUpdated)`. A stale server record must never clobber a fresher local one. (This guards the historical bug where a PCOS result saved seconds earlier vanished on reopening the Diary.) | `_refreshFromBackendIfNewer` |
| FR-79 | Saves shall write to local cache **immediately** and push to the backend in the background; UI shall never block on the network. A failed push shall leave the local cache correct and retry on the next save/load. | `saveProfile` |
| FR-80 | All profile access shall route through `HealthProfileService` — screens shall not call the backend directly. | architectural rule |
| FR-81 | The system shall present a unified, reverse-chronological timeline merging PCOS results, contraception changes, eligibility checks, cycle logs, and AI conversations. | `health_diary_screen.dart` |
| FR-82 | The diary shall show summary counts (PCOS checks, methods logged, cycle entries, AI check-ins) and a Timeline/Profile tab switch. | same |
| FR-83 | The Profile tab shall display four sections — Demographics, Lifestyle, Reproductive Health, Wellbeing — showing "Not set" for null values, plus a "Last updated" line. | `_buildProfileTab` |
| FR-84 | **[GAP]** The Profile tab is **read-only**. There is no screen anywhere in the app that lets a user directly edit demographics, lifestyle, or wellbeing fields. These can currently be populated only indirectly (AI tool calls, and — once FR-21 is fixed — the PCOS form). A direct profile-edit screen **shall** be added. | — |
| FR-85 | The system shall support free-text diary entries with date, optional mood, symptom tags, and body text. | `DiaryEntry`, `diary_entry_dialog.dart` |
| FR-86 | The user shall be able to delete their entire stored profile. | `DELETE /profile/<user_id>` |

### 5.11 Settings, Privacy, Content

| ID | Requirement | Implementation |
|---|---|---|
| FR-87 | The user shall be able to edit display name, cycle data, and privacy settings. | `settings_screen.dart` |
| FR-88 | Privacy settings shall include `aiMemoryEnabled` (whether prior turns are sent to the model) and `aiCanAccessDiary` (whether diary content may be used as context). | `PrivacySettings` |
| FR-89 | The system shall provide educational content on reproductive anatomy, hormones, and menstruation. | `learn_screen.dart` |
| FR-90 | The system shall provide dedicated endometriosis information. | `endo_screen.dart` |
| FR-91 | The system shall provide About and Terms screens. | `about_screen.dart`, `terms_screen.dart` |
| FR-92 | The system shall provide a data & privacy screen explaining what is stored and where. | `data_privacy_screen.dart` |
| FR-93 | The app shell shall present 8 tabs — Cycle, Ovu, Prot, PCOS, Endo, Learn, Set, Chat — via an `IndexedStack` preserving each tab's state across switches. | `home_shell.dart` |
| FR-94 | Tab content shall be constrained to a max width of **640 px** and centred, for readable layout on wide screens. | same |
| FR-95 | **[FIXED]** The tab content area shall be given an explicit bounded height via `LayoutBuilder` rather than relying on ambient constraints, which could silently collapse to zero height and render a blank screen with no error. | `home_shell.dart` |

---

## 6. Non-Functional Requirements

| ID | Requirement | Notes |
|---|---|---|
| NFR-01 | Passwords shall be hashed before storage using Werkzeug's `generate_password_hash` (PBKDF2-SHA256 by default). Plain-text passwords shall never be stored or logged. *(Note: v1.0 said bcrypt; the implementation uses Werkzeug's PBKDF2. Either is acceptable; the doc is corrected to match reality.)* | `main_flask.py` |
| NFR-02 | PCOS prediction shall return in under **1 second** once the request reaches the backend (model and scaler are loaded once at import, not per request). | `main_flask.py` module level |
| NFR-03 | The AI check-in shall degrade gracefully with a clear message if Groq is unreachable or unconfigured. Upstream failures return **502** with a readable detail. | `chat()` |
| NFR-04 | All backend input shall be validated, returning specific 4xx errors naming the invalid field rather than unhandled 500s. | throughout |
| NFR-05 | The system shall run on Android, iOS, and web from a single Flutter codebase. | — |
| NFR-06 | The backend shall run on commodity/low-cost hosting — SQLite only, no external DB server. | — |
| NFR-07 | No API keys or credentials shall be committed to version control. `.gitignore` shall exclude `*.db` and the virtualenv. | `.gitignore` |
| NFR-08 | Chat requests shall time out client-side at **30 seconds**; profile requests at **8 seconds**. | `ai_service.dart`, `health_profile_service.dart` |
| NFR-09 | CORS shall allow all origins, methods, and headers. `Access-Control-Allow-Credentials` shall **not** be set — auth is a Bearer token, not a cookie, so there is no CSRF surface that flag would guard. | `add_cors_headers` |
| NFR-10 | Every mutating endpoint shall handle the CORS preflight `OPTIONS` method, returning **204**. | throughout |
| NFR-11 | The app shall function offline for cycle tracking and diary reading; cloud features degrade with clear messaging. | local-cache-first design |
| NFR-12 | SQLite connections shall be opened per request and closed in `finally` blocks to avoid exhausting the free tier's file handles. | throughout |
| NFR-13 | Background sync failures shall be silent and non-blocking — never surfaced as errors that interrupt the user. | `_refreshFromBackendIfNewer` |

---

## 7. System Features (Screen Inventory)

| Screen | File | Purpose |
|---|---|---|
| Splash | `splash_screen.dart` | Session restore; routes to sign-in or home |
| Sign In | `sign_in_screen.dart` | Email/password authentication |
| Sign Up | `sign_up_screen.dart` | Account creation |
| Forgot Password | `forgot_password_screen.dart` | Password reset |
| Home Shell | `home_shell.dart` | 8-tab `IndexedStack` container + bottom nav |
| Home / Cycle | `home_screen.dart` | Cycle day, phase, calendar, logging |
| Cycle Data | `cycle_data_screen.dart` | Edit period start, cycle length, duration |
| Ovulation | `ovulation_screen.dart` | Fertile window and ovulation estimate |
| Protection | `protection_screen.dart` | Methods, effectiveness, eligibility tool, My Plan |
| PCOS | `pcos_screen.dart` | 22-field screening form and result |
| Endometriosis | `endo_screen.dart` | Educational content |
| Learn | `learn_screen.dart` | Anatomy, hormones, menstruation content |
| Settings | `settings_screen.dart` | Name, cycle, privacy, logout |
| AI Check-In | `ai_checkin_screen.dart` | Bilingual chat, voice, attachments, history |
| Health Diary | `health_diary_screen.dart` | Timeline + read-only profile |
| Data & Privacy | `data_privacy_screen.dart` | Storage disclosure |
| About | `about_screen.dart` | App info |
| Terms | `terms_screen.dart` | Terms of use |

**Reusable widgets:** `ai_suggestion_card`, `ai_welcome_card`, `app_text_field`, `diary_entry_dialog`, `gradient_card`, `month_calendar`, `pill_button`, `wellness_check_in_dialog`.
*(Housekeeping: `app_text_field (1).dart` is a duplicate file and should be deleted. `lib/services/auth_session.dart` is dead code — nothing imports it since the migration to direct SharedPreferences reads.)*

---

## 8. AI Safety Requirements

| ID | Requirement |
|---|---|
| AI-01 | The AI shall never issue a diagnosis, physical or mental. It shall never say "you have X" or "this means you have X." Permitted framing: "some of what you're describing is worth checking with the PCOS tool." |
| AI-02 | The AI shall never provide medication dosages, tell a user to start or stop a medication, or give treatment directives. It shall redirect to a healthcare provider. |
| AI-03 | On disclosure suggesting emotional distress, self-harm risk, or an unsafe situation (e.g. family violence), the AI shall remain calm and supportive, shall not attempt to solve it, and shall set `crisis_concern: true` so the app can surface real crisis resources — while continuing to engage supportively in text rather than going silent. |
| AI-04 | The AI provider shall be configurable via environment variable, never hardcoded. |
| AI-05 | The AI shall ask one question at a time and keep replies to 2–4 sentences. |
| AI-06 | The AI shall never make the user feel screened or judged; the register is a caring, knowledgeable friend. |
| AI-07 | The AI shall not claim to have seen an image it cannot process (see FR-65). |
| AI-08 | **[GAP vs v1.0]** v1.0 required crisis detection to be *deterministic and keyword-based, independent of AI model behaviour* (AI-03 in v1.0), and separately required distinguishing physical medical emergencies from psychological crisis (FR-16 in v1.0). **Neither exists in the current code** — crisis detection is entirely model-driven via the `crisis_concern` tool field. A deterministic keyword pre-filter, running before and independently of the model call, **shall** be added, along with a distinct physical-emergency path. |
| AI-09 | **[GAP vs v1.0]** v1.0 FR-17 required a fallback reply when no AI key is configured. Currently a missing key returns a **500 error**, not a graceful fallback message. A user-facing fallback **shall** be implemented. |

---

## 9. Data Model Specification

### 9.1 `HealthProfile` (root document)
| Field | Type | Notes |
|---|---|---|
| `userId` | String | Account `user_id`, or device ID in local-only mode |
| `demographics` | Demographics | |
| `lifestyle` | Lifestyle | |
| `reproductiveHistory` | ReproductiveHistory | |
| `pcosHistory` | List\<PcosCheckResult\> | Append-only |
| `eligibilityHistory` | List\<EligibilityCheckResult\> | Append-only |
| `mentalHealth` | MentalHealthFlags | |
| `conversationLog` | List\<ConversationEntry\> | Append-only |
| `privacySettings` | PrivacySettings | |
| `diaryEntries` | List\<DiaryEntry\> | |
| `lastUpdated` | DateTime | Drives sync conflict resolution (FR-78) |

### 9.2 Sub-objects
| Class | Fields |
|---|---|
| `Demographics` | `ageYrs: int?`, `weightKg: double?`, `heightCm: double?`, `maritalStatus: String?` |
| `Lifestyle` | `regularExercise: bool?`, `exerciseFrequency: String?`, `dietQuality: String?`, `fastFoodFrequent: bool?`, `averageSleepHours: double?`, `notes: String?` |
| `ReproductiveHistory` | `cycleRegularity: String?` ('Regular'/'Irregular'), `cycleLengthDays: int?`, `currentContraceptionMethod: String?`, `contraceptionHistory: List<ContraceptionLogEntry>` |
| `ContraceptionLogEntry` | `date: DateTime`, `method: String`, `note: String?` |
| `PcosCheckResult` | `date: DateTime`, `prediction: String`, `pcosProbability: double`, `modelUsed: String` |
| `EligibilityResultEntry` | `methodLabel: String`, `category: int` |
| `EligibilityCheckResult` | `date: DateTime`, `conditions: List<String>`, `results: List<EligibilityResultEntry>` |
| `MentalHealthFlags` | `selfReportedStressLevel: int?` (1–5), `notes: String?`, `lastCheckIn: DateTime?` |
| `ConversationEntry` | `timestamp: DateTime`, `role: String` ('user'/'assistant'), `message: String`, `sessionId: String?` |
| `PrivacySettings` | `aiMemoryEnabled: bool`, `aiCanAccessDiary: bool` |
| `DiaryEntry` | `date: DateTime`, `mood: String?`, `symptomTags: List<String>`, `text: String` |
| `CycleData` | `lastPeriodStart: DateTime`, `cycleLength: int` (default 28), `periodDuration: int` (default 5) |
| `DailyLog` | `isPeriodDay: bool`, `mood: String?`, `symptoms: List<String>`, `flowIntensity: String?` |

**Design note:** every sub-object implements `copyWith`, `toJson`, and `fromJson`. All `copyWith` methods use `value ?? this.value`, which means **a field cannot be set back to null via copyWith** — a known constraint to be aware of when implementing profile editing (FR-84).

---

## 10. Database Requirements

Three separate SQLite files:

| DB | Path | Table | Schema |
|---|---|---|---|
| Accounts | `accounts.db` | `accounts` | `email TEXT PRIMARY KEY`, `password_hash TEXT NOT NULL`, `name TEXT NOT NULL`, `user_id TEXT` |
| Sessions | (via `auth_utils`) | `sessions` | token, account_user_id, expires_at |
| Profiles | `app_deployment/health_profiles.db` | `health_profiles` | `user_id TEXT PRIMARY KEY`, `profile_json TEXT NOT NULL`, `updated_at TEXT NOT NULL` |

| ID | Requirement |
|---|---|
| DB-01 | Tables shall be created on import via `CREATE TABLE IF NOT EXISTS` — no separate migration step. |
| DB-02 | Health profiles shall be stored as a **single JSON document per user_id**, deliberately schema-light so new Dart model fields need no migration. |
| DB-03 | SQLite shall be the engine. |
| DB-04 | The `accounts` table shall self-migrate: if `user_id` is absent, `ALTER TABLE` adds it and every pre-existing row is backfilled with `secrets.token_hex(16)`, so accounts created before sessions existed can still sign in. |
| DB-05 | Should server-side querying of profile contents ever be needed (e.g. "all users flagged high PCOS risk"), real columns shall be introduced **at that point** — not pre-emptively. |
| DB-06 | `timestamps` shall be stored as ISO-8601 UTC strings. |

---

## 11. Security Requirements

| ID | Requirement | Status |
|---|---|---|
| SEC-01 | Passwords hashed before storage (Werkzeug PBKDF2). | ✅ |
| SEC-02 | Sign-in shall return an identical error for unknown email and wrong password, preventing enumeration. | ✅ |
| SEC-03 | Password reset shall return an identical generic response regardless of email existence. | ✅ |
| SEC-04 | No secrets or `.db` files committed to git. | ✅ |
| SEC-05 | `/profile/<user_id>` GET, PUT, DELETE shall require a valid Bearer token **and** verify token ownership matches the URL's `user_id`, returning **403** on mismatch. *(This was the documented gap in v1.0 — now closed.)* | ✅ |
| SEC-06 | `/chat` shall require authentication. | ✅ |
| SEC-07 | Sessions shall expire after 30 days and be individually invalidatable. | ✅ |
| SEC-08 | Password reset shall invalidate all sessions for that account. | ✅ |
| SEC-09 | Rate limiting on signup, signin, and reset. | ✅ |
| SEC-10 | Prediction errors shall not leak model or library internals. | ✅ |
| SEC-11 | Profile payload size capped to prevent storage abuse. | ✅ |
| SEC-12 | **[OPEN]** Password reset has no ownership proof (no emailed code/link). Rate limiting only. | ⚠️ |
| SEC-13 | **[OPEN]** Rate limiting is in-process and keyed by `request.remote_addr`; it resets on worker restart and is defeatable behind shared NAT or by rotating IPs. | ⚠️ |
| SEC-14 | **[OPEN]** `/predict`, `/eligibility`, `/conditions`, `/methods_reference`, `/effectiveness` are unauthenticated. Acceptable for reference data; `/predict` consumes CPU and may warrant auth. | ⚠️ |
| SEC-15 | **[OPEN]** Attachments are accepted by declared MIME type without content sniffing or malware scanning. | ⚠️ |
| SEC-16 | **[REVIEW]** Health disclosures (mental health, reproductive health) are transmitted to a third-party AI provider. Groq's terms must be reviewed before any real-world deployment, and users must be told in the privacy screen. | ⚠️ |

---

## 12. Hardware Requirements
- **Client:** any Android or iOS device, or a modern browser (Chromium-based recommended — voice input depends on the Web Speech API, unavailable in some browsers).
- **Server:** any host running Python 3.10+. Tested on PythonAnywhere free tier.

---

## 13. Software Requirements

### 13.1 Frontend
Flutter SDK (stable), Dart. Packages: `provider ^6.1.5+1`, `shared_preferences ^2.5.5`, `google_fonts ^8.1.0`, `http ^1.1.0`, `speech_to_text ^7.0.0`, `file_picker ^8.1.2`.

### 13.2 Backend
Python 3.10+, Flask ≥3.0.0, Werkzeug (transitive, used for password hashing), `groq` ≥0.11.0, `scikit-learn` ≥1.3.0, `joblib` ≥1.3.0, `numpy` ≥1.24.0, `pypdf` ≥4.0.0, `python-docx` ≥1.1.0, SQLite (stdlib).

### 13.3 Deployment topology
WSGI entry point → `main_flask.py::app`, which registers `health_profile_bp` and `chat_bp`. `GROQ_API_KEY` is set in the WSGI file. Both blueprint files must sit in the same folder as `main_flask.py` (flat imports — there is no `app_backend` package in use).

**Deployment hazard (observed):** editing files locally or on GitHub does **not** update the server. Files must be uploaded to PythonAnywhere and the web app reloaded. Verify a deploy with `wc -l <file>` rather than assuming.

---

## 14. Constraints
1. PythonAnywhere free tier: 512 MB disk, limited CPU seconds. Training-only libraries must not be installed in the deployed environment; only the serialized model artifacts ship.
2. Groq free tier chosen over paid providers due to credit-balance limits encountered in development; it is rate-limited by usage.
3. Free tier permits no ASGI — hence Flask rather than FastAPI.
4. The current Groq model is text-only; image understanding is out of reach without a model change.
5. Voice input on web depends on the browser's Web Speech API — unavailable in some browsers.
6. `copyWith` cannot null out a field (see §9.2 note).

---

## 15. Assumptions
1. Users are literate in English or Urdu.
2. Users have internet access for prediction, chat, eligibility, and sync; cycle tracking and diary reading work offline.
3. Users understand this is a screening and information tool, not a clinician.
4. Lab values entered into the PCOS form come from an actual lab report — the app cannot validate them.

---

## 16. Out of Scope
- Clinical diagnosis of any condition.
- Telemedicine or direct provider consultation.
- Payment processing.
- Languages beyond English and Urdu.
- Admin or clinician dashboards.
- Data export (no CSV/PDF export exists).
- Push notifications (the reminders toggle stores a preference but no notification system is wired up).
- Wearable or health-platform integration.

---

## 17. Acceptance Criteria

| ID | Traces to | Criterion |
|---|---|---|
| AC-01 | FR-01, FR-02 | A user can register and subsequently sign in with the same credentials, receiving a token both times. |
| AC-02 | FR-01b | Registering an existing email returns 409, not a duplicate account. |
| AC-03 | FR-02a | Nine consecutive failed sign-ins from one IP for one email return 429. |
| AC-04 | FR-03b | After a password reset, a previously issued token is rejected. |
| AC-05 | FR-17 | Submitting a valid 22-field form returns a prediction label, a probability in [0,1] to 4dp, and the model name "RandomForest". |
| AC-06 | FR-17f | Omitting `prl` returns 422 naming `prl`. Sending `cycle_regularity: "Maybe"` returns 422 naming the field and the value. |
| AC-07 | FR-17b | Two requests with identical inputs except height produce different results, confirming BMI derivation is live. |
| AC-08 | FR-26 | Submitting selected conditions returns a category 1–4 for each of the **9** methods. |
| AC-09 | FR-26a | Selecting both `smoking_35_plus` (chc: 3) and `migraine_with_aura` (chc: 4) returns chc = **4**. |
| AC-10 | FR-27 | Submitting an unknown condition ID returns 422 naming it. |
| AC-11 | FR-72, FR-75 | Data saved via PUT is retrievable via GET for the same `user_id`; a user with no profile gets 404 and the app still opens. |
| AC-12 | SEC-05 | User A's token used against `/profile/<user_B_id>` returns 403 for GET, PUT, and DELETE. |
| AC-13 | FR-78 | With a fresher local profile and a stale server copy, reopening the Diary preserves the local data. |
| AC-14 | FR-45 | With the toggle on اردو, sending "hello how are you" in English produces an **Urdu** reply. |
| AC-15 | FR-43 | The language choice survives a full app restart. |
| AC-16 | FR-62 | Attaching a text-bearing PDF results in a reply that references its actual contents. |
| AC-17 | FR-65 | Attaching a photo produces an acknowledgement asking for a description — never a fabricated reading of the image. |
| AC-18 | FR-58 | A 12 MB file is rejected by name before any network call. |
| AC-19 | FR-68, FR-69 | Enter sends; Shift+Enter inserts a newline. |
| AC-20 | FR-36 | A turn that triggers `record_checkin_insights` still renders a non-empty assistant bubble. |
| AC-21 | AI-03 | A message containing crisis-indicating language returns `crisis_concern: true` **and** the app surfaces real crisis-line resources. |
| AC-22 | FR-21 | After running a PCOS check, the Diary's Profile tab shows the entered age, weight, and height — **not** "Not set". *(Currently failing.)* |
| AC-23 | FR-93 | Switching tabs and returning preserves each tab's scroll position and form state. |
| AC-24 | NFR-02 | `/predict` responds in under 1 second measured server-side. |

---

## 18. Known Defects and Required Work

Ordered by priority. This is the actionable backlog.

### P1 — Data correctness
1. **FR-21 / AC-22 — PCOS form inputs are never persisted.** `_runDetection()` in `pcos_screen.dart` calls `appendPcosResult()` with only the result. Age, weight, height, cycle regularity, and cycle length are discarded, leaving Demographics and Reproductive Health permanently "Not set". Fix: write these back via `HealthProfileService.updateProfile()` in the same success path.
2. **FR-84 — No profile editing UI exists.** Add a screen allowing direct edit of demographics, lifestyle, and wellbeing fields. Note the `copyWith` null constraint (§9.2).

### P2 — Safety gaps vs. stated requirements
3. **AI-08 — Crisis detection is not deterministic.** v1.0 required a keyword-based check independent of model behaviour. Implement a pre-filter that runs before the Groq call and can set `crisis_concern` on its own.
4. **AI-08 — No separate physical-emergency path.** v1.0 FR-16 required distinguishing described physical medical emergencies from psychological crisis.
5. **AI-09 — Missing-key path returns 500, not a graceful fallback.** v1.0 NFR-03/FR-17 required a clear fallback message.

### P3 — Security hardening
6. **SEC-12** — Password reset lacks ownership proof; implement emailed one-time code.
7. **SEC-13** — Move rate limiting to shared, persistent storage.
8. **SEC-15** — Add content sniffing for attachments rather than trusting declared MIME type.
9. **SEC-16** — Disclose third-party AI processing in `data_privacy_screen.dart`.

### P4 — Housekeeping
10. Delete `lib/widgets/app_text_field (1).dart` (duplicate).
11. Delete `lib/services/auth_session.dart` (dead code — no importers).
12. Remove the vestigial `app_backend/` package and the `uvicorn` `Procfile`, or document clearly that they are unused, to stop them misleading readers into thinking the backend is FastAPI.
13. Replace deprecated `withOpacity` calls with `withValues(alpha:)` (present in `health_diary_screen.dart::_profileSection`).

### P5 — Feature completion
14. **FR-48** — Urdu localisation of the remaining 17 screens.
15. **FR-67** — Vision-capable model for real image understanding.
16. Push notifications to back the existing reminders toggle.
17. Data export (CSV/PDF) for the diary.

---

## 19. Traceability Summary

| Objective | Functional requirements | Acceptance criteria |
|---|---|---|
| OBJ-01 Cycle tracking | FR-08 … FR-16 | AC-23 |
| OBJ-02 PCOS screening | FR-17 … FR-22 | AC-05, AC-06, AC-07, AC-22, AC-24 |
| OBJ-03 Contraceptive guidance | FR-23 … FR-29 | AC-08, AC-09, AC-10 |
| OBJ-04 AI check-in | FR-30 … FR-41, AI-01 … AI-09 | AC-20, AC-21 |
| OBJ-05 Unified diary | FR-72 … FR-86 | AC-11, AC-12, AC-13 |
| OBJ-06 Urdu support | FR-42 … FR-48 | AC-14, AC-15 |
| OBJ-07 Attachments | FR-49 … FR-71 | AC-16, AC-17, AC-18, AC-19 |
| Auth & security | FR-01 … FR-07, SEC-01 … SEC-16 | AC-01 … AC-04, AC-12 |