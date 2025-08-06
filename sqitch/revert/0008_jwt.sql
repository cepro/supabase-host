-- Revert supabase_setup:jwt from pg

BEGIN;

RAISE EXCEPTION 'Revert not supported for migration';

COMMIT;
