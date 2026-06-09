# 🚖 ZonaX - Smart Fleet Intelligence Platform (SFIP)

![Flutter Version](https://img.shields.io/badge/Flutter-3.x-blue.svg)
![Architecture](https://img.shields.io/badge/Architecture-Clean_Architecture-success.svg)
![State Management](https://img.shields.io/badge/State_Management-BLoC%2FCubit-orange.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)

> An AI-powered mobile application designed to optimize taxi and fleet driver operations through predictive analytics, real-time demand mapping, and intelligent decision support.

---

## 📑 Table of Contents
1. [About The Project](#-about-the-project)
2. [Core Features](#-core-features)
3. [Architecture & Folder Structure](#-architecture--folder-structure)
4. [Tech Stack](#-tech-stack)
5. [Getting Started](#-getting-started)
6. [Team & Authors](#-team--authors)

---

## 📌 About The Project
**ZonaX** leverages machine learning, geospatial analysis, and voice-first interaction to provide drivers with actionable insights that maximize earnings while ensuring safe, hands-free operation. It aims to increase driver earnings by 15-25% through intelligent zone recommendations and maintain functionality during connectivity loss through offline edge computing.

*(📸 Note: Add a high-quality mockup or GIF of your app's main heatmap screen here later)*

---

## ✨ Core Features
* 🗺️ Dynamic Predictive Heatmaps:** Visualize real-time and forecasted demand on an interactive map.
* 🎙️ Voice-First Smart Assistant:** Enable hands-free interaction using natural language processing.
* 🧠 Explainable Insight Cards:** Provide transparent explanations for AI recommendations.
* 📶 Offline Edge Mode:** Maintain critical functionality during connectivity loss.
* ☕ Smart Break Timer:** Recommend optimal break times based on demand patterns.
* 📊 Business Intelligence Dashboard:** Track and visualize daily earnings progress and calculate driver payout.

---

## 🏗️ Architecture & Folder Structure
This project strictly follows **Clean Architecture** principles with clear Presentation, Domain, and Data layers to ensure scalability, testability, and separation of concerns.

```text
lib/
│
├── core/                                 # 1. Core Layer (Infrastructure & Shared Services)
│   ├── network/                          # Network communication
│   │   ├── remote_data_source_impl.dart  # (API data fetching using Dio)
│   │   ├── websocket_manager.dart        # (Real-time connection for Heatmaps)
│   │   ├── auth_interceptor.dart         # (Token injection)
│   │   └── circuit_breaker_handler.dart  # (Handling server failures gracefully)
│   │
│   ├── storage/                          # Local storage
│   │   ├── local_data_source_impl.dart   # (Hive DB for Offline Mode)
│   │   ├── secure_storage_service.dart   # (Secure token storage)
│   │   ├── file_resource_manager.dart    # (Managing local map files)
│   │   └── encryption_service.dart       # (Encrypting sensitive data)
│   │
│   ├── errors/                           # Error handling
│   │   ├── exceptions.dart               # (ServerException, CacheException)
│   │   └── failures.dart                 # (ServerFailure, NetworkFailure)
│   │
│   ├── services/                         # Shared background services
│   │   ├── service_locator.dart          # (Dependency Injection setup - GetIt)
│   │   ├── geofencing_service.dart       # (Detecting when a driver enters a hotspot)
│   │   ├── local_notification_handler.dart # (Break and demand alerts)
│   │   ├── app_analytics.dart            # (User behavior tracking)
│   │   └── crashlytics_service.dart      # (Error and crash reporting)
│   │
│   ├── theme/                            # Design System
│   │   ├── app_colors.dart               # (Primary, Background, Semantic colors)
│   │   ├── app_typography.dart           # (Fonts and text styles)
│   │   └── app_dimensions.dart           # (Paddings and margins)
│   │
│   └── utils/                            # Helper utilities
│       ├── geo_json_parser.dart          # (Parsing NYC maps into geometries)
│       └── data_integrity_guard.dart     # (Validating GPS precision and data)
│
├── features/                             # 2. Features Layer (Feature-First grouping)
│   │
│   ├── analytics/                        # Feature: Driver Performance & Analytics
│   ├── auth/                             # Feature: Authentication (Token management)
│   ├── demand_grid/                      # Feature: Real-time Demand Mapping
│   ├── earnings/                         # Feature: Driver Earnings & Payouts
│   ├── home/                             # Feature: Main Dashboard / Home Screen
│   ├── leaderboard/                      # Feature: Gamification & Driver Rankings
│   ├── login/                            # Feature: User Login / Onboarding
│   ├── map/                              # Feature: Interactive Maps & Navigation
│   │   ├── data/                         # (Example Feature Structure)
│   │   │   ├── models/                   
│   │   │   └── repositories/             
│   │   ├── domain/                       
│   │   │   ├── entities/                 
│   │   │   ├── repositories/             
│   │   │   └── usecases/                 
│   │   └── presentation/                 
│   │       ├── cubit/                    
│   │       ├── screens/                  
│   │       └── widgets/                  
│   │
│   ├── profile/                          # Feature: Driver Profile Management
│   ├── simulation/                       # Feature: Testing / Demand Simulation
│   ├── trips/                            # Feature: Trip History & Management
│   └── voice_assistant/                  # Feature: Hands-free Voice Controls
│
└── main.dart                             # Application Entry Point (Calls ServiceLocator)
```

---

## 🛠️ Tech Stack
* **Framework:** Flutter 3.x
* **State Management:** BLoC / Cubit
* **Architecture:** Clean Architecture (Feature-First)
* **Local Storage & Edge Mode:** Hive DB
* **Network & Connectivity:** Dio, Retrofit, `connectivity_plus` (for real-time offline mode detection)
* **Maps & Geospatial:** Mapbox Maps, GeoJSON
* **Voice Assistant:** Speech To Text, Flutter TTS

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (>=3.11.1 <4.0.0)
* Mapbox Access Token
* Supabase Credentials

### Installation
1. Clone the repo:
   ```sh
   git clone https://github.com/moustafaibrahim10/ZonaX.git
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Setup environment variables (create a `.env` file in the root):
   ```env
   MAPBOX_ACCESS_TOKEN=your_token_here
   SUPABASE_URL=your_url_here
   SUPABASE_ANON_KEY=your_key_here
   ```
4. Run the app:
   ```sh
   flutter run
   ```

---

## 📶 Real-time Offline Edge Mode
ZonaX ensures seamless driver operation even in areas with poor or no internet connectivity. Powered by `connectivity_plus` and Hive:
- **Instant Detection:** Switches to Offline Mode instantly when the internet drops.
- **Local Caching:** Caches trip paths, driver coordinates, and events securely on the device.
- **Auto-Sync:** Detects when the connection is restored and automatically syncs all queued logs to the server.

---

## 👨‍💻 Team & Authors
* **Moustafa Ibrahim** - *Lead Developer*
