# Thryve - Invest in US Stocks from Africa

A Flutter-based mobile and web application for investing in US stocks, targeting the African market (Nigeria).

## Tech Stack

- **Frontend**: Flutter 3.x (iOS, Android, Web)
- **Backend**: Python on AWS Lambda (Serverless)
- **Database**: DynamoDB + Aurora Serverless
- **Auth**: AWS Cognito
- **Brokerage**: DriveWealth API
- **Payments**: Paystack, Flutterwave

## Project Structure

```
lib/
├── app/              # App configuration, routing, themes
├── core/             # Core utilities (DI, network, storage, errors)
├── features/         # Feature modules (auth, kyc, trading, etc.)
└── shared/           # Shared widgets and constants
```

## Getting Started

### Prerequisites

- Flutter SDK 3.10+
- Dart SDK 3.0+
- iOS: Xcode 15+
- Android: Android Studio with SDK 33+

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Download fonts (Inter and Space Grotesk) and place in `assets/fonts/`
4. Run the app:
   ```bash
   flutter run
   ```

### Fonts Setup

Download the following fonts and save to `assets/fonts/`:

- **Inter**: https://fonts.google.com/specimen/Inter
  - Inter-Light.ttf (300)
  - Inter-Regular.ttf (400)
  - Inter-Medium.ttf (500)
  - Inter-SemiBold.ttf (600)
  - Inter-Bold.ttf (700)
  - Inter-ExtraBold.ttf (800)

- **Space Grotesk**: https://fonts.google.com/specimen/Space+Grotesk
  - SpaceGrotesk-Medium.ttf (500)
  - SpaceGrotesk-Bold.ttf (700)

## Architecture

This project follows **Clean Architecture** with a feature-first structure:

- **Presentation**: BLoC pattern for state management
- **Domain**: Use cases and entities
- **Data**: Repository implementations and data sources

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed documentation.

## Environment Configuration

Create environment files for different stages:
- `.env.development`
- `.env.staging`
- `.env.production`

## License

Proprietary - All rights reserved
