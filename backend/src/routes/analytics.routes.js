import { Router } from 'express';
import { getAnalytics } from '../controllers/marketplaceController.js';

const router = Router();

router.get('/', getAnalytics);

export default router;