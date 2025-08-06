fly --config fly-auth.toml secrets set GOTRUE_DB_DATABASE_URL=""
fly --config fly-auth.toml secrets set GOTRUE_JWT_SECRET=""
fly --config fly-auth.toml secrets set GOTRUE_SMTP_PASSWORD=""
