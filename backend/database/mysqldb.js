import mysql from 'mysql2';
import { mysqlpassword } from '../config/env.js';

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: mysqlpassword,
    database: 'flutterdb'
});

db.connect(err => {
    if (err) {
        console.error('DB connection failed:', err);
        return;
    }
    console.log('Connected to MySQL');

    const createUsersTableSql = `
        CREATE TABLE IF NOT EXISTS users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            email VARCHAR(255) NOT NULL UNIQUE,
            password VARCHAR(255) NOT NULL
        )
    `;

    db.query(createUsersTableSql, tableErr => {
        if (tableErr) {
            console.error('Failed to ensure users table exists:', tableErr);
            return;
        }
        console.log('Users table is ready');
    });
});

export default db;