import createError from 'http-errors';

/**
 * Middleware to protect seeding endpoint with SEEDING_KEY
 */
export const validateSeedingKey = (req, res, next) => {
  const providedKey = req.headers['x-seeding-key'] || req.body.seedingKey || req.query.seedingKey;
  const expectedKey = process.env.SEEDING_KEY;

  if (!expectedKey) {
    return next(createError(500, 'SEEDING_KEY not configured on server'));
  }

  if (!providedKey || providedKey !== expectedKey) {
    return next(createError(401, 'Invalid or missing seeding key'));
  }

  next();
};

