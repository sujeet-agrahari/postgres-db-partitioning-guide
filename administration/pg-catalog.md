The PostgreSQL System Catalog is a schema with tables and views that contain metadata about all the other objects inside the database and more. With it, we can discover when various operations happen, how tables or indexes are accessed, and even whether or not the database system is reading information from memory or needing to fetch data from disk.

PostgreSQL stores the metadata information about the database and cluster in the schema ‘pg_catalog’. This information is partially used by PostgreSQL itself to keep track of things itself, but it also is presented so external people / processes can understand the inside of the databases too.

The PostgreSQL Catalog has a pretty solid rule: Look, don’t touch. While PostgreSQL stores all this information in tables like any other application would, the data in the tables are fully managed by PostgreSQL itself, and should not be modified unless an absolute emergency, and even then a rebuild is likely in order afterwards.

1. `pg_stat_activity`: Provides information about the current database sessions, including the queries being executed, session states, and other details.

2. `pg_stat_user_tables`: Displays statistics about user-defined tables, such as the number of live and dead tuples, last analyze and vacuum timestamps, etc.

3. `pg_stat_all_tables`: Similar to `pg_stat_user_tables`, but includes system tables as well.

4. `pg_stat_user_indexes`: Shows statistics related to user-defined indexes, including the number of scans, tuples fetched, block reads/writes, etc.

5. `pg_stat_all_indexes`: Similar to `pg_stat_user_indexes`, but includes system indexes as well.

6. `pg_stat_user_functions`: Provides statistics about user-defined functions, such as the number of calls, total time, self time, etc.

7. `pg_stat_statements`: Tracks statistics for all SQL statements executed in the database, including the number of calls, total time, average time, etc. This requires the `pg_stat_statements` extension to be installed.

8. `pg_indexes`: Lists all indexes in the current database, along with their table names and column names.

9. `pg_tables`: Displays information about tables in the current database, including table names, schema names, and whether they are temporary or not.

10. `pg_views`: Shows views in the current database, including their names, schema names, and the definition of each view.

11. `pg_roles`: Provides information about database roles, including their names, privileges, and other attributes.

12. `pg_database`: Lists all databases in the PostgreSQL cluster, including their names, sizes, and encoding.

13. `pg_settings`: Displays the current settings of PostgreSQL configuration parameters.

14. `pg_locks`: Shows information about current locks held on database objects, including the lock type, relation name, and lock mode.
