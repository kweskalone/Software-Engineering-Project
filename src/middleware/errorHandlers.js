/**
 * Custom error class for application errors
 * Provides consistent error structure with status codes
 */
class AppError extends Error {
  constructor(message, statusCode = 500, details = null) {
    super(message);
    this.statusCode = statusCode;
    this.publicMessage = message;
    this.details = details;
    this.isOperational = true;
    
    Error.captureStackTrace(this, this.constructor);
  }
}

function notFoundHandler(req, res) {
  res.status(404).json({ error: 'Not found', request_id: req.requestId });
}

// Centralized error formatter
function errorHandler(err, req, res, _next) {
  console.error(err);

  // Attach request context for Sentry (if available)
  if (req.requestId) {
    err.requestId = req.requestId;
  }

  const status = err.statusCode || 500;
  const message = err.publicMessage || 'Internal server error';

  const payload = {
    error: message,
    request_id: req.requestId
  };

  if (err.details) {
    payload.details = err.details;
  }
  res.status(status).json(payload);
}

export { AppError, notFoundHandler, errorHandler };
