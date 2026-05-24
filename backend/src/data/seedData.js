export const seedUsers = [
    { id: 1, name: 'Ava Buyer', email: 'buyer@example.com', password: 'buyer123', role: 'buyer', avatarUrl: '' },
    { id: 2, name: 'Sam Seller', email: 'seller@example.com', password: 'seller123', role: 'seller', avatarUrl: '' },
];

export const seedShops = [
    {
        id: 1,
        ownerUserId: 2,
        name: "Sam's Shop",
        description: 'A local demo shop for electronics and everyday essentials.',
        logoUrl: '',
    },
];

export const seedProducts = [
    {
        id: 1,
        shopId: 1,
        ownerUserId: 2,
        name: 'Aurora Headphones',
        description: 'Wireless headphones with clean sound and long battery life.',
        price: 89.99,
        stock: 24,
        category: 'Electronics',
        imageUrl: '',
    },
    {
        id: 2,
        shopId: 1,
        ownerUserId: 2,
        name: 'Studio Desk Lamp',
        description: 'Minimal desk lamp with soft light and adjustable brightness.',
        price: 34.5,
        stock: 41,
        category: 'Home',
        imageUrl: '',
    },
    {
        id: 3,
        shopId: 1,
        ownerUserId: 2,
        name: 'Pocket Power Bank',
        description: 'Fast-charging power bank with dual USB output.',
        price: 39.95,
        stock: 27,
        category: 'Electronics',
        imageUrl: '',
    },
    {
        id: 4,
        shopId: 1,
        ownerUserId: 2,
        name: 'Ceramic Mug Set',
        description: 'A simple mug set for coffee and tea lovers.',
        price: 22,
        stock: 30,
        category: 'Home',
        imageUrl: '',
    },
];

export const seedCarts = [{ id: 1, userId: 1 }];

export const seedCartItems = [
    { id: 1, cartId: 1, productId: 1, quantity: 1 },
    { id: 2, cartId: 1, productId: 4, quantity: 2 },
];

export const seedOrders = [
    {
        id: 1,
        buyerUserId: 1,
        shopId: 1,
        status: 'pending',
        subtotal: 134.99,
        total: 134.99,
        shippingAddress: '123 Market St, Demo City',
    },
    {
        id: 2,
        buyerUserId: 1,
        shopId: 1,
        status: 'shipped',
        subtotal: 34.5,
        total: 34.5,
        shippingAddress: '123 Market St, Demo City',
    },
];

export const seedOrderItems = [
    { id: 1, orderId: 1, productId: 1, productName: 'Aurora Headphones', price: 89.99, quantity: 1, imageUrl: '' },
    { id: 2, orderId: 1, productId: 4, productName: 'Ceramic Mug Set', price: 22, quantity: 2, imageUrl: '' },
    { id: 3, orderId: 2, productId: 2, productName: 'Studio Desk Lamp', price: 34.5, quantity: 1, imageUrl: '' },
];