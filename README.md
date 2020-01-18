# golang-migrate consistency test

When the `migrate` command from [golang-migrate](https://github.com/golang-migrate/migrate) is killed while a migration is running and the migration succeeds asynchronously inside Postgres, the DB is left marked dirty when in reality it's clean. This is inconsistent, and causes confusion.

This situation realistically occurs when a migration takes longer to run than the app is given to initialize by the supervisor (e.g. Kubernetes) and the supervisor restarts the app.

This repository demonstrates this inconsistency.

Usage:

```
$ bash test.sh
INCONSISTENT: DB is marked dirty, but migration succeeded
```

Then comment out the existing SQL in [`migrations/000001_one.up.sql`](migrations/000001_one.up.sql), uncomment the solution, and re-run `test.sh`:

```
$ bash test.sh
OK: DB is marked clean and migration succeeded
```
