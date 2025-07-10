-- Revert supabase_setup:webhooks from pg

BEGIN;

RAISE EXCEPTION 'Revert not supported for migration';

COMMIT;
