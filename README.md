# 🚆 RailMate – Flutter Application  

A **modern cross-platform mobile app** built with **Flutter** that replicates the core features of the popular Indian app *Where Is My Train*. This project integrates **Supabase** as the backend database and authentication layer, enabling real-time train tracking, PNR status checks, and offline caching for a seamless user experience.  

---

## ✨ Features  

- 🔎 **Search Trains** – Find trains between two stations with smart station suggestions.  
- 🚉 **Live Train Status** – View real-time running information of trains (delays, arrivals, departures).  
- 📄 **PNR Status Check** – Get ticket confirmation updates.  
- 📌 **Saved Searches** – Store recent and favorite train searches for quick access.  
- 📶 **Offline Mode** – Cache schedules locally using SQLite for low-network scenarios.  
- 🔔 **Notifications** – Push alerts for train delays and arrivals.  
- 🔐 **Authentication** – User login & signup with Supabase Auth (email/password, OTP, or social login).  

---

## 🏗️ Tech Stack  

**Frontend (Mobile App):**  
- [Flutter](https://flutter.dev/)  
- [Dart](https://dart.dev/)  
- [Provider / Riverpod](https://riverpod.dev/) (state management)  
- [SQLite](https://pub.dev/packages/sqflite) for local offline caching  

**Backend & Database:**  
- [Supabase](https://supabase.com/) (Postgres + Auth + Realtime)  
- REST APIs (custom endpoints for train data simulation)  

**DevOps / Tools:**  
- Android Studio & Xcode for builds  
- GitHub Actions / CI for automated builds  

---

## 📂 Project Structure  

lib/
├─ main.dart # Entry point
├─ screens/ # UI screens (Home, Train Status, PNR, Profile)
├─ widgets/ # Reusable widgets (cards, lists, loaders)
├─ services/ # API & Supabase service calls
├─ models/ # Data models (Train, Station, User)
├─ providers/ # State management logic
└─ utils/ # Helpers (formatters, constants)

---

## ⚡ Getting Started  

### 1️⃣ Prerequisites  
- Install [Flutter SDK](https://flutter.dev/docs/get-started/install)  
- Install [Android Studio](https://developer.android.com/studio) or Xcode (for iOS)  
- Install [Supabase CLI](https://supabase.com/docs/guides/cli)  

### 2️⃣ Clone Repository  
```bash
git clone https://github.com/iamdheerajjain/RailMate.git

🗄️ Database Schema (Supabase)

stations → (id, code, name, state)
trains → (id, number, name, source, destination)
train_schedule → (id, train_id, station_id, arrival_time, departure_time, day)
users → (id, email, password_hash, created_at)
search_history → (id, user_id, train_id, timestamp)
