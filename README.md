# 🚗 Driver Onboarding & Approval Web Application

A professional, responsive, multi-step Flutter Web application designed for onboarding delivery/ride-share drivers. Features step-isolated form validation, native file handling, client-side draft auto-saving, phone number OTP verification, and an integrated Admin Approval Dashboard.

🚀 **Live Web Demo:** [https://nigels-projects.github.io/driveronboardingloginscreen/](https://nigels-projects.github.io/driveronboardingloginscreen/)

---

## ✨ Features

- **Multi-Step Onboarding Flow:** Standard 3-step `Stepper` (Personal, Vehicle, Documents) with clean progress indicators.
- **Isolated Step Validation:** Utilizes separate `GlobalKey<FormState>` instances per step to isolate validation errors and prevent hidden form fields from blocking step navigation.
- **SMS / OTP Verification:** Integrated 4-digit OTP modal verification for applicant contact details (`Demo Code: 1234`).
- **Native Document Uploads:** Interoperable file picking (`file_picker`) supporting PDF/PNG/JPG formats with real-time file size calculations in KB.
- **Local State Persistence:** Uses `shared_preferences` to auto-save application drafts locally, preventing data loss on browser refresh.
- **Admin Approval Dashboard:** Built-in review portal to inspect submitted driver profiles and assign status tags (`Pending`, `Approved`, `Rejected`).
- **Material 3 Light/Dark Theme:** Real-time theme toggling using custom `ThemeData` configurations.

---

## 🛠️ Project Structure

```text
lib/
├── models/
│   └── driverapp.dart          # Core Data Model, JSON Serialization & Application Enums
├── screens/
│   ├── onboardingscreen.dart   # Multi-step Form, OTP Modal & Draft Auto-save Logic
│   └── admin_screen.dart       # Admin Approval Dashboard & Persistent Profile Management
└── main.dart                   # Application Entry Point & Material 3 Theme Configuration

🚀 Getting Started
Prerequisites
Flutter SDK (v3.0.0 or higher)

Dart SDK

Google Chrome or any modern Web Browser

Running Locally (In Terminal)
1. Clone the repository:
git clone https://github.com/Nigels-Projects/driveronboardingloginscreen.git
cd driveronboardingloginscreen (run this in bash in a terminal)

2. Install dependencies:
flutter pub get

3. Start local web server:
flutter run -d chrome
