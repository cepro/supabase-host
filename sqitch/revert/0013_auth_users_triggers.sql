-- Revert supabase_setup:0013_auth_users_triggers from pg

BEGIN;

drop trigger update_customers_on_email_update_trigger on auth.users;
drop trigger customer_registration_trigger on auth.users;
drop trigger customer_status_auth_users_update on auth.users;

COMMIT;
