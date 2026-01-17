function requireRole(allowedRoles) {
  const allowed = new Set(allowedRoles);

  return function roleMiddleware(req, res, next) {
    const role = req.auth?.role;
    if (!role) return res.status(401).json({ error: 'Unauthenticated' });
    if (!allowed.has(role)) return res.status(403).json({ error: 'Forbidden' });
    return next();
  };
}

export { requireRole };
