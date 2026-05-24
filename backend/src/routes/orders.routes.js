import { Router } from 'express';
import { listMarketplaceOrders, placeOrder } from '../controllers/marketplaceController.js';

const router = Router();

router.get('/', listMarketplaceOrders);
router.post('/', placeOrder);

export default router;