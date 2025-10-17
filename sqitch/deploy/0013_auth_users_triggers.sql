-- Deploy supabase_setup:0013_auth_users_triggers to pg

BEGIN;

create trigger update_customers_on_email_update_trigger after
update
    of email on
    auth.users for each row execute function myenergy.customer_email_update_for_trigger();

create trigger customer_registration_trigger before
insert
    on
    auth.users for each row execute function myenergy.customer_registration();

create trigger customer_status_auth_users_update after
update
    on
    auth.users for each row execute function myenergy.customer_status_update_on_auth_users_trigger();

COMMIT;
