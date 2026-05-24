import app from './src/app.js';
import { initDatabase } from './src/config/db.js';
import { PORT } from './src/config/env.js';

try {
    await initDatabase();

    app.listen(PORT, () => {
        console.log(`Server running on http://localhost:${PORT}`);
    });
} catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
}