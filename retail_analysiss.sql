
use SQL_eCommerce_Sales_Analysis
--Đếm số lượng bản ghi trong mỗi bảng
SELECT 'customers' AS table_name, COUNT(*) AS total_rows FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;
-- Kiểm tra giá trị NULL trong các bảng
SELECT COUNT(*) AS null_customers 
FROM customers 
WHERE customer_id IS NULL OR customer_name IS NULL;

SELECT COUNT(*) AS null_orders 
FROM orders 
WHERE order_date IS NULL OR customer_id IS NULL;

SELECT COUNT(*) AS null_items 
FROM order_items 
WHERE product_id IS NULL OR quantity IS NULL;
--Tổng quan doanh thu toàn hệ thống
SELECT 
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers,
    SUM(oi.total_price) AS total_revenue,
    AVG(oi.total_price) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id;
-- Doanh thu theo tháng
SELECT 
    YEAR(o.order_date) AS year,
    MONTH(o.order_date) AS month,
    SUM(oi.total_price) AS monthly_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY YEAR(o.order_date), MONTH(o.order_date)
ORDER BY year, month;
-- Top 10 sản phẩm bán chạy nhất
SELECT TOP 10
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.total_price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_quantity_sold DESC;
--  Doanh thu theo danh mục sản phẩm
SELECT 
    p.category,
    SUM(oi.total_price) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;
-- Tỷ lệ khách hàng quay lại (Repeat Rate)
SELECT 
    COUNT(*) AS total_customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(100.0 * SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_rate_pct
FROM (
    SELECT c.customer_id, COUNT(o.order_id) AS order_count
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
) t;
