-- Deploy supabase_setup:0011_auth_postgraphile_support to pg

BEGIN;

CREATE OR REPLACE FUNCTION auth.jwt()
 RETURNS jsonb
 LANGUAGE sql
 STABLE
AS $function$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$function$
;

ALTER FUNCTION auth.jwt() OWNER TO supabase_auth_admin;


-- 
-- Simtricity adds that handle session info from either Supabase (REST) or 
-- Postgraphile (graphql). Simtricity functions should use these functions
-- to ensure both work. eg. an RLS policy needs to handle incoming requests
-- from Supabase AND Postgraphile. 
--

CREATE OR REPLACE FUNCTION auth.session_email()
RETURNS text
LANGUAGE sql
STABLE
AS $function$
    select
    coalesce(
        auth.email(),
        nullif(current_setting('jwt.claims.email', true), '')::text,
        (nullif(current_setting('jwt.claims', true), '')::jsonb ->> 'email')::text
    )
$function$
;
COMMENT ON FUNCTION auth."session_email"() IS 'Use this to handle claims from both Supabase and Postgraphile.';

ALTER FUNCTION auth."session_email"() OWNER TO supabase_auth_admin;
GRANT ALL ON FUNCTION auth."session_email"() TO supabase_auth_admin;


CREATE OR REPLACE FUNCTION auth.session_role()
RETURNS text
LANGUAGE sql
STABLE
AS $function$
    select
    coalesce(
        auth.role(),
        nullif(current_setting('jwt.claims.role', true), '')::text,
        (nullif(current_setting('jwt.claims', true), '')::jsonb ->> 'role')::text
    )
$function$
;
COMMENT ON FUNCTION auth."session_role"() IS 'Use this to handle claims from both Supabase and Postgraphile.';

ALTER FUNCTION auth."session_role"() OWNER TO supabase_auth_admin;
GRANT ALL ON FUNCTION auth."session_role"() TO supabase_auth_admin;

CREATE OR REPLACE FUNCTION auth.session_jwt()
RETURNS jsonb
LANGUAGE sql
STABLE
AS $function$
    select
    coalesce(
        auth.jwt(),
      	nullif(current_setting('jwt.claims', true), '')::jsonb
    )::jsonb
$function$
;
COMMENT ON FUNCTION auth."session_jwt"() IS 'Use this to handle claims from both Supabase and Postgraphile.';

ALTER FUNCTION auth."session_jwt"() OWNER TO supabase_auth_admin;
GRANT ALL ON FUNCTION auth."session_jwt"() TO supabase_auth_admin;

COMMIT;
