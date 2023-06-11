<i>"Partitioning is a technique used in database management systems to divide a large table into smaller, more manageable pieces called partitions. Each partition is a separate, self-contained unit that stores a subset of the table's data, based on a specified partitioning key. Partitioning can improve query performance, simplify data management, and enable parallel processing."</i>

There are several partitioning strategies, each with its own advantages and use cases:
[Documentation](https://www.postgresql.org/docs/12/ddl-partitioning.html)

### Range partitioning:

In range partitioning, data is partitioned based on a range of values for the partitioning key. Each partition stores data with partition key values that fall within a specific range. This strategy is useful when dealing with continuous data, such as dates or timestamps, where queries often involve a range of values.

Example: A table storing sales data can be partitioned by date, with each partition containing data for a specific month or year.

### List partitioning:

In list partitioning, data is partitioned based on a list of discrete values for the partitioning key. Each partition stores data with partition key values that match one of the specified values in the list. This strategy is useful when dealing with categorical data, where queries often involve specific values.

Example: A table storing customer data can be partitioned by country, with each partition containing data for a specific country.

### Hash partitioning:

In hash partitioning, data is partitioned based on a hash function applied to the partitioning key. The hash function generates a consistent output for each input value, ensuring that data is evenly distributed across the partitions. This strategy is useful when there is no clear range or list of values for the partitioning key, and the goal is to balance the data evenly across partitions.

Example: A table storing user data can be partitioned using a hash function applied to the user ID, ensuring an even distribution of data across partitions.

### Composite partitioning:

Composite partitioning combines two or more partitioning strategies, allowing for more complex partitioning schemes. For example, a table can be range-partitioned by date and then further subpartitioned using a hash function on another column. This strategy is useful when multiple partitioning keys are relevant to the data and query patterns.

Example: A table storing sales data can be range-partitioned by date and then further hash-partitioned by product ID.

---

- _When you attempt to insert a row into a range partition that is outside the defined range and you don't have a default partition specified, the insertion will fail with an error. The specific error message you will receive is:_

```
ERROR: no partition of relation "table_name" found for row
SQL state: 23514
```

- Index/constraint added on parent(partitioned) table will be cascaded to child(partitions) automatically

### Partition Pruning

Suppose we have a large transaction table named transactions that is partitioned by date range. The table is divided into monthly partitions based on the transaction date, with each partition containing data for a specific month. The partitioning key is the transaction_date column.

Now, let's say we want to query the total sum of transactions for a specific date range, such as from January 1, 2023, to February 28, 2023.

Without partition pruning, the database would need to scan all partitions of the transactions table, including those outside the specified date range, to calculate the sum. This would result in unnecessary I/O and processing overhead.

However, with partition pruning, the database optimizer analyzes the query and recognizes that only the partitions covering the date range are relevant to the query. It can then eliminate the other partitions from the query execution plan.

In our example, partition pruning would allow the optimizer to access only the partitions corresponding to January and February 2023, ignoring the other partitions that fall outside the specified date range. This significantly reduces the amount of data that needs to be scanned and improves query performance.
