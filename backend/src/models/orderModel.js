import { query, transaction } from '../config/db.js';

function parseItems(itemsJson) {
    if (!itemsJson) {
        return [];
    }

    try {
        return JSON.parse(itemsJson);
    } catch {
        return [];
    }
}

export async function listOrders() {
    const rows = await query('SELECT * FROM orders ORDER BY created_at DESC, id DESC');

    return rows.map((row) => ({
        ...row,
        items: parseItems(row.items_json),
    }));
}

export async function createOrder({ items, subtotal, discountAmount, totalPrice, couponCode, status = 'completed' }) {
    return transaction(async (connection) => {
        const normalizedItems = [];

        for (const item of items) {
            const [rows] = await connection.query(
                'SELECT id, name, price, stock, category FROM products WHERE id = ? LIMIT 1',
                [item.productId],
            );

            const product = rows[0];

            if (!product) {
                const error = new Error(`Product ${item.productId} not found`);
                error.statusCode = 404;
                throw error;
            }

            if (product.stock < item.quantity) {
                const error = new Error(`Insufficient stock for ${product.name}`);
                error.statusCode = 409;
                throw error;
            }

            const price = Number(product.price);
            const quantity = Number(item.quantity);

            normalizedItems.push({
                productId: product.id,
                name: product.name,
                category: product.category,
                price,
                quantity,
                lineTotal: price * quantity,
            });
        }

        for (const item of normalizedItems) {
            await connection.query('UPDATE products SET stock = stock - ? WHERE id = ?', [item.quantity, item.productId]);
        }

        const appliedSubtotal = Number.isFinite(Number(subtotal)) ? Number(subtotal) : normalizedItems.reduce((sum, item) => sum + item.lineTotal, 0);
        const appliedDiscount = Number.isFinite(Number(discountAmount)) ? Number(discountAmount) : 0;
        const appliedTotal = Number.isFinite(Number(totalPrice)) ? Number(totalPrice) : Math.max(appliedSubtotal - appliedDiscount, 0);

        const [result] = await connection.query(
            'INSERT INTO orders (items_json, subtotal, discount_amount, total_price, status, coupon_code) VALUES (?, ?, ?, ?, ?, ?)',
            [JSON.stringify(normalizedItems), appliedSubtotal, appliedDiscount, appliedTotal, status, couponCode || null],
        );

        const [createdRows] = await connection.query('SELECT * FROM orders WHERE id = ? LIMIT 1', [result.insertId]);
        const createdOrder = createdRows[0];

        return {
            ...createdOrder,
            items: parseItems(createdOrder.items_json),
        };
    });
}