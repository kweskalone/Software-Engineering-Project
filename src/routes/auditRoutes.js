import express from 'express';
import { requireAuth } from '../middleware/auth.js';
import { requireRole } from '../middleware/requireRole.js';
import { listAuditLogs, getAuditLog, getAuditSummary } from '../controllers/auditController.js';

const router = express.Router();

// Get audit log summary (stats)
router.get('/summary', requireAuth, requireRole(['admin']), getAuditSummary);

// List audit logs (paginated, filtered)
router.get('/', requireAuth, requireRole(['admin']), listAuditLogs);

// Get specific audit log entry
router.get('/:id', requireAuth, requireRole(['admin']), getAuditLog);

export default router;
