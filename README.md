# Blockchain Flutter Application

A **Flutter web application** that simulates blockchain creation between nodes using fake **bank transactions**.

## Features

- Genesis block creation on startup.
- **Create Bank Transaction** button generates fake sender/receiver/amount data.
- Each new block stores:
  - index
  - previous hash
  - current hash
  - transaction payload
  - timestamp
- New block is linked to the previous block.
- Animated connector line appears when a new block is added.
- No verification/mining complexity (as requested).

## Project Score

| Category | Score (/10) | Notes |
|---|---:|---|
| Requirements Coverage | 10 | Fake bank transaction block generation + chaining + linking animation implemented. |
| UI/UX Clarity | 8 | Clear ledger list and block cards; can be enhanced with node graph view. |
| Code Structure | 8 | Single-file implementation for simplicity; easy to split into models/widgets/services later. |
| Test Baseline | 7 | Basic widget smoke test included. |
| Extensibility | 8 | Model and painter can be extended for validation, multiple nodes, consensus demos. |
| **Overall** | **8.2** | Good educational simulation baseline. |

## Project Structure

```text
BlockchainFlutterApplication/
├── lib/
│   └── main.dart               # UI + block model + link animation
├── test/
│   └── widget_test.dart        # Basic widget smoke test
├── pubspec.yaml                # Flutter dependencies and package metadata
├── analysis_options.yaml       # Lints
├── README.md                   # Project docs, score, structure
└── LICENSE
```

## Run in Chrome (Web)

```bash
flutter config --enable-web
flutter pub get
flutter run -d chrome
```

> This project is intended to run as a web app in Chrome (no Android emulator/device needed).

## Test

```bash
flutter test
```
