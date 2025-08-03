import mysql.connector
import time

# Connect to MySQL
conn = mysql.connector.connect(
    host='localhost',
    port=3307,
    user='root',
    password='123',
    database='ecommerce'
)

cursor = conn.cursor()

for i in range(1, 51):
    print(f"▶️ Running insert batch {i}/50...")

    # Execute the stored procedure
    cursor.execute("CALL insert_users_chunk();")

    # ✅ Read and print the result set to clear the buffer
    result = cursor.fetchall()
    for row in result:
        print(row[0]) 

    while cursor.nextset():
        pass

    conn.commit()
    time.sleep(1)

cursor.close()
conn.close()

print("✅ All 5 million rows inserted (if each chunk = 100k)")
