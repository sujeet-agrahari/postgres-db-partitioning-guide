create table sampletable (x numeric);

select
	*
from
	sampletable;
-- if we don't have much data in the table sequential scan is used not the index
insert
	into
	sampletable
select
	random() * 10000
from
	generate_series(1,
	10); 

create index index_x on
sampletable(x);

explain
select
	*
from
	sampletable
where
	x = 9978.53896436862;
-- as the rows are less it will use sequencial scan

/**
Seq Scan on sampletable  (cost=0.00..27.00 rows=7 width=32)
  Filter: (x = 9978.53896436862)
  
**/

insert
	into
	sampletable
select
	random() * 10000
from
	generate_series(1,
	10000000);

explain
select
	*
from
	sampletable
where
	x = 9978.53896436862;

select
	column_name,
	data_type,
	character_maximum_length,
	is_nullable
from
	information_schema.columns
where
	table_name = 'sampletable';
-- seelcting small data will use index only scan
explain
select
	*
from
	sampletable
where
	x = 42353;
--- selecting a lot of data will use sequential scan
explain
select
	*
from
	sampletable s
where
	s.x < 42353;
-- bitmap scan

/**
If you only select a handful of rows, PostgreSQL will decide on an index scan – if you select a majority of the rows, 
PostgreSQL will decide to read the table completely. 
But what if you read too much for an index scan to be efficient but too little for a sequential scan?
**/
-- analyze will not just show the plan but also it will execute the query

explain (analyze true,
buffers true,
timing true)
    select
	*
from
	t_test
where
	id < 10000;

select
	*
from
	t_test
where
	id < 10000;

shared_preload_libraries = 'pg_stat_statements';

create extension pg_stat_statements;

select
	*
from
	pg_stat_statements;

select
	*
from
	pg_stat_statements
where
	query = 'SELECT * FROM pg_stat_statements WHERE query = $1';

select
	*
from
	consumer_complaints cc
limit 10;

select
	CURRENT_USER;

select
	*
from
	pg_stat_statements pss
join pg_roles pr on
	(userid = 16384);

select
	*
from
	pg_catalog.pg_roles ;

select
	*
from
	pg_stat_activity;
--which queries are very frequently run, as well as what they consume on average:
select
	(total_exec_time / 1000 / 60) as total,
	(total_exec_time / calls) as avg,
	query
from
	pg_stat_statements
order by
	1 desc
limit 100;
-- slowest running queries
select
	row_number() over (
	order by total_exec_time desc) num,
	round(total_exec_time),
	calls,
	rows,
	mean_exec_time,
	min_exec_time,
	max_exec_time,
	left(query,
	500)
from
	pg_stat_statements
order by
	total_exec_time desc
limit 50;
-- top 10 time consuming queries
select
	userid::regrole,
	dbid,
	query
from
	pg_stat_statements
order by
	mean_exec_time desc
limit 10;
-- to 10 memory consumption
   select
	userid::regrole,
	dbid,
	query
from
	pg_stat_statements
order by
	(shared_blks_hit + shared_blks_dirtied) desc
limit 10;
-- The reason why the query select * from pg_stat_statements prints the query select * from consumer_complaints cc limit $1 is because the pg_stat_statements view only stores the text of the first statement that was executed for a given query hash. In this case, the query select * from consumer_complaints cc limit $1 was the first statement that was executed for the query hash that corresponds to the query select * from consumer_complaints cc limit 10;.
-- To see the execution statistics for the query select * from consumer_complaints cc limit 10;, you need to use the query_hash column in the pg_stat_statements view. The query_hash column stores the hash of the query, and you can use it to uniquely identify the query. For example, to see the execution statistics for the query select * from consumer_complaints cc limit 10;, you can use the following query:

select
	*
from
	pg_stat_statements
where
	query_hash = (
	select
		query_hash
	from
		pg_stat_statements
	where
		query = 'select * from consumer_complaints cc limit 10;');

