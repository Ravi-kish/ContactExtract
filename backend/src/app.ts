import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';

import authRoutes from './routes/auth';
import uploadRoutes from './routes/uploads';
import searchRoutes from './routes/search';
import recordRoutes from './routes/records';
import healthRoutes from './routes/health';
import { errorHandler } from './middleware/errorHandler';

const app = express();

// Security
app.use(helmet({
  crossOriginEmbedderPolicy: false,
  contentSecurityPolicy: false,
}));

// CORS — allow configured origins
app.use(cors({
  origin: true, // reflect request origin — works for all domains
  credentials: true,
  methods: ['GET', 'POST', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// Handle preflight
app.options('*', cors());

// Rate limiting
app.use('/api/auth', rateLimit({ windowMs: 15 * 60 * 1000, max: 20 }));
app.use('/api/search', rateLimit({ windowMs: 60 * 1000, max: 100 }));

// Logging & parsing
app.use(morgan('combined'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/uploads', uploadRoutes);
app.use('/api/search', searchRoutes);
app.use('/api/records', recordRoutes);
app.use('/api/health', healthRoutes);

// Error handler
app.use(errorHandler);

export default app;
