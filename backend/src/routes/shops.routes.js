import { Router } from 'express';
import { createShop, getShop, getShopByOwnerId, getShopDashboard, listShops } from '../controllers/marketplaceController.js';

const router = Router();

router.get('/', listShops);
router.get('/owner/:ownerUserId', getShopByOwnerId);
router.get('/:shopId', getShop);
router.get('/:shopId/dashboard', getShopDashboard);
router.post('/', createShop);

export default router;