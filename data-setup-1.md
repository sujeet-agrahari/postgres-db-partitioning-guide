### 1. Create Table

[Download Data](https://drive.google.com/file/d/1f08XdMccBCczBrCBMNPnJnpmpA8hPxyE/view?usp=sharing)

```sql
create table traffic_violations
( seqid text
, date_of_stop text
, time_of_stop text
, agency text
, subagency text
, description text
, location text
, latitude text
, longitude text
, accident text
, belts text
, personal_injury text
, property_damage text
, fatal text
, commercial_license text
, hazmat text
, commercial_vehicle text
, alcohol text
, workzone text
, search_conducted text
, search_disposition text
, search_outcome text
, search_reason text
, search_reason_for_stop text
, search_type text
, search_arrest_reason text
, state text
, vehicletype text
, year text
, make text
, model text
, color text
, violation_type text
, charge text
, article text
, contributed_to_accident text
, race text
);
```

### 3. Import the data.csv to the table using any tool (dbeaver)

### 4. Create a materialized view and enforce datatype on the columns

[Materiliazed Veiw](https://www.postgresql.org/docs/current/rules-materializedviews.html)

A materialized view is a database object that stores the result of a query as a snapshot of data, which can be updated periodically or on-demand. Materialized views are useful in situations where you have complex or time-consuming queries that are executed frequently, and the underlying data doesn't change very often. By storing the query result in a materialized view, you can significantly improve query performance, as the database can return the precomputed result from the materialized view instead of executing the query each time.

Materialized views differ from normal views in the following ways:

- Data storage: A normal view is a virtual table that doesn't store any data. Instead, it stores the definition of a query, and the query is executed each time the view is accessed. In contrast, a materialized view stores the actual result of the query as a snapshot of data, which can be updated periodically or on-demand.
- Query performance: Since normal views don't store any data and execute the query each time they are accessed, their performance depends on the complexity of the underlying query. Materialized views, on the other hand, can significantly improve query performance, as the database can return the precomputed result from the materialized view instead of executing the query.
- Data freshness: Normal views always return the most up-to-date data, as they execute the query each time they are accessed. Materialized views, however, return the data from the last snapshot, which may not be the most recent data. To maintain data freshness, materialized views need to be updated periodically or on-demand.

```sql
create materialized view mv_traffic_violations
( seqid
, date_of_stop
, time_of_stop
, agency
, subagency
, description
, location
, latitude
, longitude
, accident
, belts
, personal_injury
, property_damage
, fatal
, commercial_license
, hazmat
, commercial_vehicle
, alcohol
, workzone
, state
, vehicletype
, year
, make
, model
, color
, violation_type
, charge
, article
, contributed_to_accident
, race
, gender
, driver_city
, driver_state
, dl_state
, arrest_type
, geolocation
)
as
select seqid
     , to_date(date_of_stop,'MM/DD/YYYY')
     , time_of_stop::time
     , agency
     , subagency
     , description
     , location
     , latitude::numeric
     , longitude::numeric
     , accident
     , belts::boolean
     , personal_injury::boolean
     , property_damage::boolean
     , fatal::boolean
     , commercial_license::boolean
     , hazmat::boolean
     , commercial_vehicle::boolean
     , alcohol::boolean
     , workzone::boolean
     , state
     , vehicletype
     , case year
         when '' then null
         else year::smallint
       end
     , make
     , model
     , color
     , violation_type
     , charge
     , article
     , contributed_to_accident::boolean
     , race
     , gender
     , driver_city
     , driver_state
     , dl_state
     , arrest_type
     , geolocation::point
  from traffic_violations;


insert into traffic_violations_p (date_of_Stop) values ( now() );
```

The beauty of a materialized view is, that you can refresh whenever the underlying data set changed, e.g.:

```sql
refresh materialized view mv_traffic_violations WITH data;
```

**Index/constraint added on parent(partitioned) table will be cascaded to child(partitions) automatically**
