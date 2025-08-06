-- Revert supabase_setup:002_auth_schema from pg

BEGIN;

RAISE EXCEPTION 'Revert not supported for migration';

-- DROP ROLE supabase_auth_admin;
-- DROP SCHEMA auth CASCADE;

COMMIT;
