/**
 * Sentry instrumentation file for ESM modules.
 * This file should be imported before the app starts using --import flag.
 * Usage: node --import ./src/instrument.js src/server.js
 */
import * as Sentry from '@sentry/node';

const dsn = process.env.SENTRY_DSN;

if (dsn) {
  Sentry.init({
    dsn,
    environment: process.env.NODE_ENV || 'development',
    
    // Performance monitoring - adjust sample rate for production
    tracesSampleRate: process.env.NODE_ENV === 'production' ? 0.2 : 1.0,
    
    // Set to true to capture 100% of errors
    sampleRate: 1.0,

    // Filter out sensitive data
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
}
