-- Deploy supabase_setup:roles to pg

BEGIN;

ALTER USER authenticator WITH PASSWORD :'authenticator_password';
ALTER USER supabase_auth_admin WITH PASSWORD :'supabase_auth_admin_password';
-- ALTER USER pgbouncer WITH PASSWORD :'pgpass';  drop this because Timescale cloud already has a session pooler
-- ALTER USER supabase_functions_admin WITH PASSWORD :'pgpass';
-- ALTER USER supabase_storage_admin WITH PASSWORD :'pgpass'; Storage functionality is not currently used so this has been disabled

COMMIT;
