import fs from 'fs';
import path from 'path';
import multer from 'multer';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const uploadDir = path.resolve(__dirname, '../../../uploads');

fs.mkdirSync(uploadDir, { recursive: true });

const storage = multer.diskStorage({
    destination: (_, __, callback) => callback(null, uploadDir),
    filename: (_, file, callback) => {
        const extension = path.extname(file.originalname || '').toLowerCase() || '.png';
        callback(null, `${Date.now()}-${Math.round(Math.random() * 1e9)}${extension}`);
    },
});

export const upload = multer({ storage });

export function uploadUrl(filename) {
    return `/uploads/${filename}`;
}