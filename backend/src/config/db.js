import mysql from 'mysql2/promise';
import { DB_HOST, DB_NAME, DB_PASSWORD, DB_USER } from './env.js';
import { seedCoupons, seedProducts } from '../data/seedData.js';

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
        namedPlaceholders: true,
    });
}

async function seedTableIfEmpty(connection, tableName, rows, insertSql, mapRow) {
    const [countRows] = await connection.query(`SELECT COUNT(*) AS count FROM ${tableName}`);
    if (countRows[0].count > 0) {
        return;
    }

    for (const row of rows) {
        await connection.query(insertSql, mapRow(row));
    }
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

        await pool.query(`
            CREATE TABLE IF NOT EXISTS products (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                description TEXT NOT NULL,
                price DECIMAL(10,2) NOT NULL,
                stock INT NOT NULL DEFAULT 0,
                image_url TEXT,
                category VARCHAR(120) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `);

        await pool.query(`
            CREATE TABLE IF NOT EXISTS coupons (
                id INT AUTO_INCREMENT PRIMARY KEY,
                code VARCHAR(64) NOT NULL UNIQUE,
                discount_type ENUM('percent', 'fixed') NOT NULL,
                value DECIMAL(10,2) NOT NULL,
                expiry_date DATE NOT NULL,
                active TINYINT(1) NOT NULL DEFAULT 1,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `);

        await pool.query(`
            CREATE TABLE IF NOT EXISTS orders (
                id INT AUTO_INCREMENT PRIMARY KEY,
                items_json LONGTEXT NOT NULL,
                subtotal DECIMAL(10,2) NOT NULL,
                discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
                total_price DECIMAL(10,2) NOT NULL,
                status VARCHAR(32) NOT NULL DEFAULT 'completed',
                coupon_code VARCHAR(64),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `);

        await seedTableIfEmpty(
            pool,
            'products',
            seedProducts,
            `INSERT INTO products (name, description, price, stock, image_url, category) VALUES (?, ?, ?, ?, ?, ?)`,
            (row) => [row.name, row.description, row.price, row.stock, row.imageUrl, row.category],
        );

        await seedTableIfEmpty(
            pool,
            'coupons',
            seedCoupons,
            `INSERT INTO coupons (code, discount_type, value, expiry_date, active) VALUES (?, ?, ?, ?, ?)`,
            (row) => [row.code, row.discountType, row.value, row.expiryDate, row.active],
        );

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