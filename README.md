# 🚀 AI Scrum Master

> Intelligent project analysis and breakdown powered by AI

**AI Scrum Master** is an intelligent project management tool that uses AI to analyze project requirements and automatically generate detailed project breakdowns with milestones, subtasks, and time estimates.

Simply describe your project requirements, and AI will:

- 📅 Break down your project into actionable milestones
- 📝 Create detailed subtasks with time estimates
- 🔧 Identify required APIs and tools
- ⏰ Suggest schedules and reminders
- 💾 Store everything in Firebase for easy access

**Developed by [Kavindu Alwis](https://github.com/kavindualwis)**

---

## 📸 Screenshots & Demo

<div align="center">
  <table>
    <tr>
      <td width="33%">
        <img src="https://github.com/kavindualwis/Ai-Scrum-Automation-Flutter-App-n8n/blob/main/App%20Images/Home%20Screen.png" alt="Home Screen" width="100%">
        <p><b>Home Screen</b></p>
      </td>
      <td width="33%">
        <img src="https://github.com/kavindualwis/Ai-Scrum-Automation-Flutter-App-n8n/blob/main/App%20Images/Milestones%20Screen.png" alt="Milestones View" width="100%">
        <p><b>Milestones View</b></p>
      </td>
      <td width="33%">
        <img src="https://github.com/kavindualwis/Ai-Scrum-Automation-Flutter-App-n8n/blob/main/App%20Images/APi%20Screen%20Tab.png" alt="API View" width="100%">
        <p><b>API View</b></p>
      </td>
    </tr>
    <tr>
      <td width="33%">
        <img src="https://github.com/kavindualwis/Ai-Scrum-Automation-Flutter-App-n8n/blob/main/App%20Images/Analytics%20Screen.png" alt="Analysis Screen" width="100%">
        <p><b>Analysis Screen</b></p>
      </td>
      <td width="33%">
        <img src="https://github.com/kavindualwis/Ai-Scrum-Automation-Flutter-App-n8n/blob/main/App%20Images/Settings%20Screen.png" alt="Settings Screen" width="100%">
        <p><b>Settings Screen</b></p>
      </td>
      <td width="33%">
        <img src="https://github.com/kavindualwis/Ai-Scrum-Automation-Flutter-App-n8n/blob/main/App%20Images/n8n%20Workflow.png" width="100%">
        <p><b>n8n Workflow</b></p>
      </td>
    </tr>
  </table>
</div>

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation & Setup](#installation--setup)
  - [Flutter App Setup](#flutter-app-setup)
  - [Firebase Setup](#firebase-setup)
  - [n8n Workflow Setup](#n8n-workflow-setup)
- [Configuration Guide](#configuration-guide)
  - [Firebase Configuration](#firebase-configuration)
  - [n8n Configuration](#n8n-configuration)
  - [Google Cloud Console Setup](#google-cloud-console-setup)

---

## ✨ Features

- 🤖 **AI-Powered Analysis** - Uses OpenAI GPT-4 to intelligently analyze project requirements
- 🔥 **Firebase Integration** - Cloud database for storing project data
- 🔐 **Secure Authentication** - Firebase Auth for user management
- 📱 **Flutter Cross-Platform** - Works on Android, iOS, Web, and Desktop
- 🔄 **Real-time Sync** - Cloud Firestore for live data synchronization
- 🛠️ **REST API** - n8n workflow for backend processing
- 📊 **Automated Breakdown** - Generate milestones and subtasks automatically

---

## 🛠️ Tech Stack

| Component          | Technology         |
| ------------------ | ------------------ |
| **Frontend**       | Flutter            |
| **Backend**        | n8n Workflow       |
| **Database**       | Firebase Firestore |
| **Authentication** | Firebase Auth      |
| **AI Model**       | OpenAI GPT-4       |
| **API**            | REST API via n8n   |
| **Real-time DB**   | Cloud Firestore    |

---

## 📁 Project Structure

```
ai_scrum/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── firebase_options.dart     # Firebase config (generate with flutterfire)
│   ├── constants/                # App constants
│   ├── models/                   # Data models
│   ├── providers/                # State management (Provider)
│   ├── screens/                  # UI screens
│   ├── services/                 # API & Firebase services
│   ├── utils/                    # Utility functions
│   └── widgets/                  # Reusable widgets
├── android/                      # Android native code
├── ios/                          # iOS native code
├── web/                          # Web platform
├── macos/                        # macOS platform
├── windows/                      # Windows platform
├── linux/                        # Linux platform
├── test/                         # Unit & widget tests
├── pubspec.yaml                  # Flutter dependencies
├── firebase.json                 # Firebase config
└── analysis_options.yaml         # Dart analysis rules
```

---

## 📦 Prerequisites

Before you begin, ensure you have the following installed:

### Required Software

- **Flutter SDK** (v3.9.2 or higher) - [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Dart SDK** (included with Flutter)
- **Git** - [Install Git](https://git-scm.com/)
- **Node.js & npm** - [Install Node.js](https://nodejs.org/)

### Required Accounts

- **Google Account** - For Firebase and Google Cloud
- **OpenAI Account** - For GPT-4 API access
- **n8n Cloud Account** - [n8n Cloud](https://app.n8n.cloud/)

### Required Tools

- **FlutterFire CLI** - For Firebase setup
  ```bash
  dart pub global activate flutterfire_cli
  ```

---

## 🚀 Installation & Setup

### Flutter App Setup

#### 1. Clone the Repository

```bash
git clone https://github.com/kavindualwis/ai_scrum.git
cd ai_scrum
```

#### 2. Get Flutter Dependencies

```bash
flutter pub get
```

#### 3. Configure Firebase

Run the FlutterFire CLI to generate `firebase_options.dart`:

```bash
flutterfire configure
```

Follow the prompts and select:

- Your Firebase project
- Platforms: Android, iOS, Web (choose based on your needs)

This will create `lib/firebase_options.dart` with your Firebase credentials.

#### 4. Run the App

```bash
# For Android
flutter run -d android

# For iOS
flutter run -d ios

# For Web
flutter run -d chrome

# For Desktop (macOS)
flutter run -d macos
```

---

## 🔥 Firebase Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name: `ai-scrum`
4. Select your region
5. Enable Google Analytics (optional)
6. Click **"Create project"**

### Step 2: Enable Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click **"Create database"**
3. Choose **"Start in production mode"**
4. Select your region (same as your project region)
5. Click **"Create"**

### Step 3: Set Firestore Security Rules

1. Go to **Firestore Database** → **Rules**
2. Replace with these rules:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User's own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;

      // User's projects
      match /projects/{projectId} {
        allow read, write: if request.auth.uid == userId;

        // Project analysis data
        match /analysis/{analysisId} {
          allow read, write: if request.auth.uid == userId;
        }
      }
    }
  }
}
```

### Step 4: Enable Authentication

1. Go to **Authentication** → **Sign-in method**
2. Enable:
   - ✅ Email/Password
   - ✅ Google (optional)
   - ✅ Anonymous (for testing)

### Step 5: Create Firestore Indexes

1. Go to **Firestore Database** → **Indexes**
2. Create the following composite index:

**Index 1: Projects Query**

- Collection: `users/{userId}/projects`
- Fields:
  - `createdAt` (Descending)
  - `status` (Ascending)

**Index 2: Analysis Query**

- Collection: `users/{userId}/projects/{projectId}/analysis`
- Fields:
  - `processedAt` (Descending)

You can also use the automatic index creation when you run queries in the app.

### Step 6: Set Firestore Quotas (Optional)

1. Go to **Firestore Database** → **Database settings**
2. Set daily limits if needed (free tier: 50K reads/day)

---

## 🔄 n8n Workflow Setup

### Step 1: Setup n8n Cloud

1. Go to [n8n Cloud](https://app.n8n.cloud/)
2. Sign up or log in
3. Create new workspace

### Step 2: Import Workflow

1. In n8n, go to **Workflows** → **Import**
2. Upload: `AI Scrum Master - Project Analysis.json`
3. Click **"Import workflow"**

### Step 3: Update Workflow Variables

The workflow has these nodes that need configuration:

#### Node: "Parse Message with AI" (OpenAI)

1. Click the node
2. In **Credentials**, select **"Create New"** → OpenAI
3. Enter your **OpenAI API Key**
4. Set Model to **"gpt-4-turbo"** or **"gpt-4"**

#### Node: "HTTP Request" (Firebase)

1. Click the node
2. In **Credentials**, select **"Create New"** → Google Firebase Firestore OAuth2
3. Follow the Google OAuth flow (see [Google Cloud Setup](#google-cloud-console-setup) below)

#### Node: "Build Firestore JSON"

1. Click this node
2. Find the line with your Firestore URL: `https://firestore.googleapis.com/v1/projects/YOUR_FIREBASE_PROJECT_ID/databases/...`
3. Replace **`YOUR_FIREBASE_PROJECT_ID`** with your actual Firebase Project ID

### Step 4: Activate Workflow

1. Click the **Active** toggle (top-right)
2. Set to **Enabled**
3. Copy the Webhook URL
4. Save the workflow

---

## ⚙️ Configuration Guide

### Firebase Configuration

#### Update Flutter App (firebase_options.dart)

The `firebase_options.dart` file is auto-generated by FlutterFire CLI. It contains:

```dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Platform-specific Firebase configuration
    // Auto-configured by FlutterFire
  }
}
```

**To regenerate or update:**

```bash
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```

#### Firebase Project ID Location

Find your Firebase Project ID at:

1. Firebase Console → Project Settings
2. Copy **Project ID** (e.g., `my-awesome-project`)

---

### n8n Configuration

#### n8n Cloud Settings

Your workflow runs on n8n Cloud servers automatically. No local configuration needed.

#### Webhook URL

After importing the workflow:

1. Open the **Webhook** node
2. Copy the URL shown at the top
3. Use this URL in your Flutter app's API service:

```dart
// In services/api_service.dart
const String N8N_WEBHOOK_URL = 'https://your-n8n-instance.com/webhook/scrum-master';
```

#### Request Format

Send POST request to webhook:

```json
{
  "projectId": "proj-123",
  "projectName": "My Flutter App",
  "prompt": "Build a Flutter app with Firebase auth and Firestore",
  "userId": "user-456",
  "timestamp": "2025-01-22T10:30:00Z"
}
```

Expected Response:

```json
{
  "milestones": [
    {
      "title": "Setup Firebase",
      "description": "Initialize Firebase project",
      "estimatedDays": 2,
      "subtasks": [...]
    }
  ],
  "requiredApis": ["Firebase Auth", "Firestore"],
  "schedules": [],
  "reminders": []
}
```

---

### Google Cloud Console Setup

This is required for n8n to write to your Firestore database.

#### Step 1: Create Service Account

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Make sure your **Firebase project** is selected
3. Go to **APIs & Services** → **Credentials**
4. Click **"Create Credentials"** → **"Service Account"**
5. Fill in:
   - Service account name: `n8n-firestore`
   - Service account ID: (auto-filled)
   - Description: "n8n Firestore integration"
6. Click **"Create and Continue"**

#### Step 2: Grant Permissions

1. Grant these roles:
   - ✅ **Firebase Firestore Editor** (for read/write access)
   - ✅ **Cloud Datastore User** (for database access)
2. Click **"Continue"** → **"Done"**

#### Step 3: Create OAuth 2.0 Credentials

1. Go back to **APIs & Services** → **Credentials**
2. Click **"Create Credentials"** → **"OAuth 2.0 Client IDs"**
3. Select **"Web application"**
4. Add authorized redirect URI:
   ```
   https://your-n8n-instance.com/rest/oauth2/callback
   ```
   (For localhost: `http://localhost:5678/rest/oauth2/callback`)
5. Click **"Create"**
6. Copy **Client ID** and **Client Secret**

#### Step 4: Enable Required APIs

1. Go to **APIs & Services** → **Enabled APIs & Services**
2. Click **"Enable APIs and Services"**
3. Search for and enable:
   - ✅ **Cloud Firestore API**
   - ✅ **Firebase Management API**
   - ✅ **Firestore API**

#### Step 5: Configure n8n HTTP Request Node

1. In n8n workflow, click **HTTP Request** node
2. Select **Authentication** → **"Create New"** → **"Google Firebase Firestore OAuth2"**
3. Fill in:
   - **Client ID**: (from Step 3)
   - **Client Secret**: (from Step 3)
   - **Authorization URL**: `https://accounts.google.com/o/oauth2/v2/auth`
   - **Access Token URL**: `https://oauth2.googleapis.com/token`
   - **Scope**: `https://www.googleapis.com/auth/cloud-platform`
4. Click **"Connect"**
5. Authenticate with your Google account
6. Authorize the app

#### Step 6: Test Connection

1. In the HTTP Request node, test with a simple request
2. Use URL: `https://firestore.googleapis.com/v1/projects/YOUR_PROJECT_ID/databases/(default)/documents`
3. Method: **GET**
4. Should return your Firestore documents

---

## 🔑 Setting Up API Keys

### OpenAI API Key

1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Sign in with your account
3. Go to **API keys** → **Create new secret key**
4. Copy the key
5. Add to n8n:
   - Click **"Parse Message with AI"** node
   - In **Credentials**, add your OpenAI API key
   - Select Model: **"gpt-4-turbo"** or **"gpt-4"**

⚠️ **Important**: Never share your API key!

### Firebase Admin SDK Key (Optional, for backend)

If you need server-side access:

1. Firebase Console → **Project Settings** → **Service Accounts**
2. Click **"Generate New Private Key"**
3. Save the JSON file securely
4. Use in backend code for admin operations

---

## 📱 Flutter App Integration

### Configure API Service

In `lib/services/api_service.dart`:

```dart
class ApiService {
  // Update with your n8n webhook URL
  static const String N8N_WEBHOOK_URL =
    'https://your-n8n-instance.com/webhook/scrum-master';

  Future<Map<String, dynamic>> analyzeProject({
    required String projectId,
    required String projectName,
    required String prompt,
    required String userId,
  }) async {
    final response = await http.post(
      Uri.parse(N8N_WEBHOOK_URL),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'projectId': projectId,
        'projectName': projectName,
        'prompt': prompt,
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to analyze project');
    }
  }
}
```
---

## 🆘 Troubleshooting

### Firebase Connection Issues

**Problem**: `PlatformException: User not authenticated`

**Solution**:

```dart
// Ensure user is logged in before accessing Firestore
if (FirebaseAuth.instance.currentUser != null) {
  // Access Firestore
}
```

### n8n Webhook Not Responding

**Problem**: Webhook returns 404 error

**Solution**:

1. Check if workflow is **Active** (toggle on)
2. Verify webhook path in node settings
3. Check n8n server is running: `curl http://localhost:5678`

### OpenAI API Errors

**Problem**: `401 Unauthorized`

**Solution**:

1. Verify API key is correct
2. Check API key has sufficient credits
3. Ensure API key hasn't expired

### Firestore Security Rules Block

**Problem**: `Permission denied` when writing to Firestore

**Solution**:

1. Update Firestore rules to allow your user
2. Verify user is authenticated
3. Check path matches rules exactly

---

## 📞 Support

For issues and questions:

- 📧 Email: kavindualwis.work@gmail.com
- 🐛 GitHub Issues: [Report Bug](https://github.com/kavindualwis/ai_scrum/issues)
- 💬 Discussions: [Join Discussion](https://github.com/kavindualwis/ai_scrum/discussions)

---

## 🙏 Acknowledgments

- **Flutter** - For the amazing cross-platform framework
- **Firebase** - For real-time database and authentication
- **n8n** - For the powerful workflow automation
- **OpenAI** - For GPT-4 API

---

### Quick Reference

| Task               | Command                   |
| ------------------ | ------------------------- |
| Get dependencies   | `flutter pub get`         |
| Configure Firebase | `flutterfire configure`   |
| Run app            | `flutter run`             |
| Build release      | `flutter build appbundle` |
| Analyze code       | `flutter analyze`         |
| Run tests          | `flutter test`            |

---

**Last Updated**: November 22, 2025

<div align="center">

**Made by Dev 👨‍💻 [Kavindu Alwis](https://github.com/kavindualwis)**

</div>

---
