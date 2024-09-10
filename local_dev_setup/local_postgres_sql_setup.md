Install Postgres (https://www.postgresql.org/download/windows/)
- Password: postgres 
- Port: 5432
Connect to Postgres
- psql -U postgres
Execute commands to create DB
- CREATE DATABASE inventory_world;
- CREATE DATABASE orders_world;
Create tables
- inventory
  - Switch to the inventory_world DB:
    - \c inventory_world
	- Run the following DML statement
	```
        CREATE TABLE inventory (
          item TEXT,
          count INTEGER
       );
    ```
  - Switch to the orders_world DB:
    - \c orders_world
	- Run the following DML statement
	```
        CREATE TABLE orders (
          time TIMESTAMP,
          item TEXT
        );
	```