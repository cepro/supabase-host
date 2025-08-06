-- Revert supabase_setup:0004_post_setup from pg

BEGIN;

RAISE EXCEPTION 'Revert not supported for migration';

COMMIT;
