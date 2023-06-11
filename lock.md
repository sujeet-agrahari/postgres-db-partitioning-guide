1. tables can be read concurrently. Many users reading the same data at the same time won’t block each other. This allows PostgreSQL to handle thousands of users without any problems.
2. Write transactions won’t block read transactions. A transaction will only see data if it has been committed by the write transaction before the initiation of the read transaction. One transaction cannot inspect the changes that have been made by another active connection. A transaction can see only those changes that have already been committed.
3. two write operation (update) on the same row will lock the row. The second write will wait until the first write is finished on the row. PostgreSQL will only lock rows affected by UPDATE. So, if you have 1,000 rows, you can theoretically run 1,000 concurrent changes on the same table.
   https://shiroyasha.io/understanding-postgresql-locks.html

[Toast](https://www.percona.com/blog/unlocking-the-secrets-of-toast-how-to-optimize-large-column-storage-in-postgresql-for-top-performance-and-scalability/#:~:text=Therefore%2C%20TOAST%20is%20a%20storage,separately%20from%20the%20main%20table.)
[Lock](https://www.linuxtopia.org/online_books/database_guides/Practical_PostgreSQL_database/PostgreSQL_r27479.htm#:~:text=The%20ACCESS%20SHARE%20MODE%20lock,acquired%20on%20the%20same%20table.)
[Lock](https://engineering.nordeus.com/postgres-locking-revealed/)

```sql
-- check for locks
SELECT
	pid,
	wait_event_type,
	wait_event,
	query
FROM
	pg_stat_activity
WHERE
	datname = 'quick_link';

SELECT
	*
FROM
	quick_link;

-- pg_class is a system catalog table in PostgreSQL that stores metadata about tables, indexes, views, and other relations in the database.
SELECT
	*
FROM
	pg_class;

-- regclass data type represents the object identifier (OID) of a table or relation in the system catalog
SELECT
	oid
FROM
	pg_class
WHERE
	relname = 'quick_link';

-- cast the string to reglcass data type (oid)
SELECT
	relname,
	relkind
FROM
	pg_class
WHERE
	oid = 'quick_link'::regclass;

-- get details using oid
SELECT
	*
FROM
	pg_class
WHERE
	oid = '16884'::regclass;

SELECT
	16884::regclass;

-- get the owner of the object using oid
SELECT
	r.rolname AS owner_name
FROM
	pg_class c
	JOIN pg_roles r ON c.relowner = r.oid
WHERE
	c.oid = 16884;
-- toast:

-- find out all tables with TOAST tables
SELECT
	oid::regclass,
	reltoastrelid::regclass,
	pg_relation_size(reltoastrelid) AS toast_size
FROM
	pg_class
WHERE
	relkind = 'r'
	AND reltoastrelid <> 0
ORDER BY
	3 DESC;

-- reltoastrelid, pg_toast.pg_toast_16884, has the 16884 the numeric part which is the parent relation of the toast. Using this we can get the parent;

SELECT 16884::regclass;

-- get toasted column
SELECT attname
FROM pg_attribute
WHERE attrelid = 'quick_link'::regclass
  AND attisdropped = false
  AND attstorage = 'x';

-- force quick_link to create toast table
INSERT INTO quick_link ("actualLink", "shortLink", "redirectLink")
VALUES (
    repeat('A', 1000000),
    repeat('B', 1000000),
    repeat('C', 1000000)
);

-- get all the toast tables for a table
SELECT
	oid::regclass,
	reltoastrelid::regclass,
	pg_relation_size(reltoastrelid) AS toast_size
FROM
	pg_class
WHERE
	relkind = 'r'
	--AND reltoastrelid <> 0
	AND oid = 'quick_link'::regclass;

-- get toast data
SELECT * FROM pg_toast.pg_toast_16884;

-- pg_attributes stores column level information of the relations
/**

In PostgreSQL, the pg_attribute system catalog table stores information about the attributes (columns) of a table, including their names, data types, constraints, and other metadata. It provides valuable insights into the structure and characteristics of a table's columns. Here's a brief explanation of the columns in the pg_attribute table:

attrelid: The OID (object ID) of the table to which the attribute belongs.
attname: The name of the attribute (column).
atttypid: The OID of the data type of the attribute.
attstattarget: A statistics target for the attribute.
attlen: The storage length of the attribute's data type.
attnum: The attribute number, representing the order of the attribute within the table's column list.
attndims: The number of dimensions for an array attribute.
attcacheoff: The offset in bytes to the attribute's value within the table's tuple.
atttypmod: The type modifier associated with the attribute.
attbyval: A boolean indicating whether the attribute's data type is passed by value or reference.
attstorage: The storage type for the attribute, indicating if it's stored on disk or in memory.
attalign: The alignment requirement of the attribute's data type.
attnotnull: A boolean indicating whether the attribute is defined as NOT NULL.
atthasdef: A boolean indicating whether the attribute has a default value defined.
attisdropped: A boolean indicating whether the attribute has been dropped (no longer exists).
attislocal: A boolean indicating whether the attribute is locally defined in the table or inherited from a parent table.
attinhcount: The number of child tables that inherit the attribute.
**/
SELECT * FROM pg_attribute;

-- get details of quick_link
SELECT * FROM pg_attribute WHERE attrelid = 16884;

-- if the total size of a tuple (row) exceeds the maximum page size of 8KB, it can trigger TOAST compression

```

PostgreSQL allows reads (SELECT statements) to occur on the table in parallel with index creation, but writes (INSERT, UPDATE, DELETE) are blocked until the index build is finished
