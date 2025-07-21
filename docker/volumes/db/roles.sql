\set authenticator_password `echo "$AUTHENTICATOR_PASSWORD"`
\set supabase_auth_admin_password `echo "$SUPABASE_AUTH_ADMIN_PASSWORD"`

ALTER USER authenticator WITH PASSWORD :'authenticator_password';
ALTER USER supabase_auth_admin WITH PASSWORD :'supabase_auth_admin_password';
-- ALTER USER pgbouncer WITH PASSWORD :'pgpass';
-- ALTER USER supabase_functions_admin WITH PASSWORD :'pgpass';
-- ALTER USER supabase_storage_admin WITH PASSWORD :'pgpass';
