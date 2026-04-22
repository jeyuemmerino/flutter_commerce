import { config } from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

config({
    path: path.resolve(
        __dirname,
        `../../.env.${process.env.NODE_ENV || 'development'}.local`
    ),
});

export const {
    PORT,
    mysqlpassword
} = process.env;