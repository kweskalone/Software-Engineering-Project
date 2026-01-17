import { randomUUID } from 'crypto';

function requestId(req, res, next) {
  const incoming = req.headers['x-request-id'];
  const id = typeof incoming === 'string' && incoming.trim() ? incoming : randomUUID();
  req.requestId = id;
  res.setHeader('X-Request-Id', id);
  next();
}

export { requestId };