create table customers (
  id SERIAL not null,
  tenant_id varchar(255) not null,
  gender boolean not null,
  name VARCHAR(255) not null,
  email VARCHAR(255) not null,
  phone VARCHAR(255) not null,
  primary key (id)
);

create index tenant_id_phone_idx on
customers(tenant_id,
phone);

create table orders (
  id SERIAL not null,
  customer_id INT not null,
  order_date timestamp not null,
  order_total DECIMAL(10,
2) not null,
  primary key (id),
  foreign key (customer_id) references customers (id)
);

create index order_customer_id_idx on
orders(customer_id);
-- Generate random data for the customers table
-- Insert random data into "customers" table
insert
	into
	customers (tenant_id,
	gender,
	name,
	email,
	phone)
select
	md5(random()::text),
	random() < 0.5,
	md5(random()::text),
	md5(random()::text),
	md5(random()::text)
from
	generate_series(1,
	1000000);
-- Insert random data into "orders" table
insert
	into
	orders (customer_id,
	order_date,
	order_total)
select
	c.id as customer_id,
	current_timestamp + random() * interval '365 days',
	random() * 1000
from
	customers c
join
    (
	select
		id as customer_id
	from
		customers
	order by
		random()
	limit 100000) as subquery
on
	c.id = subquery.customer_id;

select
	*
from
	customers;

explain analyze
select
	*
from
	customers c
join orders o on
	o.customer_id = c.id
where
	c.tenant_id = 'c88b49e16697a03cf8cf084e050ed388'
	and c.phone = 'f656959694007529d888abf3664ba229'
	and c.name = '0045adcbdcb4cd5dccc1c3a6acc2d028';

select
	*
from
	orders ;

select
	*
from
	(
	select
		*
	from
		customers
	where
		tenant_id = 'c88b49e16697a03cf8cf084e050ed388'
		and phone = 'f656959694007529d888abf3664ba229'
		and name = '0045adcbdcb4cd5dccc1c3a6acc2d028'
) as c
join orders o on
	o.customer_id = c.id;

explain (analyze on
,
buffers on
,
timing on
)
select
	distinct(customer_id)
from
	(
	select
		customer_id
	from
		orders
	order by
		customer_id desc) as x ;

explain analyze
select
	distinct(customer_id)
from
	orders o ;

analyze verbose customers;

show work_mem;

show shared_buffers;

select
	round(mem.total / (1024 * 1024)) as total_memory_mb
from
	(
	select
		sum(setting::bigint) as total
	from
		pg_settings
	where
		name = 'max_process_memory') as mem;

select
	pg_size_pretty(used * block_size) as used_buffers,
	pg_size_pretty(free * block_size) as free_buffers,
	pg_size_pretty(total_buffers) as total_buffers
from
	(
	select
		pg_stat_get_buf_used() as used,
		pg_stat_get_buf_free() as free,
		pg_stat_get_buf_alloc() as total_buffers,
		current_setting('block_size')::bigint as block_size) as buffers;

create extension pg_buffercache;

select
	shared_buffers - pg_relation_size('pg_buffercache') as free_shared_buffers;

select
	(pg_size_pretty(pg_stat_get_db_blocks_hit(oid)) || '/' || pg_size_pretty(current_setting('shared_buffers'))) as shared_buffers_usage
from
	pg_database
where
	datname = current_database();

select
	n.nspname,
	c.relname,
	count(*) as buffers
from
	pg_buffercache b
join pg_class c
             on
	b.relfilenode = pg_relation_filenode(c.oid)
	and
                b.reldatabase in (0, (
	select
		oid
	from
		pg_database
	where
		datname = current_database()))
join pg_namespace n on
	n.oid = c.relnamespace
group by
	n.nspname,
	c.relname
order by
	3 desc;

select
	unit,
	max_val
from
	pg_settings
where
	name = 'work_mem';

