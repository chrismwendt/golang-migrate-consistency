-- Give the test.sh script time to kill the migrate command in the middle of executing this query.
SELECT pg_sleep(1);
CREATE TABLE foo(foo TEXT);
INSERT INTO foo VALUES ('foo');

-- The following is a solution to the inconsistent DB state demonstrated by test.sh.
-- Logically, this solution sets dirty=true when the migration throws an exception and sets dirty=false when the migration succeeds.
-- The DO block exists only because you can't use EXCEPTION outside of plpgsql.
-- Try commenting out the above section and uncommenting this solution and you'll see that consistency is maintained.

-- DO $$
-- BEGIN
--   PERFORM pg_sleep(1);
--   CREATE TABLE foo(foo TEXT);
--   INSERT INTO foo VALUES ('foo');
--   UPDATE schema_migrations SET dirty = false;
-- EXCEPTION WHEN others THEN
--   RAISE INFO 'Error Name:%',SQLERRM;
--   UPDATE schema_migrations SET dirty = true;
--   INSERT INTO foo VALUES (SQLERRM);
-- END $$ LANGUAGE plpgsql;
