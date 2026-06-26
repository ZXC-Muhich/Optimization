# Optimization

До оптимізації:
<img width="722" height="56" alt="image" src="https://github.com/user-attachments/assets/aa5e5cd0-5e51-4d6b-a98a-1a1bc1417c36" />

Після оптимізації:
<img width="836" height="73" alt="image" src="https://github.com/user-attachments/assets/052d6b24-01de-4204-be72-bdff31512c51" />

Що я зробив:
* Відфільтрував та об'єднав через Join потрібні рядки один раз у CTE "filtered_data", щоб уникнути повторного сканування таблиць.
* Використав віконні функції замість неоптимальних агрегатних функцій MIN(), MAX().
* Створив індекси на колонках фільтрації та з'єднання для оптимізаці:
    * "opt_orders(order_date)"
    * "opt_orders(product_id)"
    * "opt_orders(client_id)"
    * "opt_clients(status)"
    * "opt_products(product_category)"

Optimizer control (extra 2 points):
<img width="849" height="50" alt="image" src="https://github.com/user-attachments/assets/c09fbab4-0fd8-48ad-9e72-1a1a0b7e59af" />

Що я зробив:
"Optimizer control using planner settings"

* Тимчасово вимкнув використання індексів:
SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;
* Запустив код і зафіксував спад продуктивності.
* Повернув все назад: 
SET enable_indexscan = ON;
SET enable_bitmapscan = ON;
