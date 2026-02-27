require('dotenv').config();
require('express-async-errors');

// Validate environment variables on startup
const { validateEnv } = require('./config/validate-env');
validateEnv();

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const bodyParser = require('body-parser');
const winston = require('winston');

// Import middleware
const { verifyToken, verifyOptional } = require('./middleware/auth.middleware');

// Import routes
const authRoutes = require('./routes/auth.routes');
const linesRoutes = require('./routes/lines.routes');
const bookingsRoutes = require('./routes/bookings.routes');
const companiesRoutes = require('./routes/companies.routes');
const ratingsRoutes = require('./routes/ratings.routes');
const paymentsRoutes = require('./routes/payments.routes');
const notificationsRoutes = require('./routes/notifications.routes');
const favoritesRoutes = require('./routes/favorites.routes');
const sotracoRoutes = require('./routes/sotraco.routes');
const uploadRoutes = require('./routes/upload.routes');
const usersRoutes = require('./routes/users.routes');
const passengersRoutes = require('./routes/passengers.routes');
const promoCodesRoutes = require('./routes/promocodes.routes');
const walletRoutes = require('./routes/wallet.routes');
const priceAlertsRoutes = require('./routes/price_alerts.routes');
const feedbackRoutes = require('./routes/feedback.routes');

// Initialize Express app
const app = express();

// Logger configuration
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.json(),
  defaultMeta: { service: 'ankata-backend' },
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' }),
    new winston.transports.Console({
      format: winston.format.simple(),
    }),
  ],
});

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.NODE_ENV === 'production'
    ? [
        'https://ankata.app',
        'https://www.ankata.app',
        'https://ankata.bf',
        'https://www.ankata.bf',
        /^https:\/\/.*\.ankata\.(app|bf)$/,
      ]
    : [
        'http://localhost:3001',
        'http://localhost:8081',
        'http://localhost:8080',
        process.env.FRONTEND_URL || 'http://localhost:3001',
      ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  exposedHeaders: ['X-Total-Count', 'X-Page-Count'],
}));
app.use(bodyParser.json({ limit: '10mb' }));
app.use(bodyParser.urlencoded({ limit: '10mb', extended: true }));

// Serve static files (uploads)
const path = require('path');
app.use('/uploads', express.static(path.join(__dirname, '../public/uploads')));

// Request logging middleware
app.use((req, res, next) => {
  logger.info(`${req.method} ${req.path}`);
  next();
});

// Root redirect
app.get('/', (req, res) => {
  res.status(200).json({
    message: 'Bienvenue sur Ankata Backend',
    api: '/api',
    health: '/health',
    documentation: 'Consultez le README pour plus de détails',
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
  });
});

// API Routes
// Public routes (no JWT required)
app.use('/api/auth', authRoutes);

// Protected routes (JWT required)
app.use('/api/lines', verifyOptional, linesRoutes);
app.use('/api/bookings', verifyToken, bookingsRoutes);
app.use('/api/companies', verifyOptional, companiesRoutes);
app.use('/api/ratings', verifyToken, ratingsRoutes);
app.use('/api/payments', verifyToken, paymentsRoutes);
app.use('/api/notifications', verifyToken, notificationsRoutes);
app.use('/api/favorites', verifyToken, favoritesRoutes);
app.use('/api/sotraco', verifyOptional, sotracoRoutes);
app.use('/api/upload', verifyToken, uploadRoutes);
app.use('/api/users', verifyToken, usersRoutes);
app.use('/api/passengers', verifyToken, passengersRoutes);
app.use('/api/promocodes', verifyToken, promoCodesRoutes);
app.use('/api/wallet', verifyToken, walletRoutes);
app.use('/api/price-alerts', verifyToken, priceAlertsRoutes);
app.use('/api/feedback', verifyToken, feedbackRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Route not found',
    path: req.path,
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  logger.error({
    message: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
  });

  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal Server Error';

  res.status(statusCode).json({
    error: message,
    statusCode,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
});

// Start server
const PORT = process.env.PORT || process.env.API_PORT || 3000;
app.listen(PORT, () => {
  logger.info(`Ankata Backend running on port ${PORT}`);
  logger.info(`Environment: ${process.env.NODE_ENV || 'development'}`);
  logger.info(`Database: ${process.env.DATABASE_URL ? 'Connected' : 'Not configured'}`);
});

module.exports = app;