--A tuple ID is a pair (block number, tuple index within block) that identifies the physical location of the row within its table.
SELECT ctid, * FROM t_test tt ;
SELECT (ctid::text::point)[0]::bigint AS block_number
     , (ctid::text::point)[1]::bigint AS tuple_index
     , *
FROM   t_test tt ;

SELECT json_build_object('name', 'John', 'age', 30) AS person;
SELECT json_agg(
    json_build_object('column1', column1, 'column2', column2, 'column3', column3)
) 
FROM (VALUES (1, 2, 3), (4, 5, 6)) AS x;

CREATE TABLE json_table (
    id SERIAL PRIMARY KEY,
    data JSONB
);

-- Insert a JSON document with nested fields into the table
INSERT INTO json_table (data) VALUES ('{
    "name": "John",
    "age": 30,
    "address": {
        "street": "123 Main St",
        "city": "New York",
        "country": "USA"
    }
}');

select data->'name'->'hello' from json_table;
select data->>'address'->'street' from json_table;
select data->>'address'->'street' from json_table;
INSERT INTO json_table (data) VALUES ('{"name": "John", "age": 30, "city": "New York", "hobbies": ["reading", "painting", "gardening"]}');

select pg_typeof(data -> 'name') FROM json_table;

SELECT (jsonb_each(data -> 'address')).* FROM json_table;

select * from pg_catalog.pg_stat_database;
select * from pg_catalog.pg_stat_activity;

/**
 * Sweet spot here are values close to 100 – it means that the almost all necessary data were read from shared buffers. Values near 90 show that postgres read from disk time to time. And values below 80 show that we have insufficient amount of shared buffers or physical RAM . Data required for top-called queries don’t fit into memory, and postgres has to read it from disk. It’s quite good if this data in the OS page cache, if they aren’t there it’s a bad scenario. The basic idea here is increased amount of shared buffers – good starting point for this is 25% of the available RAM. When all databases are able to fit in RAM, the good starting point is to allocate 80% of all available RAM.
    Note, when postgres is restarted and actively fills buffer cache, it shows low cache hit ratio and this is normal behaviour.
 */
-- cache hit ration for each table
SELECT
  datname, 100 * blks_hit / (blks_hit + blks_read) as cache_hit_ratio
FROM pg_stat_database WHERE (blks_hit + blks_read) > 0;

-- cache hit ration for all tables
SELECT 
  round(100 * sum(blks_hit) / sum(blks_hit + blks_read), 3) as cache_hit_ratio
FROM pg_stat_database;

-- which table may need index
SELECT schemaname, relname, seq_scan, seq_tup_read,
       seq_tup_read / seq_scan AS avg, idx_scan
FROM pg_stat_user_tables
WHERE seq_scan > 0
ORDER BY seq_tup_read DESC LIMIT 25;

select * from pg_statio_user_tables;

-- how often the index is used
SELECT schemaname, relname, indexrelname, idx_scan,
       pg_size_pretty(pg_relation_size(indexrelid))
AS idx_size,
       pg_size_pretty(sum(pg_relation_size(indexrelid))
               OVER (ORDER BY idx_scan, indexrelid))
AS total
FROM   pg_stat_user_indexes
ORDER BY 6;

select * from pg_stat_statements;

SELECT
  pg_stat_statements.query,
  pg_stat_all_indexes.relname AS index_name,
  pg_stat_statements.calls
 -- pg_stat_statements.total_time
FROM
  pg_stat_statements
JOIN
  pg_stat_all_indexes
  ON pg_stat_statements.query = pg_stat_all_indexes.indexrelname;

