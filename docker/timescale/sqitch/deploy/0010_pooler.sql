-- Deploy supabase_setup:pooler to pg

BEGIN;

create schema if not exists _supavisor;
alter schema _supavisor owner to :pguser;

COMMIT;
