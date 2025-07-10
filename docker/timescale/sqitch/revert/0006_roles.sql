-- Revert supabase_setup:roles from pg

BEGIN;

RAISE EXCEPTION 'Revert not supported for migration';

COMMIT;
