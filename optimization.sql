-- ============================================================
-- 1. Non-optimized query
-- ============================================================

EXPLAIN ANALYZE
SELECT
    (
        SELECT CONCAT(client_email, ': ', cnt)
        FROM (
            SELECT client_email, COUNT(*) AS cnt
            FROM (
                SELECT
                    o.order_id,
                    p.product_category,
                    c.email AS client_email
                FROM opt_orders AS o
                JOIN opt_products AS p
                    ON o.product_id = p.product_id
                JOIN opt_clients AS c
                    ON o.client_id = c.id
                WHERE o.order_date > DATE '2023-01-01'
                  AND c.status = 'active'
                  AND p.product_category = 'Category1'
            ) AS sub1
            GROUP BY client_email
        ) AS sub2
        WHERE cnt = (
            SELECT MIN(cnt)
            FROM (
                SELECT COUNT(*) AS cnt
                FROM (
                    SELECT
                        o.order_id,
                        p.product_category,
                        c.email AS client_email
                    FROM opt_orders AS o
                    JOIN opt_products AS p
                        ON o.product_id = p.product_id
                    JOIN opt_clients AS c
                        ON o.client_id = c.id
                    WHERE o.order_date > DATE '2023-01-01'
                      AND c.status = 'active'
                      AND p.product_category = 'Category1'
                ) AS sub3
                GROUP BY client_email
            ) AS sub4
        )
        LIMIT 1
    ) AS min_client,

    (
        SELECT CONCAT(client_email, ': ', cnt)
        FROM (
            SELECT client_email, COUNT(*) AS cnt
            FROM (
                SELECT
                    o.order_id,
                    p.product_category,
                    c.email AS client_email
                FROM opt_orders AS o
                JOIN opt_products AS p
                    ON o.product_id = p.product_id
                JOIN opt_clients AS c
                    ON o.client_id = c.id
                WHERE o.order_date > DATE '2023-01-01'
                  AND c.status = 'active'
                  AND p.product_category = 'Category1'
            ) AS sub1
            GROUP BY client_email
        ) AS sub2
        WHERE cnt = (
            SELECT MAX(cnt)
            FROM (
                SELECT COUNT(*) AS cnt
                FROM (
                    SELECT
                        o.order_id,
                        p.product_category,
                        c.email AS client_email
                    FROM opt_orders AS o
                    JOIN opt_products AS p
                        ON o.product_id = p.product_id
                    JOIN opt_clients AS c
                        ON o.client_id = c.id
                    WHERE o.order_date > DATE '2023-01-01'
                      AND c.status = 'active'
                      AND p.product_category = 'Category1'
                ) AS sub3
                GROUP BY client_email
            ) AS sub4
        )
        LIMIT 1
    ) AS max_client;


-- ============================================================
-- 2. Indexes for optimization
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_opt_orders_order_date
    ON opt_orders(order_date);

CREATE INDEX IF NOT EXISTS idx_opt_orders_product_id
    ON opt_orders(product_id);

CREATE INDEX IF NOT EXISTS idx_opt_orders_client_id
    ON opt_orders(client_id);

CREATE INDEX IF NOT EXISTS idx_opt_clients_status
    ON opt_clients(status);
    
CREATE INDEX IF NOT EXISTS idx_opt_products_category
    ON opt_products(product_category);


-- ============================================================
-- 3. Optimized query
-- ============================================================

EXPLAIN ANALYZE
WITH filtered_data AS (
    SELECT
        c.email AS client_email
    FROM opt_orders AS o
    JOIN opt_products AS p
        ON o.product_id = p.product_id
    JOIN opt_clients AS c
        ON o.client_id = c.id
    WHERE o.order_date > DATE '2023-01-01'
      AND c.status = 'active'
      AND p.product_category = 'Category1'
),
client_counts AS (
    SELECT
        client_email,
        COUNT(*) AS cnt
    FROM filtered_data
    GROUP BY client_email
),
ranked_clients AS (
    SELECT
        client_email,
        cnt,
        ROW_NUMBER() OVER (ORDER BY cnt ASC, client_email ASC) AS min_rn,
        ROW_NUMBER() OVER (ORDER BY cnt DESC, client_email ASC) AS max_rn
    FROM client_counts
)
SELECT
    MAX(CONCAT(client_email, ': ', cnt)) FILTER (WHERE min_rn = 1) AS min_client,
    MAX(CONCAT(client_email, ': ', cnt)) FILTER (WHERE max_rn = 1) AS max_client
FROM ranked_clients;


-- ============================================================
-- 4. Demonstrate optimizer control in PostgreSQL using planner settings (2 points)
-- ============================================================

SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;

...

SET enable_indexscan = ON;
SET enable_bitmapscan = ON;