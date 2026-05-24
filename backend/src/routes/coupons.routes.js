import { Router } from 'express';
import { validateCouponCode } from '../controllers/marketplaceController.js';

const router = Router();

router.post('/validate', validateCouponCode);

export default router;