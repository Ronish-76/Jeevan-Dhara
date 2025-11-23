import createError from 'http-errors';

export const notFoundHandler = (req, res, _next) => {
  _next(createError(404, `Route ${req.originalUrl} not found`));
};

export const errorHandler = (err, req, res, _next) => {
  const statusCode = err.status || err.statusCode || 500;
  res.status(statusCode).json({
    success: false,
    message: err.message || 'Internal Server Error',
    ...(process.env.NODE_ENV !== 'production' && { stack: err.stack }),
  });
};

