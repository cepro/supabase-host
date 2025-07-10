-- Revert supabase_setup:pooler from pg

BEGIN;

RAISE EXCEPTION 'Revert not supported for migration';

COMMIT;
