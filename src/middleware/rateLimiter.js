import rateLimit from 'express-rate-limit';

// Rate limiting middleware configuration

// General API rate limit - applies to all routes
const generalLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 100, // 100 requests per minute per IP
  standardHeaders: true, // Return rate limit info in RateLimit-* headers
  legacyHeaders: false, // Disable X-RateLimit-* headers
  message: {
    error: 'Too many requests, please try again later',
    retry_after_seconds: 60
  }
  // Using default keyGenerator which properly handles IPv6
});

// Strict rate limit for authentication endpoints
const authLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 10, // 10 requests per minute per IP (login attempts)
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    error: 'Too many authentication attempts, please try again later',
    retry_after_seconds: 60
  },
  skipSuccessfulRequests: false // Count all requests, even successful ones
});

// Very strict rate limit for password reset (prevent email spam)
const passwordResetLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 3, // 3 requests per 15 minutes per IP
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    error: 'Too many password reset requests, please try again in 15 minutes',
    retry_after_seconds: 900
  }
});

// Rate limit for user creation (prevent spam accounts)
const createUserLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 5, // 5 user creations per minute
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    error: 'Too many user creation attempts, please try again later',
    retry_after_seconds: 60
  }
});

export { generalLimiter, authLimiter, passwordResetLimiter, createUserLimiter };
