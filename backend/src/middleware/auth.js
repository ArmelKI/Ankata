const jwt = require('jsonwebtoken');
const winston = require('winston');

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.Console({
      format: winston.format.simple(),
    }),
  ],
});

const authMiddleware = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        error: 'Unauthorized. Token not provided.',
        statusCode: 401,
      });
    }

    const token = authHeader.substring(7);
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    req.user = decoded;
    next();
  } catch (error) {
    logger.error('Authentication error:', error);

    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        error: 'Token expired',
        statusCode: 401,
      });
    }

    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        error: 'Invalid token',
        statusCode: 401,
      });
    }

    res.status(401).json({
      error: 'Authentication failed',
      statusCode: 401,
    });
  }
};

const optionalAuth = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      req.user = decoded;
    }

    next();
  } catch (error) {
    logger.debug('Optional auth provided but invalid:', error.message);
    next();
  }
};

module.exports = {
  authMiddleware,
  optionalAuth,
};
