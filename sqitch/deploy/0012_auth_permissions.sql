-- Deploy supabase_setup:0012_auth_permissions to pg

BEGIN;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'grafanareader') THEN
    CREATE ROLE grafanareader;
  END IF;
END $$;
GRANT USAGE ON SCHEMA auth TO grafanareader;

COMMIT;
