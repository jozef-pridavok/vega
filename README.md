# Vega Platform

> **⚠️ Project Status: Discontinued**
> This project was discontinued before completion due to business reasons. The platform was partially functional but never reached production maturity. This repository serves as a technical demonstration of Flutter/Dart architecture and code-sharing capabilities.

## Overview

Vega is a comprehensive multi-platform solution for loyalty programs, coupons, reservations, and ordering systems. The project demonstrates advanced Flutter/Dart architecture with **extensive code sharing** between mobile applications, web dashboard, and backend servers.

## Key Features

### Business Features
- **Loyalty Programs** - Digital loyalty cards with points, stamps, and rewards
- **Coupons System** - Digital coupons with validation and redemption
- **Reservations** - Table/service booking with time slot management
- **Ordering System** - Product catalog, cart, and order management
- **Digital Leaflets** - Promotional materials and catalogs
- **Multi-location Support** - Manage multiple business locations
- **Push Notifications** - Real-time notifications via FCM
- **Payment Integration** - Stripe payment processing
- **QR Code Support** - QR scanning for cards and validations

### Technical Highlights

#### Shared Codebase Architecture
The project demonstrates **maximum code reuse** through a layered architecture:

```
┌─────────────────────────────────────────────────────┐
│                   Applications                      │
├──────────────┬──────────────┬──────────────┬────────┤
│  vega_app    │  vega_       │  api_mobile  │ api_   │
│  (Mobile)    │  dashboard   │  (Server)    │ cron   │
│  iOS/Android │  (Web/Mobile)│  (Backend)   │ (Jobs) │
└──────┬───────┴──────┬───────┴──────┬───────┴───┬────┘
       │              │              │           │
       └──────┬───────┴──────────────┘           │
              │                                  │
       ┌──────▼──────────┐              ┌────────▼──────┐
       │  core_flutter   │              │   core_dart   │
       │  (UI + Logic)   │◄─────────────┤  (Pure Logic) │
       └─────────────────┘              └───────────────┘
            Shared Data Models (56+)
         Shared Business Logic & Validation
              Shared API Contracts
```

**Core Architecture:**
- **`core_dart`** - Pure Dart package (56+ data models)
  - Shared between mobile apps AND backend servers
  - Data models, business logic, validation, API contracts
  - Used by both client and server - ensuring type safety across the stack
  - Repositories, formatters, localization, error handling

- **`core_flutter`** - Flutter package (UI + mobile logic)
  - Depends on `core_dart`
  - Reusable UI components, screens, providers
  - Shared between mobile app and web dashboard

- **`vega_app`** - Mobile application (iOS + Android)
  - Consumer-facing loyalty cards, coupons, ordering
  - Multi-language support (SK, EN, ES)

- **`vega_dashboard`** - Management dashboard (Web + Mobile)
  - Business management interface
  - Works on web browsers and as mobile/desktop app
  - Merchant tools for managing programs, orders, reservations

- **`api_mobile`** - Backend API server (Dart + Shelf)
  - **Uses the same `core_dart` package as mobile apps**
  - PostgreSQL database
  - JWT authentication, Stripe integration
  - RESTful API

- **`api_cron`** - Scheduled tasks server
  - Background jobs and maintenance tasks
  - Also uses `core_dart` for consistency

- **`fcm-api`** - Push notifications service (Node.js/TypeScript)
  - Firebase Cloud Messaging integration

- **`tool_commander`** - Development and deployment tools
  - Database setup, environment management

## Technology Stack

### Mobile & Web
- **Flutter 3.0+** - Cross-platform UI framework
- **Dart 3.0+** - Programming language
- **Riverpod** - State management
- **Hive** - Local storage
- Multi-platform support: iOS, Android, Web, macOS

### Backend
- **Dart** - Server-side runtime (same language as mobile!)
- **Shelf** - HTTP server framework
- **PostgreSQL** - Primary database
- **Docker** - Containerization

### Integrations
- **Stripe** - Payment processing
- **Firebase Cloud Messaging** - Push notifications
- **JWT** - Authentication

### Development
- **Multi-flavor builds** - Complete environment separation:
  - `dev` - Development environment for active development
  - `qa` - Quality Assurance environment for testing
  - `demo` - Demo environment for business presentations and pilots
  - `prod` - Production environment (configured but never deployed)
- **Environment-specific configurations** - Each flavor has its own API endpoints, database connections, and app identifiers
- **Shared linting rules** - Consistent code style across all modules
- **Localization** - Multi-language support (SK, EN, ES)

## Project Structure

```
vega/
├── core_dart/              # 🔥 Shared Dart logic (mobile + server)
│   └── lib/src/data_models/    # 56+ shared models
├── core_flutter/           # Shared Flutter UI components
├── vega_app/              # Mobile app (iOS/Android)
├── vega_dashboard/        # Dashboard (Web/Mobile/Desktop)
├── api_mobile/            # Backend API (Dart server)
├── api_cron/              # Scheduled jobs (Dart server)
├── fcm-api/               # Push notifications (Node.js)
└── tool_commander/        # DevOps tools
```

> **Note:** Originally, each module was maintained in a separate Git repository. For GitHub publication purposes, all modules have been consolidated into this monorepo structure while preserving the original modular architecture.

## Why This Architecture Matters

This project demonstrates several advanced concepts:

1. **Type Safety Across Stack** - The same data models are used on client and server, eliminating API contract mismatches
2. **Code Reusability** - Business logic written once, runs on iOS, Android, Web, and servers
3. **Consistency** - Validation rules, formatters, and business logic are identical everywhere
4. **Developer Productivity** - Changes to models automatically propagate across all platforms
5. **Reduced Bugs** - Shared code means bugs are fixed everywhere at once

## Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart SDK 3.0+
- PostgreSQL (for backend)
- Node.js (for FCM service)
- Docker (optional)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/jozef-pridavok/vega.git
   cd vega
   ```

2. **Install dependencies**
   ```bash
   # Core packages
   cd core_dart && dart pub get && cd ..
   cd core_flutter && flutter pub get && cd ..

   # Applications
   cd vega_app && flutter pub get && cd ..
   cd vega_dashboard && flutter pub get && cd ..

   # Backend
   cd api_mobile && dart pub get && cd ..
   cd api_cron && dart pub get && cd ..
   ```

3. **Run mobile app**
   ```bash
   cd vega_app
   flutter run --flavor dev
   ```

4. **Run dashboard**
   ```bash
   cd vega_dashboard
   flutter run -d chrome --flavor dev
   ```

5. **Run backend**
   ```bash
   cd api_mobile
   # Configure config.dev.yaml first
   dart run bin/main.dart
   ```

## Configuration

Each module has environment-specific configuration:
- `config.dev.yaml` - Development
- `config.qa.yaml` - Quality assurance
- `config.demo.yaml` - Demo environment
- `config.prod.yaml` - Production (never used)

Sample configuration files are provided (`.sample.yaml`).

## License

**MIT License**

Copyright (c) 2024

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

**Feel free to use this code for learning, inspiration, or as a foundation for your own projects.**

## Contact

For questions or discussions about the architecture and implementation, feel free to open an issue.

---

*This project represents real-world Flutter/Dart architecture solving complex business problems. While incomplete, it demonstrates production-grade patterns, code organization, and cross-platform development at scale.*
