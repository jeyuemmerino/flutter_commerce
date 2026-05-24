import crypto from 'crypto';

export function hashPassword(password, salt = crypto.randomBytes(16).toString('hex')) {
    const derivedKey = crypto.scryptSync(String(password), salt, 64).toString('hex');
    return `${salt}:${derivedKey}`;
}

export function verifyPassword(password, storedHash) {
    const [salt, hash] = String(storedHash || '').split(':');

    if (!salt || !hash) {
        return false;
    }

    const derivedKey = crypto.scryptSync(String(password), salt, 64).toString('hex');
    return crypto.timingSafeEqual(Buffer.from(hash, 'hex'), Buffer.from(derivedKey, 'hex'));
}