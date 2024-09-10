Install Postgres (https://www.postgresql.org/download/windows/)
- Password: postgres 
- Port: 5432
Add Postgres to PATH (C:\Program Files\PostgreSQL\16\bin)
Connect to Postgres
- psql -U postgres
- for password, enter the password provided during installation ("postgres"(?))
Execute commands to create DB
- CREATE DATABASE inventory;
- CREATE DATABASE orders;
Create tables
- inventory
  - Switch to the inventory DB:
    - \c inventory
	- Run the following DML statement
	```
        CREATE TABLE inventory (item VARCHAR(255) UNIQUE NOT NULL, count INTEGER);
    ```
  - Switch to the orders DB:
    - \c orders
	- Run the following DML statement
	```
         CREATE TABLE orders (time TIMESTAMP DEFAULT CURRENT_TIMESTAMP, item TEXT);
	```