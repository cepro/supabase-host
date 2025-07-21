-- Revert supabase_setup:init_0_initial_schema from pg

BEGIN;

RAISE EXCEPTION 'Revert not supported for migration';

COMMIT;