WITH table_scans as (
    SELECT relid,
        tables.idx_scan + tables.seq_scan as all_scans,
        ( tables.n_tup_ins + tables.n_tup_upd + tables.n_tup_del ) as writes,
                pg_relation_size(relid) as table_size
        FROM pg_stat_user_tables as tables
),
all_writes as (
    SELECT sum(writes) as total_writes
    FROM table_scans
),
indexes as (
    SELECT idx_stat.relid, idx_stat.indexrelid,
        idx_stat.schemaname, idx_stat.relname as tablename,
        idx_stat.indexrelname as indexname,
        idx_stat.idx_scan,
        pg_relation_size(idx_stat.indexrelid) as index_bytes,
        indexdef ~* 'USING btree' AS idx_is_btree
    FROM pg_stat_user_indexes as idx_stat
        JOIN pg_index
            USING (indexrelid)
        JOIN pg_indexes as indexes
            ON idx_stat.schemaname = indexes.schemaname
                AND idx_stat.relname = indexes.tablename
                AND idx_stat.indexrelname = indexes.indexname
    WHERE pg_index.indisunique = FALSE
),
index_ratios AS (
SELECT schemaname, tablename, indexname,
    idx_scan, all_scans,
    round(( CASE WHEN all_scans = 0 THEN 0.0::NUMERIC
        ELSE idx_scan::NUMERIC/all_scans * 100 END),2) as index_scan_pct,
    writes,
    round((CASE WHEN writes = 0 THEN idx_scan::NUMERIC ELSE idx_scan::NUMERIC/writes END),2)
        as scans_per_write,
    pg_size_pretty(index_bytes) as index_size,
    pg_size_pretty(table_size) as table_size,
    idx_is_btree, index_bytes
    FROM indexes
    JOIN table_scans
    USING (relid)
),
index_groups AS (
SELECT 'Never Used Indexes' as reason, *, 1 as grp
FROM index_ratios
WHERE
    idx_scan = 0
    and idx_is_btree
UNION ALL
SELECT 'Low Scans, High Writes' as reason, *, 2 as grp
FROM index_ratios
WHERE
    scans_per_write <= 1
    and index_scan_pct < 10
    and idx_scan > 0
    and writes > 100
    and idx_is_btree
UNION ALL
SELECT 'Seldom Used Large Indexes' as reason, *, 3 as grp
FROM index_ratios
WHERE
    index_scan_pct < 5
    and scans_per_write > 1
    and idx_scan > 0
    and idx_is_btree
    and index_bytes > 100000000
UNION ALL
SELECT 'High-Write Large Non-Btree' as reason, index_ratios.*, 4 as grp 
FROM index_ratios, all_writes
WHERE
    ( writes::NUMERIC / ( total_writes + 1 ) ) > 0.02
    AND NOT idx_is_btree
    AND index_bytes > 100000000
ORDER BY grp, index_bytes DESC )
SELECT reason, schemaname, tablename, indexname,
    index_scan_pct, scans_per_write, index_size, table_size
FROM index_groups;

-- find missing indexes
SELECT
  relname                                               AS TableName,
  to_char(seq_scan, '999,999,999,999')                  AS TotalSeqScan,
  to_char(idx_scan, '999,999,999,999')                  AS TotalIndexScan,
  to_char(n_live_tup, '999,999,999,999')                AS TableRows,
  pg_size_pretty(pg_relation_size(relname :: regclass)) AS TableSize
FROM pg_stat_all_tables
WHERE schemaname = 'public'
      AND 50 * seq_scan > idx_scan -- more than 2%
      AND n_live_tup > 10000
      AND pg_relation_size(relname :: regclass) > 5000000
ORDER BY relname ASC;


-- when too_much_seq is positive and large you should be concerned.
select
	relname,
	seq_scan-idx_scan as too_much_seq,
	case
		when seq_scan-idx_scan>0 then 'Missing Index?'
		else 'OK'
	end,
	pg_relation_size(relid::regclass) as rel_size,
	seq_scan,
	idx_scan
from
	pg_stat_all_tables
where
	schemaname = 'public'
	and pg_relation_size(relid::regclass)>80000
order by
	too_much_seq desc;
	
show max_connections;
-- https://pgtune.leopard.in.ua/

