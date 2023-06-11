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
