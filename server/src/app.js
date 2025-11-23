import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import mongoSanitize from 'express-mongo-sanitize';
import { corsOptions } from './config/cors.js';
import mapRoutes from './routes/map.routes.js';
import requestRoutes from './routes/request.routes.js';
import bloodRequestRoutes from './routes/bloodRequest.routes.js';
import locationRoutes from './routes/location.routes.js';
import donorRoutes from './routes/donor.routes.js';
import routeRoutes from './routes/route.routes.js';
import userRoutes from './routes/user.routes.js';
import { notFoundHandler, errorHandler } from './middlewares/errorHandler.js';

const app = express();

app.use(cors(corsOptions));
app.use(helmet());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(mongoSanitize());

if (process.env.NODE_ENV !== 'production') {
  app.use(morgan('dev'));
}

app.get('/api/health', (req, res) =>
  res.json({ status: 'ok', timestamp: new Date().toISOString() }),
);

app.use('/api/users', userRoutes);
app.use('/api/map', mapRoutes);
app.use('/api/requests', requestRoutes);
app.use('/api/blood-requests', bloodRequestRoutes);
app.use('/api/locations', locationRoutes);
app.use('/api/donor', donorRoutes);
app.use('/api/routes', routeRoutes);

app.use(notFoundHandler);
app.use(errorHandler);

export default app;
