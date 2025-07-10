-- Revert supabase_setup:logs from pg

BEGIN;

RAISE EXCEPTION 'Revert not supported for migration';

COMMIT;
