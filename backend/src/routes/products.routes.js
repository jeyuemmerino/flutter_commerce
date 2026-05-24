import { Router } from 'express';
import { addProduct, getProductDetails, listProducts, removeProduct } from '../controllers/marketplaceController.js';

const router = Router();

router.get('/', listProducts);
router.get('/:id', getProductDetails);
router.post('/', addProduct);
router.delete('/:id', removeProduct);

export default router;