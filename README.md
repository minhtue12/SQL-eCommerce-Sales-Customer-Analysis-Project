# 🛒 SQL eCommerce Sales Analysis  

## 🎯 1️⃣ Mục tiêu Dự án  

Phân tích toàn diện hoạt động bán hàng của một **website thương mại điện tử**, bao gồm:  
- Hiểu **hành vi mua hàng của khách**  
- Đánh giá **hiệu suất sản phẩm**  
- Phân tích **doanh thu, lợi nhuận và đơn hàng theo thời gian**  

---

## 🧱 2️⃣ Cấu trúc dữ liệu  

🔹 **Các bảng chính:**
- `customers` – Thông tin khách hàng  
- `products` – Thông tin sản phẩm  
- `orders` – Thông tin đơn hàng  
- `order_items` – Chi tiết từng sản phẩm trong đơn  

---

## 🧭 3️⃣ Khám phá dữ liệu  

### 📊 Đếm số lượng bản ghi trong mỗi bảng
```sql
SELECT 'customers' AS table_name, COUNT(*) AS total_rows FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;
🔍 Kiểm tra giá trị NULL trong các bảng
sql
Copy code
SELECT COUNT(*) AS null_customers 
FROM customers 
WHERE customer_id IS NULL OR customer_name IS NULL;

SELECT COUNT(*) AS null_orders 
FROM orders 
WHERE order_date IS NULL OR customer_id IS NULL;

SELECT COUNT(*) AS null_items 
FROM order_items 
WHERE product_id IS NULL OR quantity IS NULL;
💰 4️⃣ Phân tích Doanh thu & Đơn hàng
🔸 Tổng quan doanh thu toàn hệ thống
sql
Copy code
SELECT 
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers,
    SUM(oi.total_price) AS total_revenue,
    AVG(oi.total_price) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id;
📈 Kết quả & Nhận xét
Chỉ số	Giá trị
🧾 Tổng số đơn hàng	20,000
👥 Tổng số khách hàng	2,996
💵 Tổng doanh thu	5,086,420.48 USD
💳 Giá trị trung bình mỗi đơn	173.22 USD

➡️ Nhận xét:

Gần 3,000 khách hàng tạo ra 20,000 đơn hàng, trung bình ~6.7 đơn hàng/khách.

Mức chi tiêu trung bình 173 USD/đơn, phản ánh khả năng chi tiêu cao của nhóm khách hàng.

🔸 Doanh thu theo tháng
sql
Copy code
SELECT 
    YEAR(o.order_date) AS year,
    MONTH(o.order_date) AS month,
    SUM(oi.total_price) AS monthly_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY YEAR(o.order_date), MONTH(o.order_date)
ORDER BY year, month;
📊 Nhận xét:
Doanh thu tăng mạnh từ tháng 10/2024 → tháng 4/2025, đạt đỉnh tại tháng 4/2025 (≈467K USD).

Sau tháng 6/2025, doanh thu giảm nhẹ đến tháng 10/2025.

Giai đoạn Q1–Q2/2025 có thể được xem là mùa cao điểm doanh số.

🔸 Top 10 sản phẩm bán chạy nhất
sql
Copy code
SELECT TOP 10
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.total_price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_quantity_sold DESC;
➡️ Insight:

Top sản phẩm chiếm tỷ trọng doanh thu lớn.

Nên ưu tiên quảng cáo hoặc khuyến mãi cho các sản phẩm top đầu này để tối ưu doanh thu.

🔸 Doanh thu theo danh mục sản phẩm
sql
Copy code
SELECT 
    p.category,
    SUM(oi.total_price) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;
📊 Nhận xét:
Danh mục	Tỷ trọng doanh thu	Tỷ trọng đơn hàng	Ghi chú
💄 Beauty	21.87%	21.91%	Dẫn đầu, sức mua cao và ổn định
🏃‍♀️ Sportswear	17.45%	Hiệu suất cao/đơn	Nên đẩy mạnh quảng cáo
🎧 Electronics	15.99%	-	Doanh thu tốt, cạnh tranh mạnh
👓 Accessory	17.31%	-	Có tiềm năng mở rộng
👟 Footwear	13.17%	-	Thấp nhất, cần xem lại chiến lược giá

➡️ Nhận xét tổng quan: Beauty và Sportswear là hai danh mục chủ lực; Footwear cần được tối ưu để cải thiện hiệu suất.

🔸 Tỷ lệ khách hàng quay lại (Repeat Rate)
sql
Copy code
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
📈 Kết quả:
Tổng khách hàng: 2,996

Khách hàng mua lại: 2,976

Tỷ lệ quay lại: 99.33%

➡️ Nhận xét:
Tỷ lệ khách hàng quay lại cực cao (≈99%) → thể hiện mức độ trung thành vượt trội, có thể nhờ:

Chất lượng sản phẩm tốt

Trải nghiệm mua hàng tích cực

Chính sách hậu mãi và chăm sóc khách hàng hiệu quả

🏁 5️⃣ Kết luận tổng quan
✅ Hiệu suất bán hàng mạnh mẽ, doanh thu duy trì quanh 400–470K USD/tháng
✅ Tệp khách hàng trung thành cao (Repeat Rate gần 100%)
✅ Sản phẩm Beauty & Sportswear là nhóm chủ lực, mang lại doanh thu cao nhất
⚠️ Cần chú ý danh mục Footwear & xu hướng giảm doanh thu sau tháng 6/2025 → nên triển khai chiến dịch giảm giá hoặc bundle combo để kích cầu.
