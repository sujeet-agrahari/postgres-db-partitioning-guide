Three main configuration files control operations of a PostgreSQL server:

## postgresql.conf

Controls general settings, such as memory allocation, default storage location
for new databases, the IP addresses that PostgreSQL listens on,
location of logs, and plenty more.

## pg_hba.conf

Controls access to the server, dictating which users can log in to which
databases, which IP addresses can connect, and which authentication
scheme to accept.

## pg_ident.conf

If present, this file maps an authenticated OS login to a PostgreSQL user. People
sometimes map the OS root account to the PostgresSQL superuser account,
postgres.

## Location of config file

```sql
SELECT name, setting FROM pg_settings WHERE category = 'File Locations';
```

## Reload or Restart after changing a configuration?

```sql
SELECT name, context
FROM pg_settings
WHERE name = 'max_connections';
```

The result of this query will provide the name of the configuration parameter and its associated context setting. The context can be one of the following values:

**user**: The configuration parameter can be modified at the user session level, and a **reload** of the PostgreSQL server is sufficient to apply the change.

**superuser**: Only superusers (database administrators) can modify the configuration parameter. A **reload** is required for the changes to take effect.

**postmaster**: The configuration parameter can only be modified by **restarting** the PostgreSQL server (postmaster process).

# postgresql.conf file

instead of editing postgresql.conf directly, you should override settings using an additional file called postgresql.auto.conf.

We further recommend that you don’t touch the postgresql.conf and place any custom settings in postgresql.auto.conf.

Checking postgresql.conf settings:
2865101894
Draft_GJ004S/2023/3417597

```sql
SELECT
    name,
    context ,
    unit ,
    setting, boot_val, reset_val
FROM pg_settings
WHERE name IN ('listen_addresses','deadlock_timeout','shared_buffers',
    'effective_cache_size','work_mem','maintenance_work_mem')
ORDER BY context, name;
```

The context is the scope of the setting. Some settings have
a wider effect than others, depending on their context.User settings can be changed by each user to affect just
that user’s sessions. If set by the superuser, the setting becomes
a default for all users who connect after a reload.Superuser settings can be changed only by a superuser, and
will apply to all users who connect after a reload. Users cannot
individually override the setting.Postmaster settings affect the entire server (postmaster
represents the PostgreSQL service) and take effect only after a
restart.
docker run -ti -e DATABASE_URL=postgres://postgres:password@localhost:5432/dbname -p 8080:8080 ankane/pghero

docker run -ti -e DATABASE_URL=postgres://postgres:password@127.0.0.1:5432/postgres -p 8080:8080 bmorton/pghero