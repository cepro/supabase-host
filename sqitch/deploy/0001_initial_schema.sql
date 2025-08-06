-- Deploy supabase_setup:init_0_initial_schema to pg
-- 
-- This migration creates the core Supabase schema and roles for use with external PostgreSQL
-- (specifically TimescaleDB). Several modifications have been made from the standard Supabase
-- setup to work within the constraints of managed PostgreSQL services:
--
-- MODIFICATIONS FOR TIMESCALEDB/MANAGED POSTGRESQL:
-- 1. Removed REPLICATION privileges - not available to non-superusers in managed services
-- 2. Removed BYPASSRLS privileges - not grantable by tsdbadmin user 
-- 3. Replaced pg_read_all_data with dynamic schema grants - not grantable in managed services
-- 4. Excluded 'postgres' role from grants - conflicts with TimescaleDB's tsdbexplorer role
-- 5. Filtered out TimescaleDB internal schemas from read-only user grants

BEGIN;

-- Set up realtime
-- defaults to empty publication
create publication supabase_realtime;

-- Supabase super admin
alter user supabase_admin with createrole; -- replication bypassrls

-- Supabase replication user
-- create user supabase_replication_admin with login replication;

-- Supabase read-only user
create role supabase_read_only_user with login; -- bypassrls;
-- grant pg_read_all_data to supabase_read_only_user; -- Not available in managed TimescaleDB

-- Grant access to all existing schemas and their objects
DO $$
DECLARE
    schema_name text;
BEGIN
    -- Loop through all schemas except system ones
    FOR schema_name IN 
        SELECT nspname 
        FROM pg_namespace 
        WHERE nspname NOT LIKE 'pg_%' 
        AND nspname NOT IN ('information_schema', '_timescaledb_internal', '_timescaledb_cache', '_timescaledb_catalog', '_timescaledb_config')
    LOOP
        -- Grant usage on schema
        EXECUTE format('GRANT USAGE ON SCHEMA %I TO supabase_read_only_user', schema_name);
        -- Grant select on all tables in schema
        EXECUTE format('GRANT SELECT ON ALL TABLES IN SCHEMA %I TO supabase_read_only_user', schema_name);
        -- Grant usage on all sequences in schema
        EXECUTE format('GRANT USAGE ON ALL SEQUENCES IN SCHEMA %I TO supabase_read_only_user', schema_name);
        -- Set default privileges for future objects in this schema
        EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT SELECT ON TABLES TO supabase_read_only_user', schema_name);
        EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT USAGE ON SEQUENCES TO supabase_read_only_user', schema_name);
    END LOOP;
END $$;

-- Extension namespacing
create schema if not exists extensions;
create extension if not exists "uuid-ossp"      with schema extensions;
create extension if not exists pgcrypto         with schema extensions;


-- Set up auth roles for the developer
create role anon                nologin noinherit;
create role authenticated       nologin noinherit; -- "logged in" user: web_user, app_user, etc
create role service_role        nologin noinherit; -- allow developers to create JWT's that bypass their policies bypassrls

create user authenticator noinherit;
grant anon              to authenticator;
grant authenticated     to authenticator;
grant service_role      to authenticator;
grant supabase_admin    to authenticator;

grant anon              to tsdbadmin;
grant authenticated     to tsdbadmin;
grant service_role      to tsdbadmin;

grant usage                     on schema public to anon, authenticated, service_role;
alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;

-- Allow Extensions to be used in the API
grant usage                     on schema extensions to anon, authenticated, service_role;

-- Set up namespacing
alter user supabase_admin SET search_path TO public, extensions; -- don't include the "auth" schema

-- These are required so that the users receive grants whenever "supabase_admin" creates tables/function
alter default privileges for user supabase_admin in schema public grant all
    on sequences to anon, authenticated, service_role;
alter default privileges for user supabase_admin in schema public grant all
    on tables to anon, authenticated, service_role;
alter default privileges for user supabase_admin in schema public grant all
    on functions to anon, authenticated, service_role;

-- Set short statement/query timeouts for API roles
alter role anon set statement_timeout = '3s';
alter role authenticated set statement_timeout = '8s';

-- migrate:down

COMMIT;
