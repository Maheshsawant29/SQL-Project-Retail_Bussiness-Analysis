import random
from faker import Faker
from datetime import timedelta, date

fake = Faker('en_IN')

# Configuration
NUM_STAFF = 20
NUM_CUSTOMERS = 8000
NUM_INVOICES_GOAL = 5000
output_file = "optical_data_seed_high_volume.sql"

# --- MAPPINGS FROM YOUR SCHEMA ---
BRAND_MAP = {
    1: list(range(1, 11)),   # Frames
    2: list(range(11, 18)),  # Glass
    3: [18, 19],             # Sunglass
    4: [20, 21, 22],         # Contact Lens
    5: [23],                 # Accessories
    6: [24, 25]              # Lens Solution
}

TYPE_MAP = {
    1: list(range(1, 12)),   # Frame Types
    2: list(range(12, 19)),  # Glass Types
    3: list(range(19, 30)),  # Sunglass Types
    4: list(range(30, 36)),  # Contact Lens Types
    6: [36]                  # Liquid
}

def generate_sql():
    sql_statements = []
    
    # 1. OPTIMIZATION HEADERS
    sql_statements.append("SET FOREIGN_KEY_CHECKS = 0;")
    sql_statements.append("SET AUTOCOMMIT = 0;")
    sql_statements.append("START TRANSACTION;")

    # 2. STAFF (20 rows)
    staff_ids = list(range(1, NUM_STAFF + 1))
    for s_id in staff_ids:
        name = str(fake.name()).replace("'", "")
        contact = str(fake.msisdn())[:10]
        sql_statements.append(f"INSERT INTO staff (staff_id, staff_full_name, designation, contact_number, hire_date) VALUES ({s_id}, '{name}', 'Sales Executive', '{contact}', '2023-01-01');")

    # 3. CUSTOMERS (8000 rows)
    customer_ids = list(range(1, NUM_CUSTOMERS + 1))
    for c_id in customer_ids:
        name = str(fake.name()).replace("'", "")
        age = random.randint(18, 85)
        mobile = str(fake.msisdn())[:10]
        ref_id = str(random.choice(range(1, c_id))) if c_id > 1 and random.random() < 0.1 else "NULL"
        s_id = random.choice(staff_ids)
        sql_statements.append(f"INSERT INTO customers_details (customer_id, customer_full_name, age, mobile, customer_type, referred_by_id, assigned_staff_id) VALUES ({c_id}, '{name}', {age}, '{mobile}', 'New', {ref_id}, {s_id});")

    # 4. PRESCRIPTIONS (8000 rows)
    for c_id in customer_ids:
        visit_date = str(fake.date_between(start_date='-2y', end_date='today'))
        r_sph = str(round(random.uniform(-4, 4), 2))
        l_sph = str(round(random.uniform(-4, 4), 2))
        sql_statements.append(f"INSERT INTO prescriptions (customer_id, visit_date, r_sph, r_cyl, r_axis, l_sph, l_cyl, l_axis, vision_type) VALUES ({c_id}, '{visit_date}', {r_sph}, 0.00, 90, {l_sph}, 0.00, 90, '{random.choice(['Near', 'Distance', 'Bifocal', 'Progressive'])}');")

    # 5. INVOICES (5000 rows)
    # We use a set to track which customers already have "Additional Details"
    customers_with_details = set()
    invoice_customer_pool = random.choices(customer_ids, k=NUM_INVOICES_GOAL)
    current_item_id = 1
    
    for inv_idx, c_id in enumerate(invoice_customer_pool, start=1):
        inv_date = str(fake.date_between(start_date='-1y', end_date='today'))
        pay_mode = random.choice(['Cash', 'UPI', 'Card'])
        
        sql_statements.append(f"INSERT INTO invoices (invoice_id, customer_id, staff_id, invoice_date, payment_mode, total_amount_items, total_tax, discount_amount) VALUES ({inv_idx}, {c_id}, {random.choice(staff_ids)}, '{inv_date}', '{pay_mode}', 0, {random.randint(150, 500)}, 0);")
        
        # Table 8: Items
        num_items = random.randint(1, 3)
        total_inv_price = 0
        for _ in range(num_items):
            p_id = random.choice([1, 2, 3, 4, 6])
            b_id = random.choice(BRAND_MAP[p_id])
            t_id = random.choice(TYPE_MAP[p_id])
            qty = 2 if p_id == 2 else 1
            price = random.randint(500, 7000)
            total_inv_price += (price * qty)
            sql_statements.append(f"INSERT INTO invoice_items (invoice_id, item_id, product_id, brand_id, product_type_id, quantity, unit_selling_price) VALUES ({inv_idx}, {current_item_id}, {p_id}, {b_id}, {t_id}, {qty}, {price});")
            current_item_id += 1
        
        sql_statements.append(f"UPDATE invoices SET total_amount_items = {total_inv_price} WHERE invoice_id = {inv_idx};")

        # Table 9: Additional Customer Details (5000 UNIQUE rows)
        # FIX: Only insert if the customer_id hasn't been used in this table yet
        if c_id not in customers_with_details and len(customers_with_details) < 5000:
            sql_statements.append(f"INSERT INTO additional_customer_details (customer_id, date_of_customer_visit, number_of_days_to_deliver_Product, fiter_Name, glass_distributor_name, time_spend_by_customer_in_shop) VALUES ({c_id}, '{inv_date}', {random.randint(1, 7)}, 'Fitter {random.randint(1,5)}', 'Distributor {random.randint(1,3)}', {random.randint(10, 50)});")
            customers_with_details.add(c_id)

    # 6. FOOTERS
    sql_statements.append("COMMIT;")
    sql_statements.append("SET FOREIGN_KEY_CHECKS = 1;")

    with open(output_file, "w", encoding="utf-8") as f:
        for stmt in sql_statements:
            f.write(str(stmt) + "\n")
    
    print(f"--- GENERATION COMPLETE ---")
    print(f"File: {output_file}")

if __name__ == "__main__":
    generate_sql()