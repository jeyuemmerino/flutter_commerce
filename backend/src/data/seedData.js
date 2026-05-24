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
        name: 'Nikon Z Camera',
        description: 'Professional mirrorless camera with 24.2MP sensor and stunning optical quality.',
        price: 1299.99,
        stock: 5,
        category: 'Photography',
        imageUrl: '/uploads/1779631993287-840356724.png',
    },
    {
        id: 2,
        shopId: 1,
        ownerUserId: 2,
        name: 'Harry Potter Complete Collection',
        description: 'The full 7-book collection in a beautiful boxed set. Perfect for collectors and fans.',
        price: 79.99,
        stock: 12,
        category: 'Books',
        imageUrl: '/uploads/1779632023964-102916838.png',
    },
    {
        id: 3,
        shopId: 1,
        ownerUserId: 2,
        name: 'Tease Perfume Fragrance',
        description: 'Luxurious floral fragrance with a bold, playful essence. Signature scent for everyday elegance.',
        price: 54.99,
        stock: 18,
        category: 'Beauty',
        imageUrl: '/uploads/1779632066949-730972703.png',
    },
    {
        id: 4,
        shopId: 1,
        ownerUserId: 2,
        name: 'Classic Levi\'s Jeans',
        description: 'Timeless denim jeans with authentic fit and premium quality. A wardrobe essential.',
        price: 89.99,
        stock: 22,
        category: 'Clothing',
        imageUrl: '/uploads/1779632093207-838799771.png',
    },
    {
        id: 5,
        shopId: 1,
        ownerUserId: 2,
        name: 'USB Charging Cable Set',
        description: 'Fast-charging USB and Lightning cables. Durable and certified for all devices.',
        price: 24.99,
        stock: 35,
        category: 'Electronics',
        imageUrl: '/uploads/1779632146784-375249154.png',
    },
    {
        id: 6,
        shopId: 1,
        ownerUserId: 2,
        name: 'Mechanical Keyboard',
        description: 'Premium mechanical keyboard with tactile switches and customizable RGB lighting.',
        price: 149.99,
        stock: 8,
        category: 'Electronics',
        imageUrl: '/uploads/1779632165188-226883835.png',
    },
    {
        id: 7,
        shopId: 1,
        ownerUserId: 2,
        name: 'Decorative Ceramic Vase',
        description: 'Handcrafted ceramic vase with vibrant artwork. Perfect for flowers and home décor.',
        price: 49.99,
        stock: 14,
        category: 'Home',
        imageUrl: '/uploads/1779632194407-273749365.png',
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
    { id: 1, orderId: 1, productId: 1, productName: 'Nikon Z Camera', price: 1299.99, quantity: 1, imageUrl: '/uploads/1779631993287-840356724.png' },
    { id: 2, orderId: 1, productId: 7, productName: 'Decorative Ceramic Vase', price: 49.99, quantity: 2, imageUrl: '/uploads/1779632194407-273749365.png' },
    { id: 3, orderId: 2, productId: 2, productName: 'Harry Potter Complete Collection', price: 79.99, quantity: 1, imageUrl: '/uploads/1779632023964-102916838.png' },
];