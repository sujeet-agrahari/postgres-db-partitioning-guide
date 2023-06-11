```sql
-- Hash paritioning is great when you have many different values
-- A good candidate would be the seqid column
-- When choosing a column as a partition key, selecting one with high cardinality is important to ensure a balanced distribution of data across partitions
-- high cardinality" in the context of database partitioning refers to having a column with a large number of distinct values.
( seqid text
, date_of_stop date
, time_of_stop time
, agency text
, subagency text
, description text
, location text
, latitude numeric
, longitude numeric
, accident text
, belts boolean
, personal_injury boolean
, property_damage boolean
, fatal boolean
, commercial_license boolean
, hazmat boolean
, commercial_vehicle boolean
, alcohol boolean
, workzone boolean
, state text
, vehicletype text
, year smallint
, make text
, model text
, color text
, violation_type text
, charge text
, article text
, contributed_to_accident boolean
, race text
, gender text
, driver_city text
, driver_state text
, dl_state text
, arrest_type text
, geolocation point
)
partition by hash (seqid);

create table traffic_violations_p_hash_p1
partition of traffic_violations_p_hash
for values with (modulus 5, remainder 0);

create table traffic_violations_p_hash_p2
partition of traffic_violations_p_hash
for values with (modulus 5, remainder 1);

create table traffic_violations_p_hash_p3
partition of traffic_violations_p_hash
for values with (modulus 5, remainder 2);

create table traffic_violations_p_hash_p4
partition of traffic_violations_p_hash
for values with (modulus 5, remainder 3);

create table traffic_violations_p_hash_p5
partition of traffic_violations_p_hash
for values with (modulus 5, remainder 4);

insert into traffic_violations_p_hash select * from mv_traffic_violations;
```

**Hash partitioning can not have a default partition as that would not make any sense because of the modulus and the remainder. When you try to do that you will get an error:**

```sql
create table traffic_violations_p_hash_default
partition of traffic_violations_p_hash default;

-- psql: ERROR:  a hash-partitioned table may not have a default partition
```
