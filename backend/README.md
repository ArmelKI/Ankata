# Ankata Backend API

Production-ready Node.js API for Ankata App Passagers.

## Quick Start

### Prerequisites
- Node.js >= 16.0.0
- PostgreSQL >= 12
- npm >= 8.0.0
- Twilio Account (for WhatsApp OTP)
- Payment Gateway Accounts (Orange Money, Moov Money)

### Installation

1. Clone or navigate to the backend directory
2. Copy environment variables:
   ```bash
   cp .env.example .env
   ```

3. Install dependencies:
   ```bash
   npm install
   ```

4. Set up database:
   ```bash
   npm run db:migrate
   ```

5. Start development server:
   ```bash
   npm run dev
   ```

## Environment Variables

### Database
- `DATABASE_URL` - PostgreSQL connection string
- `POSTGRES_USER` - Database user
- `POSTGRES_PASSWORD` - Database password
- `POSTGRES_DB` - Database name

### Authentication
- `JWT_SECRET` - Secret key for JWT (min 32 characters)
- `JWT_EXPIRATION` - Token expiration time (default: 7d)

### SMS/WhatsApp
- `TWILIO_ACCOUNT_SID` - Twilio account SID
- `TWILIO_AUTH_TOKEN` - Twilio auth token
- `TWILIO_PHONE_NUMBER` - Twilio phone number
- `OTP_EXPIRATION_MINUTES` - OTP validity duration (default: 10)

### Payment Gateways
- `ORANGE_MONEY_API_KEY` - Orange Money API key
- `ORANGE_MONEY_SECRET` - Orange Money secret
- `MOOV_MONEY_API_KEY` - Moov Money API key
- `MOOV_MONEY_SECRET` - Moov Money secret
- `YENGA_PAY_API_KEY` - Yenga Pay API key

### AWS S3
- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key
- `AWS_REGION` - AWS region
- `S3_BUCKET_NAME` - S3 bucket name

### Application
- `NODE_ENV` - Environment (development, staging, production)
- `API_PORT` - Server port (default: 3000)
- `API_BASE_URL` - Base URL for API
- `FRONTEND_URL` - Frontend URL for CORS

## API Routes

### Authentication (`/api/auth`)
- `POST /request-otp` - Request OTP via WhatsApp
- `POST /verify-otp` - Verify OTP and get JWT token
- `GET /me` - Get current user (protected)
- `PUT /profile` - Update user profile (protected)

### Lines (`/api/lines`)
- `GET /` - Get all lines with filters
- `GET /search?originCity=X&destinationCity=Y&date=Z` - Search lines
- `GET /:lineId` - Get line details
- `GET /:lineId/schedules` - Get schedules for a line
- `GET /:lineId/stops` - Get stops for a line

### Companies (`/api/companies`)
- `GET /` - Get all companies
- `GET /:companyId` - Get company details
- `GET /slug/:slug` - Get company by slug
- `GET /:companyId/ratings` - Get company ratings

### Bookings (`/api/bookings`)
- `POST /` - Create booking (protected)
- `GET /my-bookings?status=upcoming|past` - Get user bookings (protected)
- `GET /:bookingId` - Get booking details (protected)
- `GET /code/:bookingCode` - Get booking by code
- `POST /:bookingId/cancel` - Cancel booking (protected)

### Ratings (`/api/ratings`)
- `POST /` - Create rating (protected)
- `GET /line/:lineId` - Get line ratings
- `GET /company/:companyId` - Get company ratings
- `POST /:ratingId/helpful` - Mark rating as helpful

### Payments (`/api/payments`)
- `POST /` - Initiate payment (protected)
- `POST /:paymentId/verify` - Verify payment
- `GET /:paymentId` - Get payment details (protected)

## Database Schema

### Tables
- **users** - User accounts
- **companies** - Transport companies
- **lines** - Transport routes
- **schedules** - Trip schedules
- **stops** - Route stops
- **bookings** - User bookings
- **ratings** - Trip ratings
- **payments** - Payment records
- **loyalty_points** - User loyalty points
- **otp_verifications** - OTP records
- **promo_codes** - Promotional codes
- **admin_users** - Admin accounts
- **audit_logs** - Activity logs

## Project Structure

```
src/
├── controllers/
│   ├── auth.controller.js
│   ├── lines.controller.js
│   ├── bookings.controller.js
│   ├── companies.controller.js
│   ├── ratings.controller.js
│   └── payments.controller.js
├── routes/
│   ├── auth.routes.js
│   ├── lines.routes.js
│   ├── bookings.routes.js
│   ├── companies.routes.js
│   ├── ratings.routes.js
│   └── payments.routes.js
├── models/
│   ├── User.js
│   ├── Company.js
│   ├── Line.js
│   ├── Schedule.js
│   ├── Booking.js
│   ├── Rating.js
│   ├── Payment.js
│   └── Otp.js
├── middleware/
│   └── auth.js
├── database/
│   ├── connection.js
│   ├── schema.js
│   └── migrations.js
├── utils/
│   └── helpers.js
├── services/
│   ├── sms.service.js
│   ├── payment.service.js
│   └── email.service.js
└── index.js
```

## Development

### Code Style
- Uses ESLint for linting
- Follow JavaScript best practices
- Use const/let (avoid var)
- Use async/await

### Logging
- Winston for logging
- Levels: error, warn, info, http, debug
- Logs to console in development
- Logs to files in production

### Error Handling
- Express async error handling
- Consistent error responses
- Proper HTTP status codes

## Testing

```bash
npm run test                 # Run tests
npm run test:watch         # Watch mode
npm run test:coverage      # Coverage report
```

## Deployment

### Docker
```dockerfile
FROM node:18

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY src ./src

EXPOSE 3000

CMD ["npm", "start"]
```

### Heroku
```bash
git push heroku main
```

### AWS EC2
1. SSH into instance
2. Clone repository
3. Install Node.js
4. Set environment variables
5. Run with PM2:
   ```bash
   npm install -g pm2
   pm2 start src/index.js --name "ankata-api"
   pm2 save
   ```

## Performance Optimization

- Database connection pooling
- Query pagination (max 100 items)
- Index on frequently queried columns
- Response compression with gzip
- CORS configured

## Security Best Practices

- Environment variables for secrets
- JWT token validation
- Rate limiting on OTP requests
- SQL injection prevention with parameterized queries
- CORS headers configured
- Helmet.js for security headers
- Password hashing with bcryptjs
- Input validation and sanitization

## Troubleshooting

### Database Connection Error
- Check DATABASE_URL format
- Verify PostgreSQL is running
- Ensure database exists

### OTP Not Sending
- Verify Twilio credentials
- Check phone number format (+226XXXXXXXXXX)
- Check Twilio account balance

### Payment Gateway Issues
- Verify API keys
- Check gateway documentation
- Review transaction logs

## Support

For issues and questions, contact: dev@axiane.agency

---

**Version:** 1.0.0  
**Last Updated:** 23 février 2026
