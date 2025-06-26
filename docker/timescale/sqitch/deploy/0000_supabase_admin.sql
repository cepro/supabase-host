-- Deploy supabase_setup:supabase to pg

BEGIN;

-- The rest of the migrations assume that we already have a `supabase_admin` role - so create one here

-- Create user with specific privileges
CREATE USER supabase_admin WITH 
  CREATEROLE 
  LOGIN 
  PASSWORD :'supabaseadminpass';

GRANT ALL PRIVILEGES ON DATABASE tsdb TO supabase_admin;

GRANT supabase_admin TO tsdbadmin;

COMMIT;
