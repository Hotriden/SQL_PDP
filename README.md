PDP MS SQL

Script description and order:
1. To initialize database and schema should run script "DB_initial_db.sql";
2. To fill tables by default data should run script "DB_initial_data.sql";
3. To generate data on tables from random values and with default data should run script "DB_randomizer(Cleared)sql.sql";
4. Due to "DB_randomizer(Cleared)sql.sql" is stored procedure to fill database with data should be setted up amount of iterations on script Task "Task1.sql" on line 1;
   Task 1:
   - To create vShipmentSearch (VIEW) should be runned script "Task1.sql" from line 4 to line 15. To Select data from this View should be runned line 17
   - To create and run CTE_shipmentSearch should be runned script "Task1.sql" from line 21 to line 34
   - To create and run CROSS APPLY expression should be runned script "Task1.sql" from line 38 to line 56
