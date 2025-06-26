-- Revert supabase_setup:002_auth_schema from pg

BEGIN;

RAISE EXCEPTION 'Revert not supported for migration';

COMMIT;
