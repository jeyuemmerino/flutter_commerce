import mysql from 'mysql2/promise';
import { config } from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';
import { hashPassword } from '../src/utils/security.js';
import { seedUsers, seedShops, seedProducts, seedCarts, seedCartItems, seedOrders, seedOrderItems } from '../src/data/seedData.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load environment variables
config({
    path: path.resolve(__dirname, '../.env.development.local'),
});

const DB_HOST = process.env.DB_HOST || 'localhost';
const DB_USER = process.env.DB_USER || 'root';
const DB_PASSWORD = process.env.DB_PASSWORD || '';
const DB_NAME = process.env.DB_NAME || 'ecommerce_db';

async function seedDatabase() {
    let connection;

    try {
        console.log('🌱 Connecting to database...');
        connection = await mysql.createConnection({
            host: DB_HOST,
            user: DB_USER,
            password: DB_PASSWORD,
            database: DB_NAME,
        });

        console.log('✅ Connected to database');

        // Clear existing data (respecting foreign key constraints)
        console.log('🗑️  Clearing existing data...');
        await connection.query('SET FOREIGN_KEY_CHECKS = 0');
        await connection.query('TRUNCATE TABLE order_items');
        await connection.query('TRUNCATE TABLE orders');
        await connection.query('TRUNCATE TABLE cart_items');
        await connection.query('TRUNCATE TABLE carts');
        await connection.query('TRUNCATE TABLE products');
        await connection.query('TRUNCATE TABLE shops');
        await connection.query('TRUNCATE TABLE users');
        await connection.query('SET FOREIGN_KEY_CHECKS = 1');
        console.log('✅ Data cleared');

        // Insert users
        console.log('👤 Seeding users...');
        for (const user of seedUsers) {
            await connection.query(
                'INSERT INTO users (id, name, email, password_hash, role, avatar_url) VALUES (?, ?, ?, ?, ?, ?)',
                [user.id, user.name, user.email, hashPassword(user.password), user.role, user.avatarUrl]
            );
        }
        console.log(`✅ Inserted ${seedUsers.length} user(s)`);

        // Insert shops
        console.log('🏬 Seeding shops...');
        for (const shop of seedShops) {
            await connection.query(
                'INSERT INTO shops (id, owner_user_id, name, description, logo_url) VALUES (?, ?, ?, ?, ?)',
                [shop.id, shop.ownerUserId, shop.name, shop.description, shop.logoUrl]
            );
        }
        console.log(`✅ Inserted ${seedShops.length} shop(s)`);

        // Insert products
        console.log('📦 Seeding products...');
        for (const product of seedProducts) {
            await connection.query(
                'INSERT INTO products (id, shop_id, owner_user_id, name, description, price, stock, category, image_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
                [product.id, product.shopId, product.ownerUserId, product.name, product.description, product.price, product.stock, product.category, product.imageUrl]
            );
        }
        console.log(`✅ Inserted ${seedProducts.length} product(s)`);

        // Insert carts
        console.log('🛒 Seeding carts...');
        for (const cart of seedCarts) {
            await connection.query(
                'INSERT INTO carts (id, user_id) VALUES (?, ?)',
                [cart.id, cart.userId]
            );
        }
        console.log(`✅ Inserted ${seedCarts.length} cart(s)`);

        // Insert cart items
        console.log('🛍️  Seeding cart items...');
        for (const item of seedCartItems) {
            await connection.query(
                'INSERT INTO cart_items (id, cart_id, product_id, quantity) VALUES (?, ?, ?, ?)',
                [item.id, item.cartId, item.productId, item.quantity]
            );
        }
        console.log(`✅ Inserted ${seedCartItems.length} cart item(s)`);

        // Insert orders
        console.log('📋 Seeding orders...');
        for (const order of seedOrders) {
            await connection.query(
                'INSERT INTO orders (id, buyer_user_id, shop_id, status, subtotal, total, shipping_address) VALUES (?, ?, ?, ?, ?, ?, ?)',
                [order.id, order.buyerUserId, order.shopId, order.status, order.subtotal, order.total, order.shippingAddress]
            );
        }
        console.log(`✅ Inserted ${seedOrders.length} order(s)`);

        // Insert order items
        console.log('📦 Seeding order items...');
        for (const item of seedOrderItems) {
            await connection.query(
                'INSERT INTO order_items (id, order_id, product_id, product_name, price, quantity, image_url) VALUES (?, ?, ?, ?, ?, ?, ?)',
                [item.id, item.orderId, item.productId, item.productName, item.price, item.quantity, item.imageUrl]
            );
        }
        console.log(`✅ Inserted ${seedOrderItems.length} order item(s)`);

        console.log('🎉 Seeding completed successfully!');
        process.exit(0);
    } catch (error) {
        console.error('❌ Seeding failed:', error.message);
        process.exit(1);
    } finally {
        if (connection) {
            await connection.end();
        }
    }
}

seedDatabase();
