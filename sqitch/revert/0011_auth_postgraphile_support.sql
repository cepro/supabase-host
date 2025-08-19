-- Revert supabase_setup:0011_auth_postgraphile_support from pg

BEGIN;

DROP FUNCTION auth.session_email();
DROP FUNCTION auth.session_role();
DROP FUNCTION auth.session_jwt();

COMMIT;
