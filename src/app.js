import express from 'express';
import morgan from 'morgan';
import cors from 'cors';
import helmet from 'helmet';

// Import Sentry for error tracking
import { initSentry, setupSentryExpressErrorHandler } from './config/sentry.js';

// Initialize Sentry before other imports
initSentry();

// Import custom middleware
import { notFoundHandler, errorHandler } from './middleware/errorHandlers.js';
import { requestId } from './middleware/requestId.js';
import { generalLimiter } from './middleware/rateLimiter.js';
import { getSupabaseClients } from './config/supabaseClient.js';

// Import route modules
import authRoutes from './routes/authRoutes.js';
import hospitalRoutes from './routes/hospitalRoutes.js';
import wardRoutes from './routes/wardRoutes.js';
import admissionRoutes from './routes/admissionRoutes.js';
import dischargeRoutes from './routes/dischargeRoutes.js';
import referralRoutes from './routes/referralRoutes.js';
import userRoutes from './routes/userRoutes.js';
import patientRoutes from './routes/patientRoutes.js';
import bedRoutes from './routes/bedRoutes.js';
import dashboardRoutes from './routes/dashboardRoutes.js';
import auditRoutes from './routes/auditRoutes.js';
import contactRoutes from './routes/contactRoutes.js';

const app = express();

// Security middleware
app.use(helmet());

app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  methods: ['GET', 'POST', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Request-Id'],
  exposedHeaders: ['X-Request-Id', 'RateLimit-Limit', 'RateLimit-Remaining', 'RateLimit-Reset'],
  credentials: true,
  maxAge: 86400 // 24 hours
}));

// Rate limiting - applies to all routes except health checks
app.use(generalLimiter);

// Body parser
app.use(express.json({ limit: '1mb' }));

// Request ID middleware
app.use(requestId);

// Logging middleware
morgan.token('request-id', (req) => req.requestId || '-');
app.use(morgan(':method :url :status :response-time ms - req_id=:request-id'));

// Simple health check
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', service: 'hospital-bed-management-backend' });
});

// Deep health check - verifies database connectivity
app.get('/health/ready', async (_req, res) => {
  try {
    const { supabaseService, supabaseAnon } = getSupabaseClients();
    const db = supabaseService || supabaseAnon;

    // Simple query to verify DB connectivity
    const { error } = await db.from('hospitals').select('id').limit(1);
    
    if (error) {
      return res.status(503).json({
        status: 'unhealthy',
        service: 'hospital-bed-management-backend',
        database: 'disconnected',
        error: 'Database query failed'
      });
    }

    return res.status(200).json({
      status: 'healthy',
      service: 'hospital-bed-management-backend',
      database: 'connected',
      timestamp: new Date().toISOString()
    });
  } catch {
    return res.status(503).json({
      status: 'unhealthy',
      service: 'hospital-bed-management-backend',
      database: 'disconnected',
      error: 'Health check failed'
    });
  }
});

// Sentry test route
app.get("/debug-sentry", function mainHandler(_req, _res) {
  throw new Error("My first Sentry error!");
});

// Mount route modules
app.use('/auth', authRoutes);
app.use('/hospitals', hospitalRoutes);
app.use('/wards', wardRoutes);
app.use('/admissions', admissionRoutes);
app.use('/discharges', dischargeRoutes);
app.use('/referrals', referralRoutes);
app.use('/users', userRoutes);
app.use('/patients', patientRoutes);
app.use('/beds', bedRoutes);
app.use('/dashboard', dashboardRoutes);
app.use('/audit-logs', auditRoutes);
app.use('/contact', contactRoutes);

// 404 and error handling middleware
app.use(notFoundHandler);

// Sentry error handler - must be before custom error handler (Sentry v8+ API)
setupSentryExpressErrorHandler(app);

app.use(errorHandler);

export default app;
