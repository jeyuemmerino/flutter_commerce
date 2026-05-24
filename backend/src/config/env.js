import { config } from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

config({
    path: path.resolve(__dirname, `../../../.env.${process.env.NODE_ENV || 'development'}.local`),
});

const toNumber = (value, fallback) => {
    const parsed = Number(value);
    return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
};

export const PORT = toNumber(process.env.PORT, 5000);
export const DB_HOST = process.env.DB_HOST || 'localhost';
export const DB_USER = process.env.DB_USER || 'root';
export const DB_PASSWORD = process.env.DB_PASSWORD || process.env.mysqlpassword || '';
export const DB_NAME = process.env.DB_NAME || 'ecommerce_db';