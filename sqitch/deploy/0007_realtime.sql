-- Deploy supabase_setup:realtime to pg

BEGIN;


create schema if not exists _realtime;
alter schema _realtime owner to supabase_admin;

COMMIT;
