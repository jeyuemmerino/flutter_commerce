function parseItems(order) {
    if (Array.isArray(order.items)) {
        return order.items;
    }

    try {
        return JSON.parse(order.items_json || '[]');
    } catch {
        return [];
    }
}

export function buildAnalytics(products, orders) {
    const productMap = new Map(products.map((product) => [Number(product.id), product]));
    const productSales = new Map();
    const categorySales = new Map();

    let totalRevenue = 0;

    for (const order of orders) {
        totalRevenue += Number(order.total_price || order.totalPrice || 0);

        for (const item of parseItems(order)) {
            const product = productMap.get(Number(item.productId));
            const quantity = Number(item.quantity || 0);
            const lineTotal = Number(item.lineTotal || Number(item.price || 0) * quantity);

            if (!product) {
                continue;
            }

            productSales.set(product.id, {
                productId: product.id,
                name: product.name,
                category: product.category,
                quantity: (productSales.get(product.id)?.quantity || 0) + quantity,
                revenue: (productSales.get(product.id)?.revenue || 0) + lineTotal,
            });

            categorySales.set(product.category, (categorySales.get(product.category) || 0) + lineTotal);
        }
    }

    const topProducts = Array.from(productSales.values())
        .sort((left, right) => right.quantity - left.quantity)
        .slice(0, 5);

    const categoryPerformance = Array.from(categorySales.entries())
        .map(([category, revenue]) => ({ category, revenue }))
        .sort((left, right) => right.revenue - left.revenue);

    const bestSellingCategory = categoryPerformance[0]?.category || 'N/A';

    return {
        totalRevenue: Number(totalRevenue.toFixed(2)),
        totalOrders: orders.length,
        topProducts,
        categoryPerformance,
        bestSellingCategory,
    };
}

export function buildSalesInsights(analytics, products, orders) {
    const insights = [];
    insights.push(`Your best selling category is ${analytics.bestSellingCategory}.`);

    if (orders.length > 0) {
        insights.push(`Sales are healthy with ${analytics.totalOrders} completed orders and $${analytics.totalRevenue.toFixed(2)} in revenue.`);
    } else {
        insights.push('No orders yet. Promote your featured products to start collecting sales data.');
    }

    const lowStockProduct = products
        .filter((product) => Number(product.stock) <= 10)
        .sort((left, right) => Number(left.stock) - Number(right.stock))[0];

    if (lowStockProduct) {
        insights.push(`Recommend increasing stock for ${lowStockProduct.name}.`);
    }

    return insights;
}

export function buildDescription({ name, category }) {
    const productName = name?.trim() || 'this product';
    const productCategory = category?.trim() || 'marketplace';

    return `${productName} is a standout ${productCategory.toLowerCase()} pick built for customers who want clean design, practical value, and a polished buying experience. It is positioned for local demo marketplaces that need a confident, marketing-ready description without relying on external AI services.`;
}

export function buildRecommendations({ product, products, orders }) {
    const targetProduct = product || products[0];
    const targetCategory = targetProduct?.category;
    const targetId = Number(targetProduct?.id || 0);

    const trending = [...products]
        .sort((left, right) => Number(right.id) - Number(left.id))
        .slice(0, 4);

    const similarCategory = products
        .filter((item) => item.id !== targetId && item.category === targetCategory)
        .slice(0, 4);

    const coPurchaseCounts = new Map();

    for (const order of orders) {
        const items = Array.isArray(order.items) ? order.items : [];
        const containsTarget = items.some((item) => Number(item.productId) === targetId);

        if (!containsTarget) {
            continue;
        }

        for (const item of items) {
            if (Number(item.productId) === targetId) {
                continue;
            }

            coPurchaseCounts.set(Number(item.productId), (coPurchaseCounts.get(Number(item.productId)) || 0) + Number(item.quantity || 1));
        }
    }

    const frequentlyBoughtTogether = Array.from(coPurchaseCounts.entries())
        .sort((left, right) => right[1] - left[1])
        .map(([productId]) => products.find((item) => Number(item.id) === Number(productId)))
        .filter(Boolean)
        .slice(0, 4);

    return {
        trending,
        similarCategory,
        frequentlyBoughtTogether,
    };
}