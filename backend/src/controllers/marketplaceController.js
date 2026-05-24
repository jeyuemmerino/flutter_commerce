import { query, transaction } from '../config/db.js';
import { hashPassword, verifyPassword } from '../utils/security.js';

function numberOrZero(value) {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : 0;
}

function cleanString(value) {
    return String(value || '').trim();
}

function mapUser(row) {
    if (!row) {
        return null;
    }

    return {
        id: row.id,
        name: row.name,
        email: row.email,
        role: row.role,
        avatarUrl: row.avatar_url || '',
        createdAt: row.created_at,
    };
}

function mapShop(row) {
    if (!row) {
        return null;
    }

    return {
        id: row.id,
        ownerUserId: row.owner_user_id,
        name: row.name,
        description: row.description || '',
        logoUrl: row.logo_url || '',
        createdAt: row.created_at,
    };
}

function mapProduct(row) {
    if (!row) {
        return null;
    }

    return {
        id: row.id,
        shopId: row.shop_id,
        shopName: row.shop_name || '',
        ownerUserId: row.owner_user_id,
        name: row.name,
        description: row.description,
        price: numberOrZero(row.price),
        stock: numberOrZero(row.stock),
        category: row.category,
        imageUrl: row.image_url || '',
        createdAt: row.created_at,
    };
}

function mapOrderItem(row) {
    return {
        id: row.id,
        productId: row.product_id,
        productName: row.product_name,
        price: numberOrZero(row.price),
        quantity: numberOrZero(row.quantity),
        imageUrl: row.image_url || '',
    };
}

function mapOrder(row) {
    return {
        id: row.id,
        buyerUserId: row.buyer_user_id,
        shopId: row.shop_id,
        status: row.status,
        subtotal: numberOrZero(row.subtotal),
        total: numberOrZero(row.total),
        shippingAddress: row.shipping_address || '',
        createdAt: row.created_at,
        shopName: row.shop_name || '',
        buyerName: row.buyer_name || '',
        items: [],
    };
}

async function getUserById(id) {
    const rows = await query('SELECT * FROM users WHERE id = ? LIMIT 1', [id]);
    return mapUser(rows[0]);
}

async function getUserByEmail(email) {
    const rows = await query('SELECT * FROM users WHERE email = ? LIMIT 1', [email]);
    return rows[0] || null;
}

async function getShopByOwner(ownerUserId) {
    const rows = await query('SELECT * FROM shops WHERE owner_user_id = ? LIMIT 1', [ownerUserId]);
    return mapShop(rows[0]);
}

async function getShopById(shopId) {
    const rows = await query(
        `
        SELECT shops.*, users.name AS owner_name, users.email AS owner_email
        FROM shops
        JOIN users ON users.id = shops.owner_user_id
        WHERE shops.id = ?
        LIMIT 1
        `,
        [shopId],
    );
    const shop = mapShop(rows[0]);
    if (!shop) {
        return null;
    }

    shop.ownerName = rows[0].owner_name;
    shop.ownerEmail = rows[0].owner_email;
    return shop;
}

async function ensureCartForUser(userId) {
    const rows = await query('SELECT * FROM carts WHERE user_id = ? LIMIT 1', [userId]);
    if (rows[0]) {
        return rows[0];
    }

    const result = await query('INSERT INTO carts (user_id) VALUES (?)', [userId]);
    return { id: result.insertId, user_id: userId };
}

async function getCartItems(userId) {
    const rows = await query(
        `
        SELECT
            cart_items.id,
            cart_items.cart_id,
            cart_items.product_id,
            cart_items.quantity,
            products.name AS product_name,
            products.description,
            products.price,
            products.stock,
            products.category,
            products.image_url,
            products.shop_id,
            shops.name AS shop_name
        FROM cart_items
        JOIN carts ON carts.id = cart_items.cart_id
        JOIN products ON products.id = cart_items.product_id
        JOIN shops ON shops.id = products.shop_id
        WHERE carts.user_id = ?
        ORDER BY cart_items.id ASC
        `,
        [userId],
    );

    return rows.map((row) => ({
        id: row.id,
        cartId: row.cart_id,
        productId: row.product_id,
        quantity: numberOrZero(row.quantity),
        product: {
            id: row.product_id,
            name: row.product_name,
            description: row.description,
            price: numberOrZero(row.price),
            stock: numberOrZero(row.stock),
            category: row.category,
            imageUrl: row.image_url || '',
            shopId: row.shop_id,
            shopName: row.shop_name,
        },
    }));
}

