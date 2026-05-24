import { query } from '../config/db.js';

export async function validateCoupon(code) {
    const rows = await query(
        'SELECT * FROM coupons WHERE code = ? AND active = 1 AND expiry_date >= CURDATE() LIMIT 1',
        [code],
    );

    return rows[0] || null;
}