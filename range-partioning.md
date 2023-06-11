```sql
create table traffic_violations_p
( seqid text
, date_of_stop date not null
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
, geolocation point)
partition by range (date_of_stop);

insert into traffic_violations_p (date_of_Stop) values ( now() );



create table traffic_violations_p_2012
partition of traffic_violations_p
for values from ('2012-01-01') to ('2012-12-31');

create table traffic_violations_p_2013
partition of traffic_violations_p
for values from ('2013-01-01') to ('2013-12-31');

create table traffic_violations_p_2014
partition of traffic_violations_p
for values from ('2014-01-01') to ('2014-12-31');

create table traffic_violations_p_2015
partition of traffic_violations_p
for values from ('2015-01-01') to ('2015-12-31');

create table traffic_violations_p_2016
partition of traffic_violations_p
for values from ('2016-01-01') to ('2016-12-31');

create table traffic_violations_p_2017
partition of traffic_violations_p
for values from ('2017-01-01') to ('2017-12-31');

create table traffic_violations_p_2018
partition of traffic_violations_p
for values from ('2018-01-01') to ('2018-12-31');

create table traffic_violations_p_2019
partition of traffic_violations_p
for values from ('2019-01-01') to ('2019-12-31');

create table traffic_violations_p_2020
partition of traffic_violations_p
for values from ('2020-01-01') to ('2020-12-31');

create table traffic_violations_p_default
partition of traffic_violations_p default;
```

As our partitioned table setup is now complete we can load the data:

```sql
insert into traffic_violations_p select * from mv_traffic_violations;
```