// Helper to build cart response for a given user id
async function getCartForUser(userId) {
    const cart = await ensureCartForUser(userId);
    const items = await getCartItems(userId);
    const subtotal = items.reduce((sum, item) => sum + item.quantity * item.product.price, 0);
    return { cart, items, subtotal };
}

async function getProductsByShop(shopId) {
    const rows = await query(
        `
        SELECT products.*, shops.name AS shop_name, shops.owner_user_id
        FROM products
        JOIN shops ON shops.id = products.shop_id
        WHERE products.shop_id = ?
        ORDER BY products.created_at DESC, products.id DESC
        `,
        [shopId],
    );

    return rows.map(mapProduct);
}

async function getAllProducts() {
    const rows = await query(
        `
        SELECT products.*, shops.name AS shop_name, shops.owner_user_id
        FROM products
        JOIN shops ON shops.id = products.shop_id
        ORDER BY products.created_at DESC, products.id DESC
        `,
        [],
    );

    return rows.map(mapProduct);
}

async function getProductById(productId) {
    const rows = await query(
        `
        SELECT products.*, shops.name AS shop_name, shops.owner_user_id
        FROM products
        JOIN shops ON shops.id = products.shop_id
        WHERE products.id = ?
        LIMIT 1
        `,
        [productId],
    );

    return mapProduct(rows[0]);
}

async function getOrderWithItems(orderId) {
    const orderRows = await query(
        `
        SELECT orders.*, shops.name AS shop_name, buyers.name AS buyer_name
        FROM orders
        JOIN shops ON shops.id = orders.shop_id
        JOIN users AS buyers ON buyers.id = orders.buyer_user_id
        WHERE orders.id = ?
        LIMIT 1
        `,
        [orderId],
    );

    const order = mapOrder(orderRows[0]);
    if (!order) {
        return null;
    }

    const itemRows = await query('SELECT * FROM order_items WHERE order_id = ? ORDER BY id ASC', [orderId]);
    order.items = itemRows.map(mapOrderItem);
    return order;
}

async function getOrdersByBuyer(buyerUserId) {
    const orderRows = await query(
        `
        SELECT orders.*, shops.name AS shop_name, buyers.name AS buyer_name
        FROM orders
        JOIN shops ON shops.id = orders.shop_id
        JOIN users AS buyers ON buyers.id = orders.buyer_user_id
        WHERE orders.buyer_user_id = ?
        ORDER BY orders.created_at DESC, orders.id DESC
        `,
        [buyerUserId],
    );

    const orders = [];
    for (const row of orderRows) {
        const order = mapOrder(row);
        const items = await query('SELECT * FROM order_items WHERE order_id = ? ORDER BY id ASC', [order.id]);
        order.items = items.map(mapOrderItem);
        orders.push(order);
    }

    return orders;
}

async function getOrdersByShop(shopId) {
    const orderRows = await query(
        `
        SELECT orders.*, shops.name AS shop_name, buyers.name AS buyer_name
        FROM orders
        JOIN shops ON shops.id = orders.shop_id
        JOIN users AS buyers ON buyers.id = orders.buyer_user_id
        WHERE orders.shop_id = ?
        ORDER BY orders.created_at DESC, orders.id DESC
        `,
        [shopId],
    );

    const orders = [];
    for (const row of orderRows) {
        const order = mapOrder(row);
        const items = await query('SELECT * FROM order_items WHERE order_id = ? ORDER BY id ASC', [order.id]);
        order.items = items.map(mapOrderItem);
        orders.push(order);
    }

    return orders;
}

function getUploadPath(file) {
    if (!file) {
        return '';
    }

    return `/uploads/${file.filename}`;
}

export async function register(req, res) {
    const name = cleanString(req.body.name);
    const email = cleanString(req.body.email).toLowerCase();
    const password = cleanString(req.body.password);
    const role = cleanString(req.body.role) || 'buyer';

    if (!name || !email || !password) {
        return res.status(400).json({ message: 'name, email, and password are required' });
    }

    if (!['buyer', 'seller'].includes(role)) {
        return res.status(400).json({ message: 'role must be buyer or seller' });
    }

    const existing = await getUserByEmail(email);
    if (existing) {
        return res.status(409).json({ message: 'Email already registered' });
    }

    const result = await query(
        'INSERT INTO users (name, email, password_hash, role, avatar_url) VALUES (?, ?, ?, ?, ?)',
        [name, email, hashPassword(password), role, ''],
    );

    const user = await getUserById(result.insertId);

    if (role === 'buyer') {
        await ensureCartForUser(user.id);
    }

    const shop = await getShopByOwner(user.id);

    return res.status(201).json({ user, shop });
}