SELECT
    t.schemaname,
    t.tablename,
    c.reltuples::bigint                            AS num_rows,
    pg_size_pretty(pg_relation_size(c.oid))        AS table_size,
    psai.indexrelname                              AS index_name,
    pg_size_pretty(pg_relation_size(i.indexrelid)) AS index_size,
    CASE WHEN i.indisunique THEN 'Y' ELSE 'N' END  AS "unique",
    psai.idx_scan                                  AS number_of_scans,
    psai.idx_tup_read                              AS tuples_read,
    psai.idx_tup_fetch                             AS tuples_fetched
FROM
    pg_tables t
    LEFT JOIN pg_class c ON t.tablename = c.relname
    LEFT JOIN pg_index i ON c.oid = i.indrelid
    LEFT JOIN pg_stat_all_indexes psai ON i.indexrelid = psai.indexrelid
WHERE
    t.schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY 1, 2;

SELECT psut.relname,
     to_char(psut.last_vacuum, 'YYYY-MM-DD HH24:MI') as last_vacuum,
     to_char(psut.last_autovacuum, 'YYYY-MM-DD HH24:MI') as last_autovacuum,
     to_char(pg_class.reltuples, '9G999G999G999') AS n_tup,
     to_char(psut.n_dead_tup, '9G999G999G999') AS dead_tup,
     to_char(CAST(current_setting('autovacuum_vacuum_threshold') AS bigint)
         + (CAST(current_setting('autovacuum_vacuum_scale_factor') AS numeric)
            * pg_class.reltuples), '9G999G999G999') AS av_threshold,
     CASE
         WHEN CAST(current_setting('autovacuum_vacuum_threshold') AS bigint)
             + (CAST(current_setting('autovacuum_vacuum_scale_factor') AS numeric)
                * pg_class.reltuples) < psut.n_dead_tup
         THEN '*'
         ELSE ''
     END AS expect_av
 FROM pg_stat_user_tables psut
     JOIN pg_class on psut.relid = pg_class.oid
 ORDER BY 1;
 
SELECT r.rolname, r.rolsuper, r.rolinherit,
  r.rolcreaterole, r.rolcreatedb, r.rolcanlogin,
  r.rolconnlimit, r.rolvaliduntil,
  ARRAY(SELECT b.rolname
        FROM pg_catalog.pg_auth_members m
        JOIN pg_catalog.pg_roles b ON (m.roleid = b.oid)
        WHERE m.member = r.oid) as memberof
, r.rolreplication
, r.rolbypassrls
FROM pg_catalog.pg_roles r
WHERE r.rolname !~ '^pg_'
ORDER BY 1;

select round((100 * total_exec_time /
sum(total_exec_time)
                OVER ())::numeric, 2) percent,
        round(total_exec_time::numeric, 2) AS total,
        calls,
        round(mean_exec_time::numeric, 2) AS mean,
        substring(query, 1, 40)
FROM    pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;

SHOW shared_preload_libraries;

SELECT
  (total_exec_time / 1000 ) as total_seconds,
  mean_exec_time as avg_ms,
  calls,
  query
FROM pg_stat_statements
ORDER BY 1 DESC
LIMIT 500;

SELECT
  ps.query AS query_text,
  pi.relname AS index_name,
  pi.indexrelname AS index_relation,
  pi.schemaname AS schema_name
FROM
  pg_stat_statements ps
JOIN
  pg_stat_all_indexes pi
  ON ps.queryid = pi.relid
ORDER BY
  ps.queryid;
 SELECT pg_total_relation_size('a') / 1024 /1024/1024;

 -- get locks
SELECT locktype, relation::regclass, mode FROM pg_locks WHERE relation = 'a'::regclass;

SELECT
    pg_stat_activity.query,
    pg_locks.mode,
    pg_locks.granted,
    locktype, relation::regclass
FROM
    pg_locks
JOIN
    pg_stat_activity ON pg_locks.pid = pg_stat_activity.pid
WHERE
    pg_locks.relation = 'a'::regclass;
select  * from pg_catalog.pg_stat_progress_analyze ;
