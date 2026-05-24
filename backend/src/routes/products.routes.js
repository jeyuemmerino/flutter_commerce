import { Router } from 'express';
import { upload } from '../config/upload.js';
import { createProduct, getProduct, listProducts, removeProduct, updateProduct, uploadProductImage } from '../controllers/marketplaceController.js';

const router = Router();

router.get('/', listProducts);
router.get('/:productId', getProduct);
router.post('/upload-image', upload.single('image'), uploadProductImage);
router.post('/', upload.single('image'), createProduct);
router.put('/:productId', upload.single('image'), updateProduct);
router.delete('/:productId', removeProduct);

export default router;