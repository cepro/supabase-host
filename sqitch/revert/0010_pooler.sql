-- Revert supabase_setup:pooler from pg

BEGIN;

DO $$ BEGIN RAISE EXCEPTION 'Revert not supported for migration'; END $$;

COMMIT;
