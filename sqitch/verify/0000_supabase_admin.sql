-- Verify supabase_setup:supabase on pg

BEGIN;

REVOKE ALL PRIVILEGES ON DATABASE tsdb FROM supabase_admin;
drop role supabase_admin;

ROLLBACK;