export async function login(req, res) {
    const email = cleanString(req.body.email).toLowerCase();
    const password = cleanString(req.body.password);

    if (!email || !password) {
        return res.status(400).json({ message: 'email and password are required' });
    }

    const rows = await query('SELECT * FROM users WHERE email = ? LIMIT 1', [email]);
    const userRow = rows[0];

    if (!userRow || !verifyPassword(password, userRow.password_hash)) {
        return res.status(401).json({ message: 'Invalid email or password' });
    }

    const user = mapUser(userRow);
    const shop = await getShopByOwner(user.id);

    if (user.role === 'buyer') {
        await ensureCartForUser(user.id);
    }

    return res.json({ user, shop });
}

export async function me(req, res) {
    const userId = Number(req.params.userId);
    const user = await getUserById(userId);
    if (!user) {
        return res.status(404).json({ message: 'User not found' });
    }

    const shop = await getShopByOwner(userId);
    return res.json({ user, shop });
}

export async function listShops(req, res) {
    const rows = await query(
        `
        SELECT shops.*, users.name AS owner_name, users.email AS owner_email
        FROM shops
        JOIN users ON users.id = shops.owner_user_id
        ORDER BY shops.created_at DESC, shops.id DESC
        `,
    );

    return res.json(
        rows.map((row) => ({
            ...mapShop(row),
            ownerName: row.owner_name,
            ownerEmail: row.owner_email,
        })),
    );
}

export async function getShop(req, res) {
    const shop = await getShopById(req.params.shopId);
    if (!shop) {
        return res.status(404).json({ message: 'Shop not found' });
    }

    return res.json(shop);
}

export async function getShopByOwnerId(req, res) {
    const shop = await getShopByOwner(req.params.ownerUserId);
    if (!shop) {
        return res.status(404).json({ message: 'Shop not found' });
    }

    return res.json(shop);
}

export async function createShop(req, res) {
    const ownerUserId = Number(req.body.ownerUserId);
    const name = cleanString(req.body.name);
    const description = cleanString(req.body.description);
    const logoUrl = cleanString(req.body.logoUrl) || getUploadPath(req.file);

    if (!ownerUserId || !name) {
        return res.status(400).json({ message: 'ownerUserId and name are required' });
    }

    const user = await getUserById(ownerUserId);
    if (!user) {
        return res.status(404).json({ message: 'Owner user not found' });
    }

    if (user.role !== 'seller') {
        return res.status(400).json({ message: 'Only sellers can register a shop' });
    }

    const existingShop = await getShopByOwner(ownerUserId);
    if (existingShop) {
        return res.status(409).json({ message: 'Seller already has a shop' });
    }

    const result = await query(
        'INSERT INTO shops (owner_user_id, name, description, logo_url) VALUES (?, ?, ?, ?)',
        [ownerUserId, name, description, logoUrl],
    );

    const shop = await getShopById(result.insertId);
    return res.status(201).json(shop);
}

export async function getShopDashboard(req, res) {
    const shop = await getShopById(req.params.shopId);
    if (!shop) {
        return res.status(404).json({ message: 'Shop not found' });
    }

    const products = await getProductsByShop(shop.id);
    const orders = await getOrdersByShop(shop.id);

    const stats = orders.reduce(
        (accumulator, order) => {
            accumulator.totalOrders += 1;
            accumulator.totalRevenue += order.total;
            accumulator.pending += order.status === 'pending' ? 1 : 0;
            accumulator.shipped += order.status === 'shipped' ? 1 : 0;
            accumulator.delivered += order.status === 'delivered' ? 1 : 0;
            return accumulator;
        },
        { totalOrders: 0, totalRevenue: 0, pending: 0, shipped: 0, delivered: 0 },
    );

    return res.json({ shop, products, orders, stats });
}

export async function listProducts(req, res) {
    const { shopId } = req.query;
    const products = shopId ? await getProductsByShop(shopId) : await getAllProducts();
    return res.json(products);
}

