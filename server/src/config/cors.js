/**
 * CORS Configuration
 * Configure Cross-Origin Resource Sharing for security
 */

// Base allowed origins for development
const allowedOrigins = [
    'http://localhost:3000',
    'http://localhost:5000',
    'http://10.0.2.2:3000', // Android emulator
    'http://10.0.2.2:5000', // Android emulator backend
    'http://127.0.0.1:3000',
    'http://127.0.0.1:5000',
];

// Add production origins from environment variable
if (process.env.ALLOWED_ORIGINS) {
    const productionOrigins = process.env.ALLOWED_ORIGINS.split(',').map(origin => origin.trim());
    allowedOrigins.push(...productionOrigins);
}

// Add Render URL if in production
if (process.env.NODE_ENV === 'production') {
    allowedOrigins.push('https://jeevan-dhara-s7wo.onrender.com');
}

export const corsOptions = {
    origin: (origin, callback) => {
        // Allow requests with no origin (mobile apps, Postman, etc.)
        if (!origin) return callback(null, true);

        if (allowedOrigins.indexOf(origin) !== -1) {
            callback(null, true);
        } else {
            console.warn(`CORS blocked origin: ${origin}`);
            console.log('Allowed origins:', allowedOrigins);
            callback(new Error('Not allowed by CORS'));
        }
    },
    credentials: true,
    optionsSuccessStatus: 200,
};
