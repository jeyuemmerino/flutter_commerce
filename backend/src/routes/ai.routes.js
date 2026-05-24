import { Router } from 'express';
import { generateDescription, getAiRecommendations, getSalesInsight } from '../controllers/marketplaceController.js';

const router = Router();

router.get('/recommendations', getAiRecommendations);
router.post('/generate-description', generateDescription);
router.get('/sales-insight', getSalesInsight);

export default router;