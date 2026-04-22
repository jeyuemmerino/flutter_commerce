import express from 'express';
import cors from 'cors';
import authRoutes from './routes/auth.routes.js';
import { PORT } from './config/env.js';

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api', authRoutes);

app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});