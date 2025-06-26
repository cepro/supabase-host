-- Deploy supabase_setup:jwt to pg

BEGIN;

-- I don't *think* these are actually used anywhere as the postgrest service has these configured as env vars
-- ALTER DATABASE tsdb SET "app.settings.jwt_secret" TO :'jwt_secret';
-- ALTER DATABASE tsdb SET "app.settings.jwt_exp" TO :'jwt_exp';

COMMIT;
