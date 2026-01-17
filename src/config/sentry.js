import * as Sentry from '@sentry/node';

/**
 * Initialize Sentry error tracking and performance monitoring.
 * Note: For ESM modules, Sentry is initialized in instrument.js via --import flag.
 * This function provides a fallback and logs the status.
 */
function initSentry() {
  const dsn = process.env.SENTRY_DSN;

  if (!dsn) {
    console.warn('⚠️  SENTRY_DSN not set - Sentry monitoring disabled');
    return false;
  }

  // Check if Sentry was already initialized via instrument.js
  if (Sentry.getClient()) {
    console.log('✅ Sentry initialized successfully');
    return true;
  }

  // Fallback initialization (if not using --import flag)
  Sentry.init({
    dsn,
    environment: process.env.NODE_ENV || 'development',
    tracesSampleRate: process.env.NODE_ENV === 'production' ? 0.2 : 1.0,
    sampleRate: 1.0,
    beforeSend(event) {
      if (event.request?.headers) {
        delete event.request.headers.authorization;
        delete event.request.headers.cookie;
      }
      return event;
    },
    initialScope: {
      tags: {
        service: 'hospital-bed-management-backend',
      },
    },
  });

  console.log('✅ Sentry initialized successfully');
  return true;
}

/**
 * Setup Sentry for Express app (call after creating express app)
 * For Sentry v8+, we use setupExpressErrorHandler
 */
function setupSentryExpressErrorHandler(app) {
  if (!process.env.SENTRY_DSN) return;
  Sentry.setupExpressErrorHandler(app);
}

/**
 * Attach user context to Sentry for better error tracking.
 * Call this after user authentication.
 */
function setSentryUser(user) {
  if (!process.env.SENTRY_DSN) return;
  
  Sentry.setUser({
    id: user.id,
    email: user.email,
    username: user.full_name,
    hospital_id: user.hospital_id,
    role: user.role,
  });
}

/**
 * Clear user context (e.g., on logout)
 */
function clearSentryUser() {
  if (!process.env.SENTRY_DSN) return;
  Sentry.setUser(null);
}

/**
 * Add custom context/tags to Sentry events
 */
function setSentryContext(name, context) {
  if (!process.env.SENTRY_DSN) return;
  Sentry.setContext(name, context);
}

/**
 * Capture a message manually
 */
function captureMessage(message, level = 'info') {
  if (!process.env.SENTRY_DSN) return;
  Sentry.captureMessage(message, level);
}

/**
 * Capture an exception manually
 */
function captureException(error, context = {}) {
  if (!process.env.SENTRY_DSN) return;
  Sentry.captureException(error, { extra: context });
}

export {
  Sentry,
  initSentry,
  setupSentryExpressErrorHandler,
  setSentryUser,
  clearSentryUser,
  setSentryContext,
  captureMessage,
  captureException,
};
