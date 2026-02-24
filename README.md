# Ankata App Passagers
Transport booking application for Burkina Faso connecting passengers with transport companies.

## Project Structure

```
ankata/
├── backend/                 # Node.js + Express API
│   ├── src/
│   │   ├── controllers/    # Business logic controllers
│   │   ├── routes/         # API route definitions
│   │   ├── models/         # Database models
│   │   ├── middleware/     # Authentication & validation
│   │   ├── services/       # External services (payment, SMS)
│   │   ├── database/       # Database schema & connection
│   │   ├── utils/          # Utility functions
│   │   └── index.js        # Express server setup
│   ├── package.json
│   ├── .env.example
│   └── README.md
│
├── mobile/                  # Flutter Mobile App
│   ├── lib/
│   │   ├── config/         # Theme, routing, constants
│   │   ├── models/         # Data models
│   │   ├── providers/      # State management (Riverpod)
│   │   ├── services/       # API client, local services
│   │   ├── screens/        # UI screens
│   │   ├── widgets/        # Reusable components
│   │   ├── utils/          # Utility functions
│   │   └── main.dart
│   ├── assets/
│   ├── pubspec.yaml
│   └── README.md
│
└── README.md
```

## Backend Setup

### Requirements
- Node.js >= 16
- PostgreSQL >= 12
- npm >= 8

### Installation

```bash
cd backend
cp .env.example .env
npm install
```

### Configuration

Edit `.env` with your environment variables:

```env
DATABASE_URL=postgresql://user:password@localhost:5432/ankata_db
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-key
JWT_SECRET=your-secret-key-32-chars-min
TWILIO_ACCOUNT_SID=your-twilio-sid
TWILIO_AUTH_TOKEN=your-twilio-token
TWILIO_PHONE_NUMBER=+1234567890
ORANGE_MONEY_API_KEY=your-key
MOOV_MONEY_API_KEY=your-key
```

### Database Setup

```bash
# Initialize database schema
npm run db:migrate
```

### Start Development Server

```bash
npm run dev
```

Server will run on `http://localhost:3000`

## Mobile App Setup

### Requirements
- Flutter >= 3.0
- Dart >= 3.0
- Android SDK or Xcode

### Installation

```bash
cd mobile
flutter pub get
```

### Configuration

Update `lib/config/constants.dart` with your API base URL:

```dart
static const String apiBaseUrl = 'http://your-api-url:3000/api';
```

### Run Development App

```bash
# iOS
flutter run -d iPhone

# Android
flutter run -d android

# Web (experimental)
flutter run -d chrome
```

## API Documentation

### Authentication Endpoints

#### Request OTP
```
POST /api/auth/request-otp
Body: { "phoneNumber": "+226XXXXXXXXXX" }
```

#### Verify OTP
```
POST /api/auth/verify-otp
Body: { 
  "phoneNumber": "+226XXXXXXXXXX",
  "otp": "123456"
}
Returns: { token, user }
```

#### Get Current User
```
GET /api/auth/me
Headers: Authorization: Bearer <token>
```

### Lines Endpoints

#### Search Lines
```
GET /api/lines/search?originCity=Ouagadougou&destinationCity=Bobo-Dioulasso&date=2026-03-01
```

#### Get Line Details
```
GET /api/lines/:lineId?date=2026-03-01
```

### Bookings Endpoints

#### Create Booking
```
POST /api/bookings
Headers: Authorization: Bearer <token>
Body: {
  "scheduleId": "uuid",
  "lineId": "uuid",
  "companyId": "uuid",
  "passengerName": "John Doe",
  "passengerPhone": "+226XXXXXXXXXX",
  "departureDate": "2026-03-01",
  "luggageWeightKg": 0,
  "paymentMethod": "orange_money_bf"
}
```

#### Get My Bookings
```
GET /api/bookings/my-bookings?status=upcoming
Headers: Authorization: Bearer <token>
```

#### Cancel Booking
```
POST /api/bookings/:bookingId/cancel
Headers: Authorization: Bearer <token>
Body: { "reason": "User cancelled" }
```

### Companies Endpoints

