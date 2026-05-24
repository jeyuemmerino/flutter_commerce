import { Router } from 'express';
import { addCartItem, clearCart, getCart, removeCartItem, updateCartItem } from '../controllers/marketplaceController.js';

const router = Router();

router.get('/:userId', getCart);
router.post('/items', addCartItem);
router.put('/items/:productId', updateCartItem);
router.delete('/items/:productId', removeCartItem);
router.delete('/:userId', clearCart);

export default router;