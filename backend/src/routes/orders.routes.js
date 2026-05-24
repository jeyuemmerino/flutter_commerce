import { Router } from 'express';
import { checkoutCart, getBuyerOrders, getInvoice, getShopOrders, updateOrderStatus } from '../controllers/marketplaceController.js';

const router = Router();

router.post('/checkout', checkoutCart);
router.get('/buyer/:userId', getBuyerOrders);
router.get('/shop/:shopId', getShopOrders);
router.get('/:orderId/invoice', getInvoice);
router.patch('/:orderId/status', updateOrderStatus);

export default router;