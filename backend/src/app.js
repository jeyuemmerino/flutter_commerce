import express from 'express';
import cors from 'cors';
import path from 'path';
import { fileURLToPath } from 'url';
import authRoutes from './routes/auth.routes.js';
import shopsRoutes from './routes/shops.routes.js';
import productsRoutes from './routes/products.routes.js';
import cartRoutes from './routes/cart.routes.js';
import ordersRoutes from './routes/orders.routes.js';
import { uploadDir } from './config/upload.js';

const app = express();
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

app.use(cors());
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static(uploadDir));

app.get('/health', (_, res) => {
    res.json({ status: 'ok', service: 'local-marketplace-api', root: __dirname });
});

app.use('/api/auth', authRoutes);
app.use('/api/shops', shopsRoutes);
app.use('/api/products', productsRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/orders', ordersRoutes);

app.use((_, res) => {
    res.status(404).json({ message: 'Route not found' });
});

export default app;