import mysql from 'mysql';
import { mysqlpassword } from '../config/env';

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
});

export default db;