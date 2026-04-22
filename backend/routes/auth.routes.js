import express from 'express';
import db from '../database/mysqldb.js';

const router = express.Router();

router.post('/login', (req, res) => {
    const { email, password } = req.body;

    const sql = 'SELECT * FROM users WHERE email = ? AND password = ?';

    db.query(sql, [email, password], (err, results) => {
        if (err) {
            console.error('Login query error:', err);
            return res.status(500).json({ message: 'Server error', code: err.code });
        }

        if (results.length > 0) {
            res.json({ message: 'Login successful' });
        } else {
            res.status(401).json({ message: 'Invalid credentials' });
        }
    });
});

export default router;