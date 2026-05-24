import mysql from 'mysql2/promise';
import { DB_HOST, DB_NAME, DB_PASSWORD, DB_USER, RESET_DB_ON_START } from './env.js';

let pool;
let initPromise;

function buildPool() {
    return mysql.createPool({
        host: DB_HOST,
        user: DB_USER,
        password: DB_PASSWORD,
        database: DB_NAME,
        waitForConnections: true,
        connectionLimit: 10,
    });
}

async function resetSchema(connection) {
    await connection.query('SET FOREIGN_KEY_CHECKS = 0');
    await connection.query('DROP TABLE IF EXISTS order_items');
    await connection.query('DROP TABLE IF EXISTS orders');
    await connection.query('DROP TABLE IF EXISTS cart_items');
    await connection.query('DROP TABLE IF EXISTS carts');
    await connection.query('DROP TABLE IF EXISTS products');
    await connection.query('DROP TABLE IF EXISTS shops');
    await connection.query('DROP TABLE IF EXISTS users');
    await connection.query('SET FOREIGN_KEY_CHECKS = 1');
}

async function createSchema(connection) {
    await connection.query('SET FOREIGN_KEY_CHECKS = 0');

    await connection.query(`
        CREATE TABLE IF NOT EXISTS users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            email VARCHAR(255) NOT NULL UNIQUE,
            password_hash VARCHAR(255) NOT NULL,
            role ENUM('buyer', 'seller') NOT NULL,
            avatar_url TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    `);

    await connection.query(`
        CREATE TABLE IF NOT EXISTS shops (
            id INT AUTO_INCREMENT PRIMARY KEY,
            owner_user_id INT NOT NULL UNIQUE,
            name VARCHAR(255) NOT NULL,
            description TEXT,
            logo_url TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            CONSTRAINT fk_shops_owner FOREIGN KEY (owner_user_id) REFERENCES users(id) ON DELETE CASCADE
        )
    `);

    await connection.query(`
        CREATE TABLE IF NOT EXISTS products (
            id INT AUTO_INCREMENT PRIMARY KEY,
            shop_id INT NOT NULL,
            owner_user_id INT NOT NULL,
            name VARCHAR(255) NOT NULL,
            description TEXT NOT NULL,
            price DECIMAL(10,2) NOT NULL,
            stock INT NOT NULL DEFAULT 0,
            category VARCHAR(120) NOT NULL,
            image_url TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            CONSTRAINT fk_products_owner FOREIGN KEY (owner_user_id) REFERENCES users(id) ON DELETE CASCADE,
            CONSTRAINT fk_products_shop FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE
        )
    `);

    await connection.query(`
        CREATE TABLE IF NOT EXISTS carts (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL UNIQUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            CONSTRAINT fk_carts_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
    `);

    await connection.query(`
        CREATE TABLE IF NOT EXISTS cart_items (
            id INT AUTO_INCREMENT PRIMARY KEY,
            cart_id INT NOT NULL,
            product_id INT NOT NULL,
            quantity INT NOT NULL DEFAULT 1,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            CONSTRAINT fk_cart_items_cart FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE CASCADE,
            CONSTRAINT fk_cart_items_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
        )
    `);

    await connection.query(`
        CREATE TABLE IF NOT EXISTS orders (
            id INT AUTO_INCREMENT PRIMARY KEY,
            buyer_user_id INT NOT NULL,
            shop_id INT NOT NULL,
            status ENUM('pending', 'shipped', 'delivered') NOT NULL DEFAULT 'pending',
            subtotal DECIMAL(10,2) NOT NULL,
            total DECIMAL(10,2) NOT NULL,
            shipping_address TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            CONSTRAINT fk_orders_buyer FOREIGN KEY (buyer_user_id) REFERENCES users(id) ON DELETE CASCADE,
            CONSTRAINT fk_orders_shop FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE
        )
    `);

    await connection.query(`
        CREATE TABLE IF NOT EXISTS order_items (
            id INT AUTO_INCREMENT PRIMARY KEY,
            order_id INT NOT NULL,
            product_id INT NOT NULL,
            product_name VARCHAR(255) NOT NULL,
            price DECIMAL(10,2) NOT NULL,
            quantity INT NOT NULL DEFAULT 1,
            image_url TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
            CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
        )
    `);

    await connection.query('SET FOREIGN_KEY_CHECKS = 1');
}

async function ensureProductOwnerColumn(connection) {
    const [columns] = await connection.query("SHOW COLUMNS FROM products LIKE 'owner_user_id'");

    if (columns.length > 0) {
        return;
    }

    await connection.query('ALTER TABLE products ADD COLUMN owner_user_id INT NOT NULL DEFAULT 0 AFTER shop_id');
    await connection.query(`
        UPDATE products
        JOIN shops ON shops.id = products.shop_id
        SET products.owner_user_id = shops.owner_user_id
    `);
    await connection.query('ALTER TABLE products MODIFY owner_user_id INT NOT NULL');
}

export async function initDatabase() {
    if (pool) {
        return pool;
    }

    if (initPromise) {
        return initPromise;
    }

    initPromise = (async () => {
        const bootstrapConnection = await mysql.createConnection({
            host: DB_HOST,
            user: DB_USER,
            password: DB_PASSWORD,
        });

        await bootstrapConnection.query(`CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\``);
        await bootstrapConnection.end();

        pool = buildPool();

        if (RESET_DB_ON_START) {
            await resetSchema(pool);
        }

        await createSchema(pool);
        await ensureProductOwnerColumn(pool);

        // Seed data is now handled by the standalone seed script (npm run seed)
        // Remove auto-seeding calls - they're in scripts/seed.js

        return pool;
    })();

    return initPromise;
}

export async function query(sql, params = []) {
    const activePool = await initDatabase();
    const [rows] = await activePool.query(sql, params);
    return rows;
}

export async function transaction(work) {
    const activePool = await initDatabase();
    const connection = await activePool.getConnection();

    try {
        await connection.beginTransaction();
        const result = await work(connection);
        await connection.commit();
        return result;
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
}