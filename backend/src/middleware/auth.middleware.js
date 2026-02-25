const jwt = require('jsonwebtoken');

const verifyToken = (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];

    if (!token) {
      return res.status(401).json({
        error: 'Access token missing',
        statusCode: 401,
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.userId = decoded.userId || decoded.id || decoded.sub;
    req.userPhone = decoded.phoneNumber;
    
    next();
  } catch (error) {
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

    res.status(500).json({
      error: 'Token verification failed',
      statusCode: 500,
    });
  }
};

const verifyOptional = (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];

    if (token) {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      req.userId = decoded.userId || decoded.id || decoded.sub;
      req.userPhone = decoded.phoneNumber;
    }

    next();
  } catch (error) {
    // If token verification fails, continue without user info
    next();
  }
};

module.exports = {
  verifyToken,
  verifyOptional,
};
