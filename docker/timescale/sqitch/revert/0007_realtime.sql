-- Revert supabase_setup:realtime from pg

BEGIN;

RAISE EXCEPTION 'Revert not supported for migration';

COMMIT;