export async function getProduct(req, res) {
    const product = await getProductById(req.params.productId);
    if (!product) {
        return res.status(404).json({ message: 'Product not found' });
    }
    return res.json(product);
}

export async function createProduct(req, res) {
    const shopId = Number(req.body.shopId);
    const ownerUserId = Number(req.body.ownerUserId);
    const name = cleanString(req.body.name);
    const description = cleanString(req.body.description);
    const category = cleanString(req.body.category);
    const price = numberOrZero(req.body.price);
    const stock = numberOrZero(req.body.stock);
    const imageUrl = getUploadPath(req.file) || cleanString(req.body.imageUrl);

    if (!shopId || !ownerUserId || !name || !description || !category) {
        return res.status(400).json({ message: 'shopId, ownerUserId, name, description, and category are required' });
    }

    const shop = await getShopById(shopId);
    if (!shop) {
        return res.status(404).json({ message: 'Shop not found' });
    }

    if (shop.ownerUserId !== ownerUserId) {
        return res.status(403).json({ message: 'You can only manage your own shop' });
    }

    const result = await query(
        'INSERT INTO products (shop_id, owner_user_id, name, description, price, stock, category, image_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [shopId, ownerUserId, name, description, price, stock, category, imageUrl],
    );

    const product = await getProductById(result.insertId);
    return res.status(201).json(product);
}

export async function updateProduct(req, res) {
    const productId = Number(req.params.productId);
    const ownerUserId = Number(req.body.ownerUserId);
    const existing = await getProductById(productId);

    if (!existing) {
        return res.status(404).json({ message: 'Product not found' });
    }

    const shop = await getShopById(existing.shopId);
    if (!shop || shop.ownerUserId !== ownerUserId) {
        return res.status(403).json({ message: 'You can only manage your own shop' });
    }

    const name = cleanString(req.body.name) || existing.name;
    const description = cleanString(req.body.description) || existing.description;
    const category = cleanString(req.body.category) || existing.category;
    const price = req.body.price !== undefined ? numberOrZero(req.body.price) : existing.price;
    const stock = req.body.stock !== undefined ? numberOrZero(req.body.stock) : existing.stock;
    const imageUrl = getUploadPath(req.file) || cleanString(req.body.imageUrl) || existing.imageUrl;

    await query(
        'UPDATE products SET name = ?, description = ?, price = ?, stock = ?, category = ?, image_url = ? WHERE id = ?',
        [name, description, price, stock, category, imageUrl, productId],
    );

    return res.json(await getProductById(productId));
}

export async function removeProduct(req, res) {
    const productId = Number(req.params.productId);
    const ownerUserId = Number(req.body.ownerUserId || req.query.ownerUserId);
    const existing = await getProductById(productId);

    if (!existing) {
        return res.status(404).json({ message: 'Product not found' });
    }

    const shop = await getShopById(existing.shopId);
    if (!shop || shop.ownerUserId !== ownerUserId) {
        return res.status(403).json({ message: 'You can only manage your own shop' });
    }

    await query('DELETE FROM products WHERE id = ?', [productId]);
    return res.json({ message: 'Product deleted' });
}

export async function uploadProductImage(req, res) {
    if (!req.file) {
        return res.status(400).json({ message: 'image file is required' });
    }

    return res.status(201).json({ imageUrl: getUploadPath(req.file) });
}

export async function getCart(req, res) {
    const userId = Number(req.params.userId);
    return res.json(await getCartForUser(userId));
}

export async function addCartItem(req, res) {
    const userId = Number(req.body.userId);
    const productId = Number(req.body.productId);
    const quantity = Math.max(Number(req.body.quantity || 1), 1);

    const product = await getProductById(productId);
    if (!product) {
        return res.status(404).json({ message: 'Product not found' });
    }

    const cart = await ensureCartForUser(userId);
    const existing = await query('SELECT * FROM cart_items WHERE cart_id = ? AND product_id = ? LIMIT 1', [cart.id, productId]);

    if (existing[0]) {
        await query('UPDATE cart_items SET quantity = quantity + ? WHERE id = ?', [quantity, existing[0].id]);
    } else {
        await query('INSERT INTO cart_items (cart_id, product_id, quantity) VALUES (?, ?, ?)', [cart.id, productId, quantity]);
    }

    return res.status(201).json(await getCartForUser(userId));
}

