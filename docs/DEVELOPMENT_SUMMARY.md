# Thryve Mobile App - Development Documentation

**Project:** Thryve - Fractional Stock Investment Platform  
**Target Market:** Nigeria  
**Date:** December 26, 2024  
**Status:** Frontend Complete, Ready for Backend Integration

---

## Table of Contents
1. [Project Overview](#project-overview)
2. [Technology Stack](#technology-stack)
3. [Session Summary](#session-summary)
4. [Detailed Task Log](#detailed-task-log)
5. [Architecture Decisions](#architecture-decisions)
6. [File Structure](#file-structure)
7. [API Integration Guide](#api-integration-guide)
8. [Security Considerations](#security-considerations)
9. [Known Issues & Technical Debt](#known-issues--technical-debt)
10. [How to Continue Development](#how-to-continue-development)
11. [Running & Testing](#running--testing)

---

## Project Overview

### What is Thryve?
Thryve is a mobile investment app that allows Nigerian users to invest in US stocks with fractional shares. Users can buy as little as $1 worth of stocks like Apple, Tesla, or Amazon through fractional trading powered by DriveWealth's brokerage infrastructure.

### Core Features
- User registration and authentication (Cognito)
- Full KYC (Know Your Customer) onboarding - DriveWealth compliant
- Real-time stock quotes and market data
- Fractional share trading (buy/sell)
- Wallet management (deposits via Paystack/Flutterwave, withdrawals to Nigerian banks)
- Portfolio tracking and performance analytics
- Stock research (analyst ratings, financials, news)
- Price alerts (local notifications)

### Business Model
- Commission-free trading (revenue from payment spreads and premium features)
- Target: Millennials and Gen-Z in Nigeria interested in global investing

---

## Technology Stack

### Frontend
| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| Framework | Flutter | 3.x | Cross-platform (iOS, Android, Web) |
| Language | Dart | 3.x | Type-safe, null-safe |
| State Management | flutter_bloc | 8.1.6 | Predictable state, separation of concerns |
| Navigation | go_router | 14.8.1 | Declarative routing, deep linking |
| Charts | fl_chart | 0.69.2 | Stock price charts, portfolio graphs |
| Secure Storage | flutter_secure_storage | 9.2.4 | Encrypted credential storage |
| HTTP Client | http | 1.6.0 | API requests to Finnhub |
| Biometrics | local_auth | 2.3.0 | Face ID / Fingerprint authentication |

### Backend (Planned - Not Implemented)
| Component | Technology | Purpose |
|-----------|------------|---------|
| Authentication | AWS Cognito | User management, JWT tokens |
| API Layer | AWS API Gateway | REST endpoints |
| Business Logic | AWS Lambda (Python) | Serverless functions |
| Database | DynamoDB | User data, preferences |
| Brokerage | DriveWealth API | Trading, account management |
| Payments | Paystack / Flutterwave | NGN deposits |
| Market Data | Finnhub API | Quotes, analyst data, news |

### Design System
- **Primary Color:** Hermes Orange (`#f37021`)
- **Font Family:** Inter (all weights)
- **Dark Mode:** Fully supported
- **Design Files:** Reference images in `docs/reference_designs/`

---

## Session Summary

### Date: December 26-27, 2024

### Objectives Completed (Dec 26)
1. ✅ Research DriveWealth API requirements for user onboarding
2. ✅ Create gap analysis comparing existing UI to DriveWealth needs
3. ✅ Build missing KYC screens for DriveWealth compliance
4. ✅ Implement enhanced stock detail page with multiple sections
5. ✅ Create Finnhub API integration models and data source
6. ✅ Fix Flutter analyze warnings and verify build
7. ✅ Create comprehensive documentation

### Objectives Completed (Dec 27 - Morning)
8. ✅ Add Auto-Invest feature (D/W/M/Y scheduling)
9. ✅ Add Portfolio chart toggle (line/pie charts)
10. ✅ Update logo and app icons

### Objectives Completed (Dec 27 - Evening Session)
11. ✅ **User Profile API Integration** - Full AWS API Gateway + Lambda + DynamoDB setup
12. ✅ **Profile Page** - Now displays real user data from DynamoDB
13. ✅ **Edit Profile Page** - Loads real data, KYC locking implemented
14. ✅ **Notifications Page** - Actionable items for phone verification and KYC
15. ✅ **UserProfileService** - Singleton with permanent caching for fast page loads
16. ✅ **Home Page** - Fixed notification bell navigation
17. ✅ **Security Cleanup** - Removed all debug print statements from production code
18. ✅ **API Documentation** - Complete guide for User Profile API

### Objectives Completed (Dec 28 - Security Hardening)
19. ✅ **Biometric Login** - Fixed toggle, added biometric option to login page
20. ✅ **Dark Mode Toggle** - Now actually changes app theme + persisted
21. ✅ **Change Password** - Wired to Cognito API with validation
22. ✅ **Session Timeout & Lock** - App locks on background, biometric to unlock
23. ✅ **Disable Screenshots** - Android FLAG_SECURE + iOS secure overlay
24. 📋 **Device Management** - AWS setup guide documented (pending deployment)

### AWS Infrastructure Configured
- **API Gateway:** `https://y1mheifune.execute-api.us-east-1.amazonaws.com/prod`
- **Lambda Functions:**
  - `thryve-get-user-profile` - Fetches user data from DynamoDB
  - `thryve-post-confirmation` - Creates user in DynamoDB on signup
  - `thryve-device-management` - *(Pending)* Device CRUD operations
- **DynamoDB Tables:**
  - `thryve-users` - Stores extended user profiles
  - `thryve-user-devices` - *(Pending)* Device tracking for 3-device limit
- **Cognito:** User Pool with Post Confirmation Lambda trigger

### Metrics
- **New Screens Created:** 7
- **Screens Modified:** 12
- **New Widget Components:** 10
- **New Services Created:** 4 (ApiService, UserProfileService, ThemeService, SessionService)
- **Total App Screens:** 38+
### Objectives Completed (Dec 29 - Code Review & Security Audit)
25. ✅ **Comprehensive Codebase Review** - Reviewed all 50+ dart files across features
26. ✅ **Bug Fixes** - Fixed 4 bugs identified during review:
    - Removed unused `_resetBiometricSession()` method in lock_screen.dart
    - Fixed `removePin()` to sync removal to Cognito for cross-device consistency
    - Removed unused `_shellNavigatorKey` variable from router.dart
    - Fixed security_page.dart Change Password to call Cognito API
27. ✅ **Code Review Document** - Created findings document with pre-production items
28. ⚠️ **Security Items Documented** - For pre-production:
    - PIN hashing without salt (requires migration strategy)
    - API key handling (use env variables)

### Objectives Completed (Dec 29 - Settings & Devices Refactor)
29. ✅ **Settings Page Refactor**:
    - Added "Change Passcode" tile (moved from security page)
    - Renamed "Two-Factor Authentication" → "Devices"
    - Updated icon to `Icons.devices`
    - Added full PIN sheet with keypad for passcode changes
30. ✅ **Security Page → Devices Page**:
    - Renamed page title from "Security" to "Devices"
    - Removed Password & Passcode section (moved to Settings)
    - Removed Biometric Authentication section (stays in Settings)
    - Added info banner explaining device management
    - Added delete button to each non-current device
    - Kept "Log out all other devices" with confirmation dialog

### Objectives Completed (Dec 29 - Bug Fixes & Architecture Improvements)
31. ✅ **iOS Crash Fix** - Fixed `AppDelegate.swift` crash on launch
    - Removed problematic CALayer manipulation in `setupSecureScreen()`
    - Kept blur overlay for app switcher protection
32. ✅ **Biometric Button Fix** - Fixed button not working after cancel
    - Added `_onBiometricButtonTap()` method that resets session flag
    - Button now properly re-triggers biometric auth after cancel
33. ✅ **Cross-Device Passcode Sync** - Fixed passcode prompt on new device
    - Added `syncFromCloud()` call in splash_page.dart after session validation
    - Syncs passcode hash from Cognito before checking if enabled
34. ✅ **Profile Data Caching** - Fixed placeholder profile after unlock
    - Added user attribute caching (givenName, familyName, etc.) to local storage
    - `getCurrentUser()` now reads from local cache (no network call)
    - Added storage keys in `AuthConfig` for user attributes
35. ✅ **CognitoAuthDatasource Singleton** - Fixed session state sharing
    - Converted to singleton pattern so all app components share same session
    - Fixed password change "session expired" error
    - Fixed passcode sync failing due to different instances

### Session Metrics (Dec 29 - Bug Fixes)
- **Critical Bugs Fixed:** 5
- **Architecture Improvements:** 2 (local caching, singleton)
- **Files Modified:** 6

### Session Metrics (Dec 29)
- **Files Reviewed:** 50+ dart files
- **Bugs Fixed:** 4
- **Pages Refactored:** 2 (settings_page.dart, security_page.dart)

---

## Detailed Task Log

### Task 1: DriveWealth API Research
**Objective:** Understand what user data DriveWealth requires for account creation

**What Was Done:**
- Researched DriveWealth's Users API documentation
- Identified all required PII (Personally Identifiable Information) fields
- Researched KYC verification options (DO_KYC, NO_KYC, VERIFY_KYC)
- Researched investor suitability requirements
- Researched disclosure/agreement requirements

**Key Findings:**

DriveWealth Users API requires:
```
Required Fields:
├── Legal First Name (must match ID)
├── Legal Last Name (must match ID)
├── Date of Birth
├── Email Address
├── Phone Number
├── Street Address (no PO boxes)
├── City
├── State/Province
├── Postal/ZIP Code
├── Country of Residence
├── Country of Citizenship
├── Tax Residency Country
└── Tax ID (SSN for US, BVN for Nigeria, TIN for others)

Investor Profile (for suitability):
├── Employment Status
├── Employer Name
├── Occupation
├── Annual Income Range
├── Total Net Worth
├── Liquid Net Worth
├── Investment Experience
├── Investment Objectives
└── Risk Tolerance

Required Agreements:
├── Customer Account Agreement
├── Trading Disclosure
├── Privacy Policy
├── Terms of Use
├── W-8BEN Tax Certification (for non-US)
└── Risk Disclosure
```

**Files Created:** None (research only)

---

### Task 2: Gap Analysis Document
**Objective:** Compare existing UI screens to DriveWealth requirements

**What Was Done:**
- Reviewed existing `kyc_personal_info_page.dart` (had: name, DOB, BVN, address, city, state)
- Identified missing fields: postal code, country, citizenship, tax residency
- Identified missing screens: investor profile, disclosures
- Identified missing features: official documents page, order history

**Files Created:**
- `.gemini/antigravity/brain/.../implementation_plan.md` - Detailed gap analysis

**User Decision:** Approved the gap analysis and requested implementation

---

### Task 3: Create KYC Investor Profile Page
**Objective:** Collect employment and financial information for DriveWealth suitability assessment

**What Was Done:**
- Created new screen with 3 sections: Employment, Financial, Investment
- Implemented conditional employer fields (show only if employed/self-employed)
- Used dropdown selectors for standardized responses
- Added validation to ensure all fields are completed
- Connected to 5-step KYC flow progress indicator

**Implementation Details:**
```dart
// Employment options
['Employed', 'Self-Employed', 'Unemployed', 'Retired', 'Student']

// Income ranges (for DriveWealth)
['Less than $25,000', '$25,000 - $50,000', '$50,000 - $100,000', ...]

// Investment experience levels
['None', 'Limited (1-2 years)', 'Moderate (3-5 years)', 'Extensive (5+ years)']

// Risk tolerance
['Conservative', 'Moderate', 'Aggressive']
```

**Files Created:**
- `lib/features/kyc/presentation/pages/kyc_investor_profile_page.dart` (390 lines)

---

### Task 4: Create KYC Disclosures Page
**Objective:** Capture explicit consent for all required DriveWealth agreements

**What Was Done:**
- Created 6 disclosure checkboxes with "Read" buttons
- Implemented modal bottom sheets with full agreement text
- Added "Accept All" master checkbox
- Submit button only enabled when all agreements accepted
- Navigates to pending status after submission

**Disclosures Implemented:**
1. Customer Account Agreement
2. Trading Disclosure
3. Privacy Policy
4. Terms of Use
5. Tax Certification (W-8BEN)
6. Investment Risk Disclosure

**Implementation Details:**
```dart
// Each disclosure has:
// - Title and description
// - Checkbox for acceptance
// - "Read" button to view full content
// - Content displayed in DraggableScrollableSheet

bool get _allAccepted =>
    _acceptAccountAgreement &&
    _acceptTradingDisclosure &&
    _acceptPrivacyPolicy &&
    _acceptTermsOfUse &&
    _acceptTaxCertification &&
    _acceptRiskDisclosure;
```

**Files Created:**
- `lib/features/kyc/presentation/pages/kyc_disclosures_page.dart` (450 lines)

---

### Task 5: Create Documents Page
**Objective:** Allow users to access official DriveWealth account documents

**What Was Done:**
- Created tabbed interface with 3 tabs: Statements, Tax, Trades
- Implemented document card UI with icon, title, subtitle, date
- Added download button functionality (mock)
- Different icons/colors for different document types

**Document Types:**
```dart
enum DocumentType { statement, tax, confirmation }

// Example documents:
// - Account Statement - December 2024
// - W-8BEN Tax Certification
// - Form 1042-S - 2023
// - Trade Confirmation - AAPL Buy 2.5 shares
```

**Files Created:**
- `lib/features/profile/presentation/pages/documents_page.dart` (260 lines)

---

### Task 6: Create Order History Page
**Objective:** Show detailed order status with DriveWealth order tracking

**What Was Done:**
- Created filterable list (All, Open, Filled, Cancelled)
- Implemented order cards with symbol, side (buy/sell), status
- Added order detail bottom sheet with full information
- Cancel button for open orders
- Color-coded status badges

**Order Model:**
```dart
class OrderItem {
  final String id;           // 'ORD-2024-001234'
  final String symbol;       // 'AAPL'
  final String name;         // 'Apple Inc.'
  final OrderType type;      // market, limit, stop
  final OrderSide side;      // buy, sell
  final double quantity;     // 2.5 (fractional)
  final double? price;       // fill price
  final double? limitPrice;  // for limit orders
  final OrderStatus status;  // open, filled, cancelled, rejected
  final DateTime createdAt;
  final DateTime? filledAt;
}
```

**Files Created:**
- `lib/features/wallet/presentation/pages/order_history_page.dart` (480 lines)

---

### Task 7: Update KYC Personal Info Page
**Objective:** Add missing DriveWealth required fields

**What Was Done:**
- Added postal code field
- Added country of residence dropdown
- Added country of citizenship dropdown
- Added tax residency country dropdown
- Made tax ID label dynamic (BVN for Nigeria, SSN for US, TIN for others)
- Updated to 5-step progress indicator
- Changed navigation to go to investor profile next

**Before vs After:**
```
Before:                       After:
├── First Name                ├── Legal First Name
├── Last Name                 ├── Legal Last Name
├── Date of Birth             ├── Date of Birth
├── BVN                       ├── Country of Citizenship
├── Street Address            ├── Country of Residence
├── City                      ├── Street Address
└── State                     ├── City + Postal Code (row)
                              ├── State
                              ├── Tax Residency Country
                              └── Tax ID (dynamic label)
```

**Files Modified:**
- `lib/features/kyc/presentation/pages/kyc_personal_info_page.dart` (completely rewritten, 545 lines)

---

### Task 8: Create Finnhub API Integration
**Objective:** Integrate supplementary market data API for analyst ratings, news, etc.

**What Was Done:**
- Created data models for all Finnhub response types
- Created remote data source with methods for each endpoint
- Implemented error handling with try/catch

**Models Created:**
```dart
// lib/features/trading/data/models/finnhub_models.dart
class AnalystRecommendation { ... }  // buy/hold/sell counts
class PriceTarget { ... }            // high/low/mean targets
class BasicFinancials { ... }        // P/E, EPS, market cap
class StockNews { ... }              // headline, source, time
class EarningsEvent { ... }          // date, EPS estimate
class CompanyProfile { ... }         // sector, exchange, description
```

**API Endpoints Implemented:**
```dart
// lib/features/trading/data/datasources/finnhub_remote_datasource.dart
Future<List<AnalystRecommendation>> getRecommendations(String symbol);
Future<PriceTarget> getPriceTarget(String symbol);
Future<BasicFinancials> getBasicFinancials(String symbol);
Future<List<StockNews>> getCompanyNews(String symbol, DateTime from, DateTime to);
Future<List<EarningsEvent>> getEarningsCalendar(String symbol);
Future<CompanyProfile> getCompanyProfile(String symbol);
Future<List<String>> getPeers(String symbol);
Future<Map<String, dynamic>> getQuote(String symbol);
```

**Files Created:**
- `lib/features/trading/data/models/finnhub_models.dart` (244 lines)
- `lib/features/trading/data/datasources/finnhub_remote_datasource.dart` (205 lines)

---

### Task 9: Create Stock Detail Widget Components
**Objective:** Build reusable UI components for enhanced stock detail page

**Components Created:**

| Widget | Purpose | Key Features |
|--------|---------|--------------|
| `AnalystRatingCard` | Show buy/hold/sell consensus | Colored distribution bars, consensus badge |
| `PriceTargetCard` | Show analyst price targets | Visual range indicator, current price marker |
| `KeyStatsGrid` | Display key financial metrics | 2-column grid, formatted values |
| `EventsSection` | Show upcoming earnings | Date, time (AMC/BMO), estimate |
| `AboutStockSection` | Company description | Expandable text, sector/exchange chips |
| `SimilarStocksRow` | Related stocks | Horizontal scroll, price change |
| `PriceAlertCard` | Manage price alerts | Add/remove, above/below toggle |
| `StockNewsWidgets` | News card and list | Image, headline, source, time ago |

**Files Created:**
- `lib/features/trading/presentation/widgets/analyst_rating_card.dart`
- `lib/features/trading/presentation/widgets/price_target_card.dart`
- `lib/features/trading/presentation/widgets/key_stats_grid.dart`
- `lib/features/trading/presentation/widgets/events_section.dart`
- `lib/features/trading/presentation/widgets/about_stock_section.dart`
- `lib/features/trading/presentation/widgets/similar_stocks_row.dart`
- `lib/features/trading/presentation/widgets/price_alert_card.dart`
- `lib/features/trading/presentation/widgets/stock_news_widgets.dart`

---

### Task 10: Redesign Stock Detail Page
**Objective:** Integrate all new widgets into tabbed stock detail page

**What Was Done:**
- Implemented 3-tab layout (Overview, Financials, News)
- Created collapsible app bar with stock info and chart
- Added period selector (1D, 1W, 1M, 3M, 1Y, ALL)
- Integrated all widget components
- Kept buy/sell buttons in persistent footer

**Tab Structure:**
```
Overview Tab:
├── Analyst Rating Card
├── Price Target Card
├── Key Stats Grid
├── Events Section
├── About Section
├── Price Alerts
└── Similar Stocks

Financials Tab:
├── Key Stats (detailed)
└── Placeholder for future charts

News Tab:
└── Stock News List
```

**Files Modified:**
- `lib/features/trading/presentation/pages/stock_detail_page.dart` (completely rewritten, 620 lines)

---

### Task 11: Update Router
**Objective:** Add routes for all new screens

**What Was Done:**
- Added imports for 5 new pages
- Added route constants to AppRoutes class
- Added GoRoute definitions for each new screen
- Updated KYC flow to include investor-profile and disclosures

**New Routes:**
```dart
static const String kycInvestorProfile = '/kyc/investor-profile';
static const String kycDisclosures = '/kyc/disclosures';
static const String orderHistory = '/wallet/orders';
static const String documents = '/documents';
```

**Files Modified:**
- `lib/app/router.dart` (added ~30 lines)

---

### Task 12: Fix Flutter Warnings
**Objective:** Clean up code quality issues

**What Was Done:**
- Added `http` package to dependencies
- Removed unused `_isSearching` field from `trade_page.dart`
- Removed unused `_handleBackspace` method from `verify_otp_page.dart`
- Removed unused `size` variable from `register_page.dart` and `verify_otp_page.dart`
- Verified build passes with `flutter build web`

**Remaining Warnings (minor):**
- Deprecated API usage (Flutter SDK version related, no functional impact)
- Test file import error (needs update after package rename)

---

### Task 13: Create Auto-Invest Feature (Dec 27)
**Objective:** Allow users to schedule recurring investments on D/W/M/Y basis

**What Was Done:**
- Created new auto-invest page with full scheduling UI
- Implemented frequency selector (Daily, Weekly, Monthly, Yearly)
- Added stock picker from watchlist/portfolio
- Day picker for weekly (Mon-Fri) and monthly (1,5,10,15,20,25)
- Active auto-invest cards with status and next date
- Benefits section explaining dollar-cost averaging

**Implementation Details:**
```dart
// Frequency options displayed as D, W, M, Y buttons
['Daily', 'Weekly', 'Monthly', 'Yearly']

// Auto-invest model structure
{
  'symbol': 'AAPL',
  'amount': 100.0,
  'frequency': 'Weekly',
  'nextDate': 'Mon, Dec 30',
  'isActive': true,
}
```

**Files Created:**
- `lib/features/portfolio/presentation/pages/auto_invest_page.dart` (580 lines)

---

### Task 14: Add Portfolio Chart Toggle (Dec 27)
**Objective:** Add line/pie chart toggle to show portfolio allocation vs growth

**What Was Done:**
- Added toggle button (line chart / pie chart icons)
- Line chart shows portfolio growth over time with period selector
- Pie chart shows allocation by stock with color-coded legend
- Holdings list now color-coded to match pie chart
- Activity tab includes auto-invest transactions
- Auto-invest button added to app bar

**Implementation Details:**
```dart
// Chart toggle state
bool _showPieChart = false;

// Holdings with colors for pie chart
final List<Map<String, dynamic>> _holdings = [
  {'symbol': 'AAPL', 'value': 933.20, 'color': Color(0xFF555555)},
  {'symbol': 'NVDA', 'value': 981.33, 'color': Color(0xFF76B900)},
  // ...
];
```

**Files Modified:**
- `lib/features/portfolio/presentation/pages/portfolio_page.dart` (completely rewritten, 510 lines)

---

### Task 15: Update Logo and App Icons (Dec 27)
**Objective:** Replace placeholder logos with actual Thryve branding

**What Was Done:**
- Added Thryve leaf icon to assets folder
- Added Thryve wordmark logo to assets folder
- Updated splash page to show leaf icon
- Updated login page to show leaf icon
- Generated app icons for iOS, Android, and Web
- Configured flutter_launcher_icons package

**Files Added:**
- `assets/images/thryve_icon.png` - Orange leaf icon
- `assets/images/thryve_logo.png` - Full wordmark

**Files Modified:**
- `lib/features/auth/presentation/pages/splash_page.dart`
- `lib/features/auth/presentation/pages/login_page.dart`
- `pubspec.yaml` (flutter_launcher_icons config)

---

## Architecture Decisions

### Why Flutter?
- Single codebase for iOS, Android, and Web
- Fast development with hot reload
- Rich widget library for complex financial UIs
- Strong typing with Dart prevents runtime errors

### Why go_router over Navigator 2.0?
- Declarative routing is easier to maintain
- Built-in deep linking support
- ShellRoute for persistent bottom navigation
- Type-safe route parameters

### Why flutter_bloc?
- Separation of business logic from UI
- Predictable state management
- Easy to test
- Good DevTools integration

### Why Finnhub for supplementary data?
- Free tier with 60 requests/minute
- Has analyst ratings, price targets, news
- DriveWealth doesn't provide these endpoints
- Simple REST API, no complex auth

### KYC Flow Design
```
5-Step KYC Flow:
1. Personal Info (name, address, tax ID)
2. Investor Profile (employment, income, experience)
3. Document Upload (ID verification)
4. Disclosures (agreement checkboxes)
5. Pending (verification status)
```

Rationale: Breaking into steps prevents form fatigue while collecting all DriveWealth-required data.

---

## File Structure

```
lib/
├── app/
│   ├── app.dart              # App configuration, theme setup
│   ├── router.dart           # All routes (35+ screens)
│   └── theme/
│       ├── colors.dart       # ThryveColors (accent: #f37021)
│       └── typography.dart   # ThryveTypography (Inter font)
│
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── splash_page.dart
│   │       │   ├── onboarding_page.dart
│   │       │   ├── login_page.dart
│   │       │   ├── register_page.dart
│   │       │   ├── verify_otp_page.dart
│   │       │   └── forgot_password_page.dart
│   │       └── widgets/
│   │           ├── auth_text_field.dart
│   │           └── social_login_button.dart
│   │
│   ├── kyc/
│   │   └── presentation/
│   │       └── pages/
│   │           ├── kyc_start_page.dart
│   │           ├── kyc_personal_info_page.dart    # Modified
│   │           ├── kyc_investor_profile_page.dart # NEW
│   │           ├── kyc_documents_page.dart
│   │           ├── kyc_disclosures_page.dart      # NEW
│   │           └── kyc_pending_page.dart
│   │
│   ├── portfolio/
│   │   └── presentation/
│   │       └── pages/
│   │           ├── home_page.dart
│   │           ├── portfolio_page.dart         # Modified (Dec 27)
│   │           └── auto_invest_page.dart       # NEW (Dec 27)
│   │
│   ├── trading/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── finnhub_models.dart        # NEW
│   │   │   └── datasources/
│   │   │       └── finnhub_remote_datasource.dart  # NEW
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── trade_page.dart
│   │       │   └── stock_detail_page.dart     # Modified
│   │       └── widgets/
│   │           ├── analyst_rating_card.dart   # NEW
│   │           ├── price_target_card.dart     # NEW
│   │           ├── key_stats_grid.dart        # NEW
│   │           ├── events_section.dart        # NEW
│   │           ├── about_stock_section.dart   # NEW
│   │           ├── similar_stocks_row.dart    # NEW
│   │           ├── price_alert_card.dart      # NEW
│   │           └── stock_news_widgets.dart    # NEW
│   │
│   ├── wallet/
│   │   └── presentation/
│   │       └── pages/
│   │           ├── wallet_page.dart
│   │           ├── deposit_page.dart
│   │           ├── withdraw_page.dart
│   │           ├── bank_accounts_page.dart
│   │           └── order_history_page.dart    # NEW
│   │
│   └── profile/
│       └── presentation/
│           └── pages/
│               ├── profile_page.dart
│               ├── settings_page.dart
│               ├── edit_profile_page.dart
│               ├── notifications_page.dart
│               ├── security_page.dart
│               ├── help_support_page.dart
│               ├── referrals_page.dart
│               ├── legal_documents_page.dart
│               └── documents_page.dart        # NEW
│
├── shared/
│   └── widgets/
│       ├── shimmer_loading.dart
│       ├── animated_button.dart
│       ├── animated_dialogs.dart
│       ├── animation_widgets.dart
│       ├── common_widgets.dart
│       └── placeholder_page.dart
│
└── main.dart

docs/
├── DEVELOPMENT_SUMMARY.md    # This file
├── architecture_diagram.mmd  # Mermaid diagram
└── reference_designs/        # UI mockup images
```

---

## API Integration Guide

### DriveWealth Integration (Not Yet Implemented)

**Base URL:** `https://api.drivewealth.io/v1` (production)  
**Sandbox:** `https://api.drivewealth.io/sandbox`

**Required Endpoints:**

1. **Users API** - Create/update user profiles
```
POST /users           # Create user
GET /users/{userID}   # Get user
PATCH /users/{userID} # Update user
```

2. **Accounts API** - Manage brokerage accounts
```
POST /accounts        # Create account
GET /accounts/{id}    # Get account details
```

3. **Orders API** - Execute trades
```
POST /orders          # Place order
GET /orders/{id}      # Get order status
DELETE /orders/{id}   # Cancel order
```

4. **Funding API** - Deposits/withdrawals
```
POST /funding/deposits      # Create deposit
POST /funding/withdrawals   # Create withdrawal
```

**Authentication:** Bearer token in header
```
Authorization: Bearer <access_token>
```

### Finnhub Integration (Models Created)

**Base URL:** `https://finnhub.io/api/v1`  
**API Key Location:** `lib/features/trading/data/datasources/finnhub_remote_datasource.dart` line 7

⚠️ **IMPORTANT:** Replace `YOUR_FINNHUB_API_KEY` before production!

**How to Get API Key:**
1. Go to https://finnhub.io/register
2. Create free account
3. Copy API key from dashboard
4. Update `finnhub_remote_datasource.dart`

**Rate Limits:** 60 requests/minute on free tier

---

## Security Considerations

### Current Implementation
- ✅ `flutter_secure_storage` for encrypted storage
- ✅ Biometric auth UI (ready, not connected)
- ✅ Input validation on forms
- ✅ No sensitive data in logs

### Before Production - MUST DO

1. **Move API Keys to Environment**
```dart
// Instead of:
final _apiKey = 'YOUR_FINNHUB_API_KEY';

// Use:
final _apiKey = const String.fromEnvironment('FINNHUB_API_KEY');
```

2. **Implement SSL Pinning**
```dart
// For DriveWealth and Finnhub connections
// Use package like http_certificate_pinning
```

3. **Backend Input Validation**
- Never trust client-side validation alone
- Validate all inputs on Lambda functions

4. **AWS Security**
- Use Cognito for JWT token validation
- Implement API Gateway rate limiting
- Store secrets in AWS Secrets Manager

### Sensitive Data Handling
- BVN, SSN, TIN - encrypted in secure storage
- Never log PII
- W-8BEN data stored only on DriveWealth

---

## Known Issues & Technical Debt

### Issues (Non-blocking)

| Issue | Location | Impact | Priority |
|-------|----------|--------|----------|
| Deprecated `value` on DropdownButtonFormField | Multiple KYC pages | None (works) | Low |
| Deprecated `activeColor` on Switch | settings_page, security_page | None (works) | Low |
| Test file import error | test/widget_test.dart | Tests don't run | Medium |
| WASM warnings | flutter_secure_storage_web | Web build still works | Low |

### Technical Debt

1. **Mock Data Everywhere**
   - All screens use mock data
   - Need to replace with real API calls
   - Pattern: Create repositories + BLoC for each feature

2. **No Error Handling UI**
   - Need loading states, error states, empty states
   - Create reusable error widget

3. **No Offline Support**
   - Consider caching stock data
   - Handle network errors gracefully

4. **No Unit Tests**
   - Add tests for models, repositories, BLoCs
   - Add widget tests for key flows

5. **No Analytics**
   - Add Firebase Analytics or Mixpanel
   - Track key user journeys

---

## How to Continue Development

### Immediate Next Steps

1. **Apply for DriveWealth Access**
   - Visit https://www.drivewealth.com/partners
   - Apply for sandbox/partner access
   - Get API credentials

2. **Set Up AWS Infrastructure**
   ```bash
   # Using AWS CDK (recommended)
   cd infrastructure/
   npm install
   cdk deploy --all
   ```
   
   Required AWS services:
   - Cognito User Pool (authentication)
   - API Gateway (REST endpoints)
   - Lambda (Python functions)
   - DynamoDB (user data)
   - Secrets Manager (API keys)

3. **Connect Authentication**
   - Replace mock auth in login_page.dart with Cognito
   - Store JWT in secure storage
   - Implement token refresh

4. **Implement BLoC Pattern**
   ```
   For each feature, create:
   lib/features/{feature}/
   ├── data/
   │   ├── repositories/
   │   │   └── {feature}_repository.dart
   │   └── datasources/
   │       └── {feature}_remote_datasource.dart
   ├── domain/
   │   ├── entities/
   │   └── usecases/
   └── presentation/
       ├── bloc/
       │   ├── {feature}_bloc.dart
       │   ├── {feature}_event.dart
       │   └── {feature}_state.dart
       ├── pages/
       └── widgets/
   ```

### Feature Priority Order

1. Authentication (Cognito)
2. KYC Flow (DriveWealth Users API)
3. Portfolio (DriveWealth Accounts API)
4. Trading (DriveWealth Orders API)
5. Wallet (Paystack + DriveWealth Funding)
6. Market Data (Finnhub integration)

---

## Running & Testing

### Prerequisites
- Flutter SDK 3.x installed
- Xcode (for iOS)
- Android Studio (for Android)
- Chrome (for web)

### Commands

```bash
# Navigate to project
cd ~/Desktop/stock_company/mobile_app

# Get dependencies
flutter pub get

# Run on Chrome (web)
flutter run -d chrome

# Run on iOS simulator
open -a Simulator
flutter run -d ios

# Run on Android emulator
flutter run -d android

# Build for production
flutter build web
flutter build ios --release
flutter build apk --release

# Run tests (once fixed)
flutter test

# Analyze code
flutter analyze
```

### Navigating the App

```
Splash (/) → Onboarding → Login → Verify OTP → KYC Flow → Home

From Home:
├── Portfolio tab → Holdings list
├── Trade tab → Search stocks → Stock Detail
├── Wallet tab → Deposit/Withdraw
└── Profile tab → Settings, Documents, etc.
```

---

## Contact & Resources

### Repository
`~/Desktop/stock_company/mobile_app`

### Documentation
- This file: `docs/DEVELOPMENT_SUMMARY.md`
- Architecture: `docs/architecture_diagram.mmd`
- Design references: `docs/reference_designs/`

### External Resources
- [DriveWealth Developer Docs](https://developer.drivewealth.com/)
- [Finnhub API Docs](https://finnhub.io/docs/api)
- [Flutter Documentation](https://docs.flutter.dev/)
- [go_router Guide](https://pub.dev/packages/go_router)
- [flutter_bloc Guide](https://bloclibrary.dev/)

---

*Last Updated: December 26, 2024*
