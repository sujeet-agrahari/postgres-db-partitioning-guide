## Shards

- Useful when there is lot of requests and the single server is not able to handle it (more writes)
- Routing queries to concerned shard is responsibility of the application code
- Loses the ability to use ACIDs
- High cost and maintenance
- Complex to implement

## Partitioning

- Useful when reads or slow or the table becomes too large
- Routing queries to concerned partition is responsibility of database which uses index on partition keys
- We can still use ACIDs
- Low cost and maintenance
- Less complex to implement
