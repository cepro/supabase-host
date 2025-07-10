-- Deploy supabase_setup:logs to pg

BEGIN;

create schema if not exists _analytics;
alter schema _analytics owner to supabase_admin;

COMMIT;
