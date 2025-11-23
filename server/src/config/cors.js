/**
 * CORS Configuration
 * Configure Cross-Origin Resource Sharing for security
 */

const allowedOrigins = [
    'http://localhost:3000',
    'http://10.0.2.2:3000', // Android emulator
    'http://127.0.0.1:3000',
    // Add your production domains here
    // 'https://jeevandhara.com',
];

export const corsOptions = {
    origin: (origin, callback) => {
        // Allow requests with no origin (mobile apps, Postman, etc.)
        if (!origin) return callback(null, true);

        if (allowedOrigins.indexOf(origin) !== -1) {
            callback(null, true);
        } else {
            callback(new Error('Not allowed by CORS'));
        }
    },
    credentials: true,
    optionsSuccessStatus: 200,
};
