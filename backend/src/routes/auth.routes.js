import { Router } from 'express';
import { login, me, register, updateProfile } from '../controllers/marketplaceController.js';

const router = Router();

router.post('/register', register);
router.post('/login', login);
router.get('/me/:userId', me);
router.put('/profile/:userId', updateProfile);

export default router;