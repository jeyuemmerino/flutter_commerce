import express from 'express';
import cors from 'cors';
import productsRoutes from './routes/products.routes.js';
import ordersRoutes from './routes/orders.routes.js';
import couponsRoutes from './routes/coupons.routes.js';
import analyticsRoutes from './routes/analytics.routes.js';
import aiRoutes from './routes/ai.routes.js';

const app = express();

app.use(cors());
app.use(express.json({ limit: '1mb' }));

app.get('/health', (_, res) => {
    res.json({ status: 'ok', service: 'local-marketplace-api' });
});

app.use('/api/products', productsRoutes);
app.use('/api/orders', ordersRoutes);
app.use('/api/coupons', couponsRoutes);
app.use('/api/analytics', analyticsRoutes);
app.use('/api/ai', aiRoutes);

app.use((_, res) => {
    res.status(404).json({ message: 'Route not found' });
});

export default app;