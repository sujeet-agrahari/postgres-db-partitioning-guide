```sql
create table traffic_violations_p_list
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
partition by list (violation_type);

create table traffic_violations_p_list_warning
partition of traffic_violations_p_list
for values in ('Warning');

create table traffic_violations_p_list_sero
partition of traffic_violations_p_list
for values in ('SERO');

create table traffic_violations_p_list_Citation
partition of traffic_violations_p_list
for values in ('Citation');

create table traffic_violations_p_list_ESERO
partition of traffic_violations_p_list
for values in ('ESERO');

create table traffic_violations_p_list_default
    partition of traffic_violations_p_list DEFAULT;

insert into traffic_violations_p_list select * from mv_traffic_violations;

```
