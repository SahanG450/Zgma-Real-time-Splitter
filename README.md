# SmartPay 💳

> **Session-Based Group Payment Platform** — Scan. Split. Settle.

SmartPay eliminates the friction of splitting shared bills. Whether it's a restaurant table, a taxi ride, a hotel booking, or a group trip — SmartPay creates a live payment session, lets everyone scan a QR code, see their share, and pay instantly.

Built for Sri Lanka. Designed to scale across South Asia.

---

## ✨ Features

- **Session-Based Payments** — Create a payment session for any shared bill (hotel, taxi, rental, trip)
- **QR Code Join Flow** — Participants scan a QR code to instantly join a session — no manual group setup
- **Flexible Bill Splitting** — Equal split, item-based selection, or custom amount per person
- **Real-Time Balance Tracking** — Live updates via Supabase Realtime as payments come in
- **Hybrid Payment Support** — Digital payments and cash (manually confirmed by cashier)
- **Debt Management** — Tracks who paid for whom across sessions; supports debt consolidation and settlement
- **Role-Based Access** — Normal User, Cashier/Provider, and Admin roles with distinct permissions
- **Push Notifications** — FCM-powered alerts for payments, session settlement, and debt reminders
- **Guest Mode** — Join and pay without registration (limited to single session)
- **Offline-Tolerant UI** — Cached session view; payment queued on reconnect

---

## 🏗️ Tech Stack

| Layer              | Technology                      |
| ------------------ | ------------------------------- |
| Mobile App         | Flutter (Dart) — iOS & Android  |
| API Gateway        | Node.js + Express               |
| Microservices      | Node.js + Express (7 services)  |
| Database           | Supabase (PostgreSQL)           |
| Auth               | Supabase Auth + JWT             |
| Real-Time          | Supabase Realtime (WebSocket)   |
| File Storage       | Supabase Storage                |
| Push Notifications | Firebase Cloud Messaging (FCM)  |
| QR Generation      | Node.js `qrcode` package        |
| CI/CD              | GitHub Actions + Docker Compose |

---

## 🗂️ Project Structure

```
smartpay/
├── mobile/                  # Flutter mobile app
│   └── lib/
│       ├── core/            # Router, network, storage, utils
│       ├── features/        # auth, session, payment, debt, cashier, admin...
│       └── shared/          # Reusable widgets and theme
│
├── backend/
│   ├── gateway/             # API Gateway — port 3000
│   ├── services/
│   │   ├── user-service/         # port 3001
│   │   ├── session-service/      # port 3002
│   │   ├── payment-service/      # port 3003
│   │   ├── contribution-service/ # port 3004
│   │   ├── debt-service/         # port 3005
│   │   ├── qr-service/           # port 3006
│   │   └── notification-service/ # port 3007
│   └── shared/              # Supabase client, response utils, middleware
│
├── supabase/
│   ├── migrations/          # Ordered SQL migration files
│   ├── rls/                 # Row Level Security policies
│   ├── functions/           # DB triggers and cron jobs
│   └── seed/                # Dev/test seed data
│
├── docs/                    # SRS, API spec (OpenAPI), architecture docs
├── docker-compose.yml
└── .github/workflows/       # CI/CD pipelines
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Node.js `18 LTS`
- Docker & Docker Compose
- Supabase CLI
- Firebase project (for FCM)

### 1. Clone the repo

```bash
git clone https://github.com/YOUR_USERNAME/smartpay.git
cd smartpay
```

### 2. Set up environment variables

```bash
cp .env.example .env
# Fill in your Supabase URL, anon key, JWT secret, FCM credentials
```

### 3. Run the backend (all services)

```bash
docker-compose up --build
```

Services will be available at:

- Gateway → `http://localhost:3000`
- User Service → `http://localhost:3001`
- Session Service → `http://localhost:3002`
- Payment Service → `http://localhost:3003`
- Contribution Service → `http://localhost:3004`
- Debt Service → `http://localhost:3005`
- QR Service → `http://localhost:3006`
- Notification Service → `http://localhost:3007`

### 4. Apply Supabase migrations

```bash
supabase db push
```

### 5. Run the Flutter app

```bash
cd mobile
flutter pub get
flutter run
```

---

## 📡 API Overview

Base URL: `https://api.smartpay.lk/api/v1`

All responses follow this envelope:

```json
{
  "success": true,
  "data": {},
  "error": null,
  "meta": { "page": 1, "limit": 20, "total": 100 }
}
```

Key endpoints:

| Method | Endpoint             | Description                      |
| ------ | -------------------- | -------------------------------- |
| `POST` | `/auth/register`     | Register new user                |
| `POST` | `/auth/login`        | Login, receive JWT               |
| `POST` | `/sessions`          | Create payment session (Cashier) |
| `POST` | `/sessions/:id/join` | Join a session via QR            |
| `POST` | `/contributions`     | Set split amount                 |
| `POST` | `/payments`          | Submit payment                   |
| `GET`  | `/debts/me`          | Get debt summary                 |
| `POST` | `/debts/:id/settle`  | Settle a debt                    |

Full API reference: [`docs/api/openapi.yaml`](docs/api/openapi.yaml)

---

## 🧑‍💻 Team & Branching Strategy

This project is built by a team of 4 (2 initial, 2 joining at Month 2).

```
main          ← stable, production-ready
develop       ← integration branch
feature/*     ← individual feature branches
hotfix/*      ← urgent production fixes
```

**Workflow:**

```bash
git checkout develop
git checkout -b feature/your-feature-name
# ... make changes ...
git push origin feature/your-feature-name
# Open Pull Request → develop
```

---

## 🗺️ Roadmap

- [x] Project scaffold & SRS
- [ ] Phase 1 — MVP (Auth, Sessions, QR, Payments, Debts)
- [ ] Phase 2 — Real payment gateway integration (CBSL compliant)
- [ ] Phase 2 — Sinhala & Tamil localization
- [ ] Phase 2 — Google OAuth
- [ ] Phase 2 — Scale to 5000+ concurrent sessions

---

## 📄 License

Private & Confidential — SmartPay © 2026. All rights reserved.
