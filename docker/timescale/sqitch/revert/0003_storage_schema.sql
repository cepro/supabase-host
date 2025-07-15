-- Revert supabase_setup:0003_storage_schema from pg

BEGIN;

RAISE EXCEPTION 'Revert not supported for migration';

COMMIT;