export async function updateCartItem(req, res) {
    const userId = Number(req.body.userId);
    const productId = Number(req.params.productId);
    const quantity = Number(req.body.quantity);
    const cart = await ensureCartForUser(userId);
    const existing = await query('SELECT * FROM cart_items WHERE cart_id = ? AND product_id = ? LIMIT 1', [cart.id, productId]);

    if (!existing[0]) {
        return res.status(404).json({ message: 'Cart item not found' });
    }

    if (quantity <= 0) {
        await query('DELETE FROM cart_items WHERE id = ?', [existing[0].id]);
    } else {
        await query('UPDATE cart_items SET quantity = ? WHERE id = ?', [quantity, existing[0].id]);
    }

    return res.json(await getCartForUser(userId));
}

export async function removeCartItem(req, res) {
    const userId = Number(req.query.userId || req.body.userId);
    const productId = Number(req.params.productId);
    const cart = await ensureCartForUser(userId);
    await query('DELETE FROM cart_items WHERE cart_id = ? AND product_id = ?', [cart.id, productId]);
    return res.json(await getCartForUser(userId));
}

export async function clearCart(req, res) {
    const userId = Number(req.params.userId);
    const cart = await ensureCartForUser(userId);
    await query('DELETE FROM cart_items WHERE cart_id = ?', [cart.id]);
    return res.json(await getCartForUser(userId));
}

export async function checkoutCart(req, res) {
    const userId = Number(req.body.userId);
    const shippingAddress = cleanString(req.body.shippingAddress);
    const items = await getCartItems(userId);

    if (items.length === 0) {
        return res.status(400).json({ message: 'Cart is empty' });
    }

    const groups = new Map();
    for (const item of items) {
        const key = String(item.product.shopId);
        if (!groups.has(key)) {
            groups.set(key, []);
        }
        groups.get(key).push(item);
    }

    const createdOrderIds = [];

    await transaction(async (connection) => {
        for (const [shopId, groupedItems] of groups.entries()) {
            const subtotal = groupedItems.reduce((sum, item) => sum + item.quantity * item.product.price, 0);
            const [result] = await connection.query(
                'INSERT INTO orders (buyer_user_id, shop_id, status, subtotal, total, shipping_address) VALUES (?, ?, ?, ?, ?, ?)',
                [userId, Number(shopId), 'pending', subtotal, subtotal, shippingAddress],
            );

            for (const item of groupedItems) {
                await connection.query(
                    'INSERT INTO order_items (order_id, product_id, product_name, price, quantity, image_url) VALUES (?, ?, ?, ?, ?, ?)',
                    [result.insertId, item.productId, item.product.name, item.product.price, item.quantity, item.product.imageUrl],
                );

                await connection.query('UPDATE products SET stock = stock - ? WHERE id = ?', [item.quantity, item.productId]);
                await connection.query(
                    `
                    DELETE ci
                    FROM cart_items ci
                    JOIN carts c ON c.id = ci.cart_id
                    WHERE c.user_id = ? AND ci.product_id = ?
                    `,
                    [userId, item.productId],
                );
            }

            createdOrderIds.push(result.insertId);
        }
    });

    const orders = [];
    for (const orderId of createdOrderIds) {
        const order = await getOrderWithItems(orderId);
        if (order) {
            orders.push(order);
        }
    }

    return res.status(201).json({ orders });
}

export async function getBuyerOrders(req, res) {
    return res.json(await getOrdersByBuyer(Number(req.params.userId)));
}

export async function getShopOrders(req, res) {
    return res.json(await getOrdersByShop(Number(req.params.shopId)));
}

export async function updateOrderStatus(req, res) {
    const orderId = Number(req.params.orderId);
    const status = cleanString(req.body.status);

    if (!['pending', 'shipped', 'delivered'].includes(status)) {
        return res.status(400).json({ message: 'Invalid order status' });
    }

    const existing = await getOrderWithItems(orderId);
    if (!existing) {
        return res.status(404).json({ message: 'Order not found' });
    }

    await query('UPDATE orders SET status = ? WHERE id = ?', [status, orderId]);
    return res.json(await getOrderWithItems(orderId));
}

export async function getInvoice(req, res) {
    const order = await getOrderWithItems(Number(req.params.orderId));
    if (!order) {
        return res.status(404).json({ message: 'Order not found' });
    }

    const buyer = await getUserById(order.buyerUserId);
    const shop = await getShopById(order.shopId);

    return res.json({
        invoiceNumber: `INV-${String(order.id).padStart(5, '0')}`,
        buyer,
        shop,
        order,
    });
}