import { asyncHandler } from '../middleware/asyncHandler.js';
import { buildAnalytics, buildDescription, buildRecommendations, buildSalesInsights } from '../utils/marketplaceAnalytics.js';
import { createProduct, deleteProduct, getProductById, getProducts } from '../models/productModel.js';
import { createOrder, listOrders } from '../models/orderModel.js';
import { validateCoupon } from '../models/couponModel.js';
import { query } from '../config/db.js';

function toNumber(value) {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : 0;
}

export const listProducts = asyncHandler(async (_req, res) => {
    const products = await getProducts();
    res.json(products.map((product) => ({
        ...product,
        price: toNumber(product.price),
        stock: Number(product.stock),
    })));
});

export const addProduct = asyncHandler(async (req, res) => {
    const { name, description, price, stock, imageUrl, category } = req.body;

    if (!name || !description || !category) {
        return res.status(400).json({ message: 'name, description, and category are required' });
    }

    const product = await createProduct({
        name,
        description,
        price: toNumber(price),
        stock: Number.isFinite(Number(stock)) ? Number(stock) : 0,
        imageUrl,
        category,
    });

    res.status(201).json({
        ...product,
        price: toNumber(product.price),
        stock: Number(product.stock),
    });
});

export const removeProduct = asyncHandler(async (req, res) => {
    const deleted = await deleteProduct(req.params.id);

    if (!deleted) {
        return res.status(404).json({ message: 'Product not found' });
    }

    res.json({ message: 'Product deleted' });
});

export const listMarketplaceOrders = asyncHandler(async (_req, res) => {
    const orders = await listOrders();

    res.json(orders.map((order) => ({
        ...order,
        subtotal: toNumber(order.subtotal),
        discountAmount: toNumber(order.discount_amount),
        totalPrice: toNumber(order.total_price),
        items: order.items,
    })));
});

export const placeOrder = asyncHandler(async (req, res) => {
    const { items = [], couponCode = '' } = req.body;

    if (!Array.isArray(items) || items.length === 0) {
        return res.status(400).json({ message: 'Order items are required' });
    }

    const normalizedItems = items.map((item) => ({
        productId: Number(item.productId),
        quantity: Math.max(Number(item.quantity || 1), 1),
    }));

    const products = await Promise.all(normalizedItems.map((item) => getProductById(item.productId)));
    const productMap = new Map(products.filter(Boolean).map((product) => [Number(product.id), product]));

    const subtotal = normalizedItems.reduce((sum, item) => {
        const product = productMap.get(item.productId);
        return sum + (product ? toNumber(product.price) * item.quantity : 0);
    }, 0);

    let discountAmount = 0;
    let validatedCoupon = null;

    if (couponCode) {
        validatedCoupon = await validateCoupon(couponCode);

        if (!validatedCoupon) {
            return res.status(400).json({ message: 'Coupon is invalid or expired' });
        }

        if (validatedCoupon.discount_type === 'percent') {
            discountAmount = subtotal * (toNumber(validatedCoupon.value) / 100);
        } else {
            discountAmount = toNumber(validatedCoupon.value);
        }
    }

    const totalPrice = Math.max(subtotal - discountAmount, 0);
    const order = await createOrder({
        items: normalizedItems,
        subtotal,
        discountAmount,
        totalPrice,
        couponCode: validatedCoupon?.code || null,
        status: 'completed',
    });

    res.status(201).json({
        ...order,
        subtotal: toNumber(order.subtotal),
        discountAmount: toNumber(order.discount_amount),
        totalPrice: toNumber(order.total_price),
        items: order.items,
    });
});

export const validateCouponCode = asyncHandler(async (req, res) => {
    const { code = '' } = req.body;
    const coupon = await validateCoupon(code.trim());

    if (!coupon) {
        return res.status(404).json({ valid: false, message: 'Coupon not found or expired' });
    }

    res.json({
        valid: true,
        coupon: {
            code: coupon.code,
            discountType: coupon.discount_type,
            value: toNumber(coupon.value),
            expiryDate: coupon.expiry_date,
        },
    });
});

export const getAnalytics = asyncHandler(async (_req, res) => {
    const products = await getProducts();
    const orders = await listOrders();
    const analytics = buildAnalytics(products, orders);

    res.json(analytics);
});

export const getAiRecommendations = asyncHandler(async (req, res) => {
    const products = await getProducts();
    const orders = await listOrders();
    const productId = Number(req.query.productId || 0);
    const product = productId ? products.find((item) => Number(item.id) === productId) : null;

    res.json(buildRecommendations({ product, products, orders }));
});

export const generateDescription = asyncHandler(async (req, res) => {
    const { name, category } = req.body;
    res.json({ description: buildDescription({ name, category }) });
});

export const getSalesInsight = asyncHandler(async (_req, res) => {
    const products = await getProducts();
    const orders = await listOrders();
    const analytics = buildAnalytics(products, orders);

    res.json({
        insights: buildSalesInsights(analytics, products, orders),
    });
});

export const getProductDetails = asyncHandler(async (req, res) => {
    const product = await getProductById(req.params.id);

    if (!product) {
        return res.status(404).json({ message: 'Product not found' });
    }

    res.json({
        ...product,
        price: toNumber(product.price),
        stock: Number(product.stock),
    });
});

export const getDashboardSnapshot = asyncHandler(async (_req, res) => {
    const [products, orders, couponRows] = await Promise.all([
        getProducts(),
        listOrders(),
        query('SELECT * FROM coupons ORDER BY created_at DESC'),
    ]);

    res.json({
        products,
        orders,
        coupons: couponRows,
        analytics: buildAnalytics(products, orders),
    });
});