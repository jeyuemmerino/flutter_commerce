import { config } from 'dotenv';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const envFile = path.resolve(__dirname, `../../.env.${process.env.NODE_ENV || 'development'}.local`);
const fallbackEnvFile = path.resolve(__dirname, `../../.env.${process.env.NODE_ENV || 'development'}`);
const envPath = fs.existsSync(envFile)
    ? envFile
    : fs.existsSync(fallbackEnvFile)
    ? fallbackEnvFile
    : undefined;

config(envPath ? { path: envPath, override: true } : { override: true });

if (envPath) {
    const envContent = fs.readFileSync(envPath, 'utf8');
    const match = envContent.match(/^\s*PORT\s*=\s*(\d+)\s*$/m);
    if (match) {
        process.env.PORT = match[1];
    }
}

const toNumber = (value, fallback) => {
    const parsed = Number(value);
    return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
};

export const PORT = 5000;
export const DB_HOST = process.env.DB_HOST || 'localhost';
export const DB_USER = process.env.DB_USER || 'root';
export const DB_PASSWORD = process.env.DB_PASSWORD || 'root';
export const DB_NAME = process.env.DB_NAME || 'ecommerce_db';
export const RESET_DB_ON_START = (process.env.RESET_DB_ON_START || 'false').toLowerCase() !== 'false';