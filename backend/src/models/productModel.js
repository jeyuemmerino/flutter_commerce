import { query, transaction } from '../config/db.js';

export async function getProducts() {
    return query('SELECT * FROM products ORDER BY created_at DESC, id DESC');
}

export async function getProductById(id) {
    const rows = await query('SELECT * FROM products WHERE id = ?', [id]);
    return rows[0] || null;
}

export async function createProduct(product) {
    const result = await query(
        'INSERT INTO products (name, description, price, stock, image_url, category) VALUES (?, ?, ?, ?, ?, ?)',
        [
            product.name,
            product.description,
            product.price,
            product.stock,
            product.imageUrl || '',
            product.category,
        ],
    );

    return getProductById(result.insertId);
}

export async function deleteProduct(id) {
    const result = await query('DELETE FROM products WHERE id = ?', [id]);
    return result.affectedRows > 0;
}

export async function reserveStock(orderItems) {
    return transaction(async (connection) => {
        for (const item of orderItems) {
            const [rows] = await connection.query('SELECT id, stock, name FROM products WHERE id = ?', [item.productId]);
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
        }

        for (const item of orderItems) {
            await connection.query('UPDATE products SET stock = stock - ? WHERE id = ?', [item.quantity, item.productId]);
        }
    });
}