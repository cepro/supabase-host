-- Deploy supabase_setup:0012_auth_permissions to pg

BEGIN;

GRANT USAGE ON SCHEMA auth TO grafanareader;

COMMIT;
