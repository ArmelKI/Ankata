# CORS & Security Configuration Guide

## Overview
This document provides the complete CORS (Cross-Origin Resource Sharing) and security hardening configuration for Ankata Backend.

## Current CORS Configuration

The CORS middleware is configured in `src/index.js` to allow requests from:

```javascript
cors({
  origin: [
    'http://localhost:3001',      // Local dev frontend
    'http://localhost:8081',      // Flutter dev server
    'http://localhost:8080',      // Alternative dev port
    process.env.FRONTEND_URL,     // Configured via env
    ...(process.env.NODE_ENV === 'production' ? ['https://*.ankata.bf'] : []),
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  exposedHeaders: ['X-Total-Count', 'X-Page-Count'],
})
```

## Environment Variables Required

```env
# Development
NODE_ENV=development
FRONTEND_URL=http://localhost:3001

# Production
NODE_ENV=production
FRONTEND_URL=https://app.ankata.bf
```

## Production CORS Setup

### 1. Domain Configuration

For production, update `src/index.js`:

```javascript
const allowedOrigins = {
  development: [
    'http://localhost:3001',
    'http://localhost:8081',
    'http://localhost:8080',
  ],
  production: [
    'https://app.ankata.bf',
    'https://admin.ankata.bf',
    'https://dash.ankata.bf',
  ],
};

app.use(cors({
  origin: process.env.NODE_ENV === 'production' 
    ? allowedOrigins.production 
    : allowedOrigins.development,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-API-Key'],
  exposedHeaders: ['X-Total-Count', 'X-Page-Count'],
  maxAge: 86400, // 24 hours
}));
```

### 2. HTTPS / SSL Configuration

In production, ensure:

1. **nginx/reverse proxy** enforces SSL:
```nginx
server {
  listen 443 ssl http2;
  server_name api.ankata.bf;
  
  ssl_certificate /etc/letsencrypt/live/api.ankata.bf/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/api.ankata.bf/privkey.pem;
  
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_ciphers HIGH:!aNULL:!MD5;
  ssl_prefer_server_ciphers on;
  
  location / {
    proxy_pass http://localhost:3000;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_set_header X-Forwarded-Proto https;
  }
}

# Redirect HTTP to HTTPS
server {
  listen 80;
  server_name api.ankata.bf;
  return 301 https://$server_name$request_uri;
}
```

### 3. Helmet.js Security Headers

Already configured in `src/index.js`:

```javascript
app.use(helmet()); // Adds security headers like CSP, X-Frame-Options, etc.
```

Additional hardening:

```javascript
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
  hsts: {
    maxAge: 31536000, // 1 year
    includeSubDomains: true,
    preload: true,
  },
  frameguard: { action: 'deny' },
  noSniff: true,
  referrerPolicy: { policy: 'strict-origin-when-cross-origin' },
}));
```

## Testing CORS

### Test 1: OPTIONS Preflight Request
```bash
curl -i -X OPTIONS \
  -H "Origin: https://app.ankata.bf" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type" \
  https://api.ankata.bf/api/bookings
```

Expected response:
```
Access-Control-Allow-Origin: https://app.ankata.bf
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, PATCH
Access-Control-Allow-Headers: Content-Type, Authorization
```

### Test 2: Blocked CORS Request
```bash
curl -i -X GET \
  -H "Origin: https://unauthorized-domain.com" \
  https://api.ankata.bf/api/users
```

Expected: `403 Forbidden` or no CORS headers

### Test 3: Valid Request
```bash
curl -i -X GET \
  -H "Origin: https://app.ankata.bf" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  https://api.ankata.bf/api/users/me
```

## API Rate Limiting (Optional Enhancement)

Add rate limiting to prevent abuse:

```bash
npm install express-rate-limit
```

In `src/index.js`:

```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.',
});

app.use('/api/', limiter);

// Stricter limit for auth endpoints
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5, // 5 requests per 15 minutes
});

app.use('/api/auth/login', authLimiter);
app.use('/api/auth/register', authLimiter);
```

## Flutter Client Configuration

In `lib/config/app_constants.dart`:

```dart
class AppConstants {
  static const String apiBaseUrl = 'https://api.ankata.bf';
  
  // For development
  // static const String apiBaseUrl = 'http://localhost:3000';
}
```

## Security Checklist

- ✅ JWT enabled on all protected routes
- ✅ CORS configured for production domains
- ✅ HTTPS/SSL enforced
- ✅ Security headers via Helmet.js
- ✅ Rate limiting recommended
- ✅ Supabase RLS policies enabled
- ✅ .env variables secured (never commit .env file)
- ⚠️ TODO: API key rotation policy
- ⚠️ TODO: Request signature verification (optional)
- ⚠️ TODO: DDoS protection (Cloudflare)

## Deployment Checklist

1. Update `.env` with production values
2. Set `NODE_ENV=production`
3. Configure SSL certificates
4. Set FRONTEND_URL to production domain
5. Test CORS with curl commands above
6. Deploy to production server
7. Monitor API logs for CORS rejections
8. Set up monitoring/alerting (e.g., Sentry, DataDog)

## Troubleshooting

### "No 'Access-Control-Allow-Origin' header"
- Check CORS origin configuration
- Verify frontend domain is in allowedOrigins list
- Test with curl to confirm headers are present

### "CORS policy: Credentials mode is 'include', but 'Access-Control-Allow-Credentials' is missing"
- Ensure `credentials: true` is set in CORS config
- Verify Authorization header is being sent

### "OPTIONS request returns 404"
- Ensure routes are defined before CORS middleware (if custom)
- Check that preflight requests are not being blocked

## References

- [MDN: CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
- [Express CORS Package](https://github.com/expressjs/cors)
- [Helmet.js](https://helmetjs.github.io/)
- [OWASP: CORS](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Origin_Resource_Sharing_CheatSheet.html)
