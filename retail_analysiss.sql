------------------------------------------------------------
-- 🔹 1) Top 10 sản phẩm theo doanh thu
------------------------------------------------------------
SELECT TOP (10)
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.total_price) AS revenue,
    SUM(oi.quantity) AS total_qty_sold
FROM dbo.order_items oi
JOIN dbo.products p ON oi.product_id = p.product_id
JOIN dbo.orders o ON oi.order_id = o.order_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY revenue DESC;
GO


-- 🔹 2) Cặp sản phẩm được mua cùng nhau (Basket Analysis)
------------------------------------------------------------
SELECT TOP (20)
    oi1.product_id AS product_A,
    p1.product_name AS name_A,
    oi2.product_id AS product_B,
    p2.product_name AS name_B,
    COUNT(DISTINCT oi1.order_id) AS times_bought_together
FROM dbo.order_items oi1
JOIN dbo.order_items oi2
  ON oi1.order_id = oi2.order_id
  AND oi1.product_id < oi2.product_id
JOIN dbo.products p1 ON oi1.product_id = p1.product_id
JOIN dbo.products p2 ON oi2.product_id = p2.product_id
GROUP BY oi1.product_id, p1.product_name, oi2.product_id, p2.product_name
ORDER BY times_bought_together DESC;
GO

------------------------------------------------------------
-- 🔹 4) RFM Analysis (Recency, Frequency, Monetary)
------------------------------------------------------------
SELECT
    r.customer_id,
    r.last_order,
    r.recency_days,
    r.frequency,
    r.monetary
FROM (
    SELECT
        o.customer_id,
        MAX(o.order_date) AS last_order,
        DATEDIFF(DAY, MAX(o.order_date), GETDATE()) AS recency_days,
        COUNT(*) AS frequency,
        SUM(o.total_amount) AS monetary
    FROM dbo.orders o
    GROUP BY o.customer_id
) r
ORDER BY r.monetary DESC;
GO


