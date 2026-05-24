import { Router } from 'express';
import { login, me, register } from '../controllers/marketplaceController.js';

const router = Router();

router.post('/register', register);
router.post('/login', login);
router.get('/me/:userId', me);

export default router;