#### Get All Companies
```
GET /api/companies?limit=20&offset=0
```

#### Get Company Details
```
GET /api/companies/:companyId
```

#### Get Company Ratings
```
GET /api/companies/:companyId/ratings?limit=10&offset=0
```

### Ratings Endpoints

#### Create Rating
```
POST /api/ratings
Headers: Authorization: Bearer <token>
Body: {
  "bookingId": "uuid",
  "companyId": "uuid",
  "lineId": "uuid",
  "rating": 5,
  "punctualityRating": 5,
  "comfortRating": 5,
  "staffRating": 5,
  "cleanlinessRating": 5,
  "comment": "Great service!"
}
```

### Payments Endpoints

#### Initiate Payment
```
POST /api/payments
Headers: Authorization: Bearer <token>
Body: {
  "bookingId": "uuid",
  "paymentMethod": "orange_money_bf"
}
```

## Database Schema

### Key Tables

- **users** - User profiles
- **companies** - Transport companies
- **lines** - Transport routes
- **schedules** - Trip schedules
- **bookings** - User bookings
- **ratings** - Trip ratings
- **payments** - Payment transactions
- **otp_verifications** - OTP records

## Features Implemented

### Authentication
- ✅ WhatsApp OTP verification
- ✅ JWT token management
- ✅ User profile management

### Search & Discovery
- ✅ Line search by origin/destination/date
- ✅ Schedule availability
- ✅ Company information & ratings
- ✅ Route stops

### Bookings
- ✅ Create bookings
- ✅ Manage bookings (upcoming & past)
- ✅ Cancel bookings
- ✅ Booking confirmation

### Payments
- ✅ Payment initiation
- ✅ Payment status tracking
- ✅ Multiple payment methods (Orange Money, Moov Money)

### Ratings
- ✅ Create ratings with verification
- ✅ Company statistics
- ✅ Helpful ratings tracking

## Mobile App Features

### Screens Implemented
- ✅ Splash Screen
- ✅ Onboarding
- ✅ Phone Authentication
- ✅ OTP Verification
- ✅ Home Screen with Search
- ✅ Trip Search Results
- ✅ Trip Details
- ✅ Booking Flow
- ✅ Booking Confirmation
- ✅ My Bookings
- ✅ Company Details
- ✅ Rating Screen
- ✅ User Profile

### State Management
- Riverpod for reactive state management
- Provider pattern for service injection

### Navigation
- Go Router for type-safe routing
- Deep linking support

## Testing

### Backend Tests
```bash
npm run test
```

### Mobile Tests
```bash
flutter test
```

## Deployment

### Backend (Node.js)
```bash
# Build for production
npm install --production

# Run
npm start
```

### Mobile
```bash
# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

## Security Considerations

- JWT tokens with 7-day expiration
- OTP with 10-minute expiration
- Rate limiting on OTP requests (3 attempts)
- CORS configured for specific origins
- Helmet.js for secure headers
- Input validation and sanitization
- Password hashing with bcryptjs

## Performance

- Pagination on list endpoints
- Database indexes on frequently queried fields
- Connection pooling for PostgreSQL
- Response caching where applicable

## Technologies Used

### Backend
- Node.js & Express
- PostgreSQL
- Docker (optional)
- JWT for authentication
- Twilio for WhatsApp

### Mobile
- Flutter
- Dart
- Riverpod (state management)
- Go Router (navigation)
- Dio (HTTP client)

## Contributing

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## Roadmap

### Phase 1: MVP (Current)
- [x] Authentication & OTP
- [x] Search & Discovery
- [x] Bookings
- [x] Basic Payments
- [x] Ratings

### Phase 2: Enhancement
- [ ] Loyalty Points System
- [ ] Advanced Filters
- [ ] Seat Selection
- [ ] Multi-language Support
- [ ] Push Notifications

### Phase 3: Scaling
- [ ] Admin Dashboard
- [ ] Company Portal
- [ ] Analytics
- [ ] Real-time Updates
- [ ] Performance Optimization

## License

Proprietary © Axiane Agency 2026

## Contact

dev@axiane.agency

---

**Last Updated:** 23 février 2026