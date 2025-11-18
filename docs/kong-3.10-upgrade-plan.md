# Kong Gateway 3.10 Upgrade Plan

**Document Version:** 1.0
**Date:** 2025-10-18
**Author:** Damon Rand / Simtricity
**Target Completion:** Q1 2025 (30 days)

---

## Executive Summary

This document outlines the plan to upgrade all Simtricity/Microgrid Foundry Kong Gateway instances from version 2.8.1 to 3.10.0.6 (LTS), maintaining the free/open-source licensing model while gaining security patches, performance improvements, and extended support through ~2027.

**Key Points:**
- **Cost:** $0 (remaining on free/OSS version)
- **Risk:** Low (tested upgrade path, backward-compatible configuration)
- **Timeline:** 30 days (phased rollout)
- **Architecture:** No changes (same DB-less, declarative config pattern)
- **Licensing:** Option to add Enterprise licenses per-instance later (see Appendix A)

---

## Table of Contents

1. [Current State](#current-state)
2. [Target State](#target-state)
3. [Why Upgrade Now](#why-upgrade-now)
4. [Breaking Changes & Compatibility](#breaking-changes--compatibility)
5. [Upgrade Path](#upgrade-path)
6. [Implementation Plan](#implementation-plan)
7. [Testing Strategy](#testing-strategy)
8. [Rollback Plan](#rollback-plan)
9. [Monitoring & Validation](#monitoring--validation)
10. [Success Criteria](#success-criteria)
11. [Appendix A: Enterprise Licensing Option](#appendix-a-enterprise-licensing-option)
12. [Appendix B: Research Summary](#appendix-b-research-summary)
13. [Appendix C: Resources](#appendix-c-resources)

---

## Current State

### Kong Gateway Deployment (As of 2025-10-18)

**Version:** Kong Gateway 2.8.1 (OSS)
**Image:** `public.ecr.aws/supabase/kong:2.8.1`
**Deployment Mode:** DB-less (declarative configuration)
**Config Format:** YAML (`_format_version: '2.1'`)

**Active Instances:**
- `supabase-kong-mgf` (Microgrid Foundry)
- `supabase-kong-bec` (Bridport Energy Community)

**Deployment Platform:**
- **Host:** Fly.io (London region - lhr)
- **Resources:** 512MB RAM, 1 shared CPU
- **Ports:** 8000 (HTTP), 8443 (HTTPS)

**Plugins in Use:**
```yaml
KONG_PLUGINS: request-transformer,cors,key-auth,acl,basic-auth
```

All five plugins are free/open-source and will remain compatible with Kong 3.10.

### Architecture Pattern

```
Internet → Kong Gateway (Fly.io)
            ↓
    ┌───────┴───────┬───────────────┬──────────────┐
    ↓               ↓               ↓              ↓
GoTrue Auth    PostgREST      pg-meta      Supabase Studio
(port 9999)   (port 3000)   (port 8080)    (port 3000)
```

**Configuration Management:**
- Declarative YAML config (`kong.yml`)
- Environment variable substitution for secrets
- Version-controlled in `supabase-host/fly/kong/`
- Immutable deployments (no runtime changes via Admin API)

**Current Limitations (Inherent to DB-less Mode):**
- Read-only Admin API (expected behavior)
- No cluster-mode rate limiting (not currently used)
- Must redeploy to change configuration (acceptable for CI/CD workflow)

---

## Target State

### Kong Gateway 3.10.0.6 (LTS)

**Version:** Kong Gateway 3.10.0.6 (Free/OSS)
**Image:** `kong/kong-gateway:3.10.0.6-debian`
**Deployment Mode:** DB-less (unchanged)
**Config Format:** YAML (`_format_version: '2.1'` - compatible)

**Why Debian variant:**
- Alpine support discontinued in Kong 3.4+
- Debian images are optimized, security-scanned, minimal dependencies
- Smallest non-Alpine option available

**Same Architecture, Same Configuration Pattern:**
- No changes to `kong.yml` structure
- Same plugin set (all remain free)
- Same Fly.io deployment model
- Same secrets management pattern

### What Changes

**Docker Image Only:**
```diff
# fly-kong-mgf.toml
[build]
- image = 'public.ecr.aws/supabase/kong:2.8.1'
+ image = 'kong/kong-gateway:3.10.0.6-debian'
```

**Everything Else Stays the Same:**
- ✅ Declarative configuration (`kong.yml`)
- ✅ Plugins (request-transformer, cors, key-auth, acl, basic-auth)
- ✅ Routes and services definitions
- ✅ Environment variable substitution
- ✅ Fly.io deployment configs
- ✅ Resource allocations (512MB RAM, 1 CPU)

---

## Why Upgrade Now

### 1. Security & Support

**Kong 2.8 LTS:**
- Released: 2022
- End of Life: ~2025-2027 (3-year LTS policy)
- Currently 3 major versions behind (2.8 → 3.x → 4.x coming)

**Kong 3.10 LTS:**
- Released: 2024
- End of Life: ~2027 (3-year LTS policy)
- Extended security patch window
- Active development and bug fixes

**Risk of Staying on 2.8.1:**
- Security vulnerabilities discovered in older versions
- Dependency CVEs (OpenResty, Nginx, Lua libraries)
- No upstream fixes for newly discovered issues

### 2. Performance Improvements

Kong 3.x series includes:
- **Faster plugin execution** - Optimized Lua VM
- **Better memory efficiency** - Reduced memory footprint in DB-less mode
- **HTTP/3 support** - QUIC protocol for faster TLS handshakes
- **Improved DNS caching** - Reduced latency for service discovery

**Impact for Simtricity:**
- Lower latency for API requests
- Better resource utilization (same 512MB RAM, more throughput)
- Future-proofing for HTTP/3 adoption

### 3. New Features (Free Tier)

**Kong Manager GUI:**
- Now included in free version (was Enterprise-only pre-3.0)
- Read-only in DB-less mode (useful for debugging)
- Visualize routes, services, plugins without parsing YAML

**WebAssembly Plugin Support:**
- Run plugins written in Rust, Go, AssemblyScript
- Better performance than Lua for CPU-intensive tasks
- Future capability for custom plugins

**Better Observability:**
- Enhanced logging format (structured JSON)
- OpenTelemetry support improvements
- Better metrics exposure

### 4. Ecosystem Alignment

**Supabase will eventually upgrade:**
- Current: `kong:2.8.1` (2+ years old)
- Community discussions about Kong 3.x upgrade
- Timeline: Unknown (could be 6-12+ months)

**By upgrading now:**
- ✅ No longer dependent on Supabase Kong image releases
- ✅ Use official Kong images (better support, faster security patches)
- ✅ Stay ahead of ecosystem changes

### 5. Enterprise Licensing Readiness

**If future needs arise:**
- Same image supports Enterprise licenses
- Just add `KONG_LICENSE_DATA` environment variable
- No migration needed (see Appendix A)

---

## Breaking Changes & Compatibility

### Kong 2.8 → 3.10 Upgrade Path

**Supported Upgrade Route:**
```
2.8.1 → 3.0.x → 3.10.0.6
```

**Direct Upgrade Supported:**
Kong documents that upgrades between adjacent LTS versions (2.8 → 3.0) are supported. However, in DB-less mode, we're not doing blue/green database upgrades, so this is less critical.

**In DB-less Mode:**
- No database schema migrations needed
- Declarative config is version-controlled
- Can test new version independently before cutover

### Declarative Configuration Compatibility

**Format Version:** `_format_version: '2.1'`
- ✅ Compatible with Kong 2.8.1
- ✅ Compatible with Kong 3.10.0.6
- ✅ No changes needed to `kong.yml`

**Our Current Config:** `/supabase-host/fly/kong/kong.yml`
```yaml
_format_version: '2.1'
_transform: true

consumers:
  - username: DASHBOARD
  - username: anon
    keyauth_credentials:
      - key: $SUPABASE_ANON_KEY
  # ... rest of config
```

**Validation:** All entities (consumers, services, routes, plugins) use standard Kong declarative format.

### Plugin Compatibility

**All Current Plugins Remain Free & Compatible:**

| Plugin | 2.8.1 | 3.10.0.6 | Status |
|--------|-------|----------|--------|
| `request-transformer` | ✅ Free | ✅ Free | No changes |
| `cors` | ✅ Free | ✅ Free | No changes |
| `key-auth` | ✅ Free | ✅ Free | No changes |
| `acl` | ✅ Free | ✅ Free | No changes |
| `basic-auth` | ✅ Free | ✅ Free | No changes |

**Configuration:** Plugin configs in `kong.yml` remain unchanged.

### Nginx/OpenResty Version Changes

**Kong 2.8.1:**
- OpenResty: 1.19.9.1
- Nginx core: 1.19.x

**Kong 3.10.0.6:**
- OpenResty: 1.25.3.1 (latest stable)
- Nginx core: 1.25.x

**Impact:** Better security, performance, HTTP/3 support

### Deprecated Features (Not Used by Us)

**Removed in Kong 3.x:**
- Legacy DAO (we use declarative config)
- Cassandra support (we use DB-less)
- Alpine images (we're switching to Debian)

**Impact:** None (we don't use these features)

### DNS Resolution Behavior

**Change in 3.x:** Improved DNS resolver with better caching

**Our Config:**
```yaml
KONG_DNS_ORDER: LAST,AAAA,A,CNAME  # MGF
KONG_DNS_ORDER: LAST,A,CNAME       # Local docker
```

**Action Required:** Test DNS resolution to `*.flycast` internal domains during staging validation.

### Environment Variables

**All our env vars remain compatible:**
```yaml
KONG_DATABASE: "off"
KONG_DECLARATIVE_CONFIG: /tmp/kong.yml
KONG_DNS_ORDER: LAST,AAAA,A,CNAME
KONG_LOG_LEVEL: debug
KONG_NGINX_PROXY_PROXY_BUFFERS: 64 160k
KONG_NGINX_PROXY_PROXY_BUFFER_SIZE: 160k
KONG_PLUGINS: request-transformer,cors,key-auth,acl,basic-auth
```

**New Optional Vars (Can Add Later):**
- `KONG_LICENSE_DATA` - For Enterprise features (Appendix A)
- `KONG_ADMIN_GUI_LISTEN` - Enable Kong Manager UI (e.g., `0.0.0.0:8002`)

---

## Upgrade Path

### Phased Rollout Strategy

```
Week 1: Local Development Environment
   ↓
Week 2: Staging/Test Instance (if exists)
   ↓
Week 3: Production Instance 1 (BEC - smaller)
   ↓
Week 4: Production Instance 2 (MGF - larger)
```

**Why This Order:**
1. **Local first** - Validate against local Supabase stack
2. **Smaller prod first** - BEC has fewer customers than MGF
3. **Staggered rollout** - Limit blast radius if issues arise

### Pre-Upgrade Checklist

- [ ] Backup current `kong.yml` configurations
- [ ] Document current Fly.io resource metrics (CPU, memory, request latency)
- [ ] Review Kong 3.10 changelog: https://docs.konghq.com/gateway/changelog/
- [ ] Review breaking changes: https://docs.konghq.com/gateway/latest/breaking-changes/
- [ ] Verify Fly.io deployment configs are in git
- [ ] Confirm rollback procedure with team
- [ ] Schedule maintenance window (if needed - likely zero downtime)

---

## Implementation Plan

### Phase 1: Local Development Environment (Week 1)

**Objective:** Validate Kong 3.10 with local Supabase stack

**Location:** `/Users/damonrand/code/supabase/supabase-host/docker/local/docker-compose.yml`

**Steps:**

1. **Backup Current Config**
   ```bash
   cd supabase-host/docker/local
   cp docker-compose.yml docker-compose.yml.2.8.1.bak
   cp ../volumes/api/kong.yml ../volumes/api/kong.yml.2.8.1.bak
   ```

2. **Update Docker Compose**
   ```yaml
   # docker-compose.yml
   kong:
     container_name: supabase-kong
     # image: public.ecr.aws/supabase/kong:2.8.1
     image: kong/kong-gateway:3.10.0.6-debian
     restart: unless-stopped
     # ... rest unchanged
   ```

3. **Start Local Stack**
   ```bash
   docker compose down
   docker compose pull kong
   docker compose up -d
   ```

4. **Validate Services**
   ```bash
   # Check Kong is healthy
   docker compose logs kong | grep "start Kong"

   # Test Auth endpoint
   curl -H "apikey: $ANON_KEY" http://localhost:54321/auth/v1/health

   # Test REST endpoint
   curl -H "apikey: $ANON_KEY" http://localhost:54321/rest/v1/

   # Test Studio (basic auth)
   curl -u "$DASHBOARD_USERNAME:$DASHBOARD_PASSWORD" http://localhost:54321/
   ```

5. **Check Kong Version**
   ```bash
   docker exec supabase-kong kong version
   # Expected: Kong Gateway 3.10.0.6
   ```

6. **Monitor Logs for Errors**
   ```bash
   docker compose logs -f kong | grep -i error
   ```

**Expected Duration:** 2 hours (including testing)

**Success Criteria:**
- ✅ All services start without errors
- ✅ Auth endpoints respond correctly
- ✅ REST API queries work
- ✅ Studio loads with basic auth
- ✅ No DNS resolution errors for internal services
- ✅ Plugin execution works (CORS, key-auth, ACL, basic-auth)

**Rollback:**
```bash
docker compose down
# Restore original image
git checkout docker-compose.yml
docker compose up -d
```

---

### Phase 2: Staging Instance (Week 2) - Optional

**Note:** If you have a staging Fly.io instance, use this phase. Otherwise, skip to Phase 3.

**Objective:** Validate Kong 3.10 on Fly.io infrastructure

**Steps:**

1. **Create Staging Config (if not exists)**
   ```bash
   cd supabase-host/fly/kong
   cp fly-kong-mgf.toml fly-kong-mgf-staging.toml
   ```

2. **Update Staging Config**
   ```toml
   # fly-kong-mgf-staging.toml
   app = 'supabase-kong-mgf-staging'
   primary_region = 'lhr'

   [build]
     image = 'kong/kong-gateway:3.10.0.6-debian'

   # ... rest unchanged
   ```

3. **Deploy to Staging**
   ```bash
   fly launch --no-deploy --org <myorg> --name supabase-kong-mgf-staging \
     --region lhr --copy-config --config fly-kong-mgf-staging.toml

   # Set secrets (same as production)
   ./secrets-mgf-staging.sh

   fly --config fly-kong-mgf-staging.toml deploy
   ```

4. **Validation Tests** (same as local)

**Expected Duration:** 4 hours (including monitoring)

**Success Criteria:** Same as Phase 1, plus:
- ✅ Fly.io health checks pass
- ✅ HTTPS/TLS works correctly
- ✅ No performance degradation vs production

---

### Phase 3: Production - BEC Instance (Week 3)

**Objective:** Upgrade smaller production instance first

**Instance:** `supabase-kong-bec` (Bridport Energy Community)
**Config:** `/supabase-host/fly/kong/fly-kong-bec.toml`

**Pre-Deployment:**

1. **Notify Stakeholders**
   - Announce maintenance window (if needed - likely zero downtime)
   - Expected impact: None (rolling deploy)
   - Rollback plan: Immediate revert to 2.8.1 if issues

2. **Backup Current State**
   ```bash
   cd supabase-host/fly/kong
   git commit -am "Pre-upgrade backup: Kong 2.8.1 BEC config"
   git tag kong-2.8.1-bec-$(date +%Y%m%d)
   git push --tags

   # Capture current metrics
   fly --config fly-kong-bec.toml status > bec-pre-upgrade-status.txt
   fly --config fly-kong-bec.toml logs --count 100 > bec-pre-upgrade-logs.txt
   ```

3. **Update Configuration**
   ```bash
   # Edit fly-kong-bec.toml
   vim fly-kong-bec.toml
   ```

   ```diff
   [build]
   - image = 'public.ecr.aws/supabase/kong:2.8.1'
   + image = 'kong/kong-gateway:3.10.0.6-debian'
   ```

4. **Commit Changes**
   ```bash
   git add fly-kong-bec.toml
   git commit -m "Upgrade BEC to Kong Gateway 3.10.0.6"
   ```

**Deployment:**

1. **Deploy New Version**
   ```bash
   fly --config fly-kong-bec.toml deploy
   ```

2. **Monitor Deployment**
   ```bash
   # Watch logs in real-time
   fly --config fly-kong-bec.toml logs

   # Check for "start Kong" message
   # Should see: Kong Gateway 3.10.0.6
   ```

3. **Validate Health**
   ```bash
   # Check Fly.io status
   fly --config fly-kong-bec.toml status

   # Test endpoints (replace with actual BEC domain)
   curl https://api.bec.example.com/auth/v1/health
   curl -H "apikey: $ANON_KEY" https://api.bec.example.com/rest/v1/
   ```

4. **Monitor for 24 Hours**
   ```bash
   # Check metrics
   fly --config fly-kong-bec.toml dashboard

   # Watch for errors
   fly --config fly-kong-bec.toml logs | grep -i error
   ```

**Expected Duration:**
- Deployment: 5 minutes
- Validation: 30 minutes
- Monitoring period: 24 hours

**Success Criteria:**
- ✅ Zero downtime during deployment
- ✅ All health checks pass
- ✅ API latency unchanged or improved
- ✅ No errors in logs
- ✅ Memory usage ≤ 512MB
- ✅ Customer-facing apps work normally

**Rollback Procedure (If Needed):**

```bash
# Revert git commit
git revert HEAD
git push

# Redeploy 2.8.1
fly --config fly-kong-bec.toml deploy

# Verify rollback
fly --config fly-kong-bec.toml logs | grep "Kong 2.8.1"
```

**Expected rollback time:** < 5 minutes

---

### Phase 4: Production - MGF Instance (Week 4)

**Objective:** Upgrade primary production instance

**Instance:** `supabase-kong-mgf` (Microgrid Foundry)
**Config:** `/supabase-host/fly/kong/fly-kong-mgf.toml`

**Prerequisites:**
- ✅ BEC upgrade successful (Phase 3)
- ✅ No issues reported for 1 week minimum
- ✅ Stakeholder approval to proceed

**Steps:** Same as Phase 3 (BEC), but for MGF instance

**Key Differences:**
- **Higher traffic:** Monitor more closely
- **More customers:** Longer monitoring period (48 hours vs 24 hours)
- **Business-critical:** Coordinate with operations team

**Deployment Window:**
- **Recommended:** Off-peak hours (e.g., 2am UK time)
- **Duration:** 5-10 minutes
- **Expected impact:** None (zero-downtime deployment)

**Success Criteria:** Same as Phase 3

---

## Testing Strategy

### Automated Tests

**Pre-Deployment Validation:**

```bash
#!/bin/bash
# test-kong-upgrade.sh

set -e

echo "Testing Kong Gateway endpoints..."

# Variables
KONG_URL="${KONG_URL:-http://localhost:54321}"
ANON_KEY="${ANON_KEY:-your-anon-key}"
SERVICE_KEY="${SERVICE_KEY:-your-service-key}"

# Test 1: Auth Health Check
echo "✓ Testing /auth/v1/health"
curl -sf -H "apikey: $ANON_KEY" "$KONG_URL/auth/v1/health" || exit 1

# Test 2: REST API
echo "✓ Testing /rest/v1/ (anonymous)"
curl -sf -H "apikey: $ANON_KEY" "$KONG_URL/rest/v1/" || exit 1

# Test 3: REST API (service role)
echo "✓ Testing /rest/v1/ (service role)"
curl -sf -H "apikey: $SERVICE_KEY" "$KONG_URL/rest/v1/" || exit 1

# Test 4: CORS Preflight
echo "✓ Testing CORS preflight"
curl -sf -X OPTIONS \
  -H "Origin: https://example.com" \
  -H "Access-Control-Request-Method: GET" \
  "$KONG_URL/rest/v1/" || exit 1

# Test 5: Basic Auth (Dashboard)
echo "✓ Testing basic auth (dashboard)"
curl -sf -u "$DASHBOARD_USERNAME:$DASHBOARD_PASSWORD" "$KONG_URL/" || exit 1

# Test 6: ACL (should reject anon to admin endpoints)
echo "✓ Testing ACL (expecting 403)"
HTTP_CODE=$(curl -sf -o /dev/null -w "%{http_code}" -H "apikey: $ANON_KEY" "$KONG_URL/pg/")
if [ "$HTTP_CODE" != "403" ]; then
  echo "❌ ACL test failed: expected 403, got $HTTP_CODE"
  exit 1
fi

echo "✅ All tests passed!"
```

### Manual Testing Checklist

**For Each Instance:**

- [ ] **Kong Health Check**
  - Kong process started successfully
  - No errors in logs
  - Version reports as 3.10.0.6

- [ ] **Authentication**
  - Anonymous key access works
  - Service role key access works
  - Basic auth (dashboard) works
  - Invalid keys rejected (401)

- [ ] **Authorization (ACL)**
  - Anon role can access public routes
  - Anon role blocked from admin routes (403)
  - Service role can access admin routes

- [ ] **CORS**
  - Preflight requests handled
  - CORS headers present in responses
  - Cross-origin requests work

- [ ] **Service Routing**
  - `/auth/v1/*` routes to GoTrue
  - `/rest/v1/*` routes to PostgREST
  - `/pg/*` routes to pg-meta
  - `/` routes to Studio (with basic auth)

- [ ] **DNS Resolution**
  - Internal `*.flycast` domains resolve
  - No DNS timeout errors in logs

- [ ] **Performance**
  - Request latency ≤ baseline
  - Memory usage ≤ 512MB
  - CPU usage normal

- [ ] **User-Facing Apps**
  - Web app loads and authenticates
  - Mobile app connects successfully
  - API integrations work

### Load Testing (Optional)

**If available, run load tests to compare performance:**

```bash
# Using Apache Bench
ab -n 1000 -c 10 -H "apikey: $ANON_KEY" "$KONG_URL/rest/v1/"

# Using hey (https://github.com/rakyll/hey)
hey -n 1000 -c 10 -H "apikey: $ANON_KEY" "$KONG_URL/rest/v1/"
```

**Compare:**
- Requests per second
- Mean latency
- 95th percentile latency
- Error rate (should be 0%)

---

## Rollback Plan

### When to Rollback

**Immediate rollback if:**
- ❌ Kong fails to start
- ❌ Any service returns 5xx errors
- ❌ Authentication/authorization broken
- ❌ Memory usage exceeds 512MB
- ❌ Crash loops or restart failures

**Consider rollback if:**
- ⚠️ Increased latency (>20% vs baseline)
- ⚠️ Errors in logs (even if requests succeed)
- ⚠️ DNS resolution issues
- ⚠️ User reports of issues

### Rollback Procedure

**Step 1: Revert Git Commit**
```bash
cd supabase-host/fly/kong
git revert HEAD --no-commit
git commit -m "Rollback to Kong 2.8.1 due to [REASON]"
git push
```

**Step 2: Redeploy Previous Version**
```bash
# For BEC
fly --config fly-kong-bec.toml deploy

# For MGF
fly --config fly-kong-mgf.toml deploy
```

**Step 3: Verify Rollback**
```bash
# Check version
fly --config fly-kong-<instance>.toml logs | grep "Kong 2.8.1"

# Run test suite
./test-kong-upgrade.sh
```

**Step 4: Document Issue**
- Capture logs from failed deployment
- Note error messages, metrics, user reports
- File issue in project tracker
- Schedule post-mortem

**Expected Rollback Time:** < 10 minutes

### Rollback Testing

**Before production deployment, verify rollback works:**

```bash
# In local or staging
1. Deploy Kong 3.10.0.6
2. Validate it works
3. Rollback to 2.8.1
4. Validate 2.8.1 works
5. Re-deploy 3.10.0.6
```

This confirms the rollback procedure is reliable.

---

## Monitoring & Validation

### Key Metrics to Track

**Before Upgrade (Baseline):**
- Average request latency (p50, p95, p99)
- Requests per second
- Error rate (%)
- Memory usage (MB)
- CPU usage (%)

**During Upgrade:**
- Deployment success/failure
- Time to healthy state
- Zero downtime achieved (yes/no)

**After Upgrade (Compare to Baseline):**
- Request latency (should be ≤ baseline, ideally better)
- Error rate (should remain 0%)
- Memory usage (should be ≤ baseline)
- CPU usage (should be ≤ baseline)

### Fly.io Monitoring

**Dashboard:**
```bash
fly --config fly-kong-<instance>.toml dashboard
```

**Metrics:**
```bash
# Real-time logs
fly --config fly-kong-<instance>.toml logs

# Status
fly --config fly-kong-<instance>.toml status

# Health checks
fly --config fly-kong-<instance>.toml checks
```

### Kong Metrics (Optional: Enable Later)

**Kong Admin API (Currently Not Exposed):**

If needed, can expose Admin API to collect metrics:
```yaml
# kong.yml (future enhancement)
KONG_ADMIN_LISTEN: 127.0.0.1:8001  # Localhost only for security
```

Then query:
```bash
curl http://localhost:8001/status
curl http://localhost:8001/metrics
```

**Kong Manager (Optional):**

Can enable Kong Manager UI in 3.10 (included free):
```yaml
KONG_ADMIN_GUI_LISTEN: 0.0.0.0:8002
```

Access at `http://<instance>:8002` to view routes/services/plugins visually.

### Alerting

**Recommended Alerts:**
- Kong container restarts (should be 0)
- HTTP 5xx error rate > 0.1%
- Request latency p95 > 500ms
- Memory usage > 400MB (80% of limit)

**Fly.io Alerts:**
Configure via `fly.toml` or Fly.io dashboard.

---

## Success Criteria

### Phase 1: Local Development
- ✅ Kong 3.10.0.6 runs locally without errors
- ✅ All test endpoints respond correctly
- ✅ No breaking changes detected in config
- ✅ Plugin functionality validated

### Phase 2: Staging (if applicable)
- ✅ Kong 3.10.0.6 deploys to Fly.io successfully
- ✅ HTTPS/TLS works correctly
- ✅ Performance metrics meet or exceed baseline

### Phase 3: Production BEC
- ✅ Zero downtime deployment achieved
- ✅ All services healthy for 24+ hours
- ✅ No customer-reported issues
- ✅ Metrics ≤ baseline (latency, errors, resources)
- ✅ Rollback tested and working

### Phase 4: Production MGF
- ✅ Zero downtime deployment achieved
- ✅ All services healthy for 48+ hours
- ✅ No customer-reported issues
- ✅ Metrics ≤ baseline
- ✅ Operations team sign-off

### Overall Project Success
- ✅ All instances upgraded to Kong 3.10.0.6
- ✅ $0 spent (remained on free tier)
- ✅ Extended support through ~2027 (LTS)
- ✅ No production incidents
- ✅ Documentation updated (this file committed to git)
- ✅ Team trained on new version

---

## Appendix A: Enterprise Licensing Option

### Overview

Kong Gateway 3.10.0.6 supports both **Free (OSS)** and **Enterprise** features using the **same Docker image**. The only difference is adding a license key via the `KONG_LICENSE_DATA` environment variable.

This means you can upgrade all instances to 3.10.0.6 (Free) now, and **later** add Enterprise licenses to specific instances as needs arise—without any migration or architecture changes.

### How to Add Enterprise License

**Step 1: Obtain License from Kong**
- Contact Kong sales: https://konghq.com/pricing
- Sign Enterprise subscription agreement
- Receive `license.json` file

**Step 2: Add License as Fly.io Secret**
```bash
# Store license in Fly.io secrets (never commit to git)
fly secrets set KONG_LICENSE_DATA="$(cat license.json)" \
  --app supabase-kong-mgf
```

**Step 3: Update Fly.io Config (Optional)**
```toml
# fly-kong-mgf.toml
[env]
  # License will be read from Fly secrets, but can document here
  # KONG_LICENSE_DATA is set via `fly secrets set`

  # Optionally enable Kong Manager with RBAC
  KONG_ADMIN_GUI_LISTEN = "0.0.0.0:8002"
```

**Step 4: Redeploy (No Image Change Needed)**
```bash
fly --config fly-kong-mgf.toml deploy
```

**Step 5: Verify Enterprise Features Enabled**
```bash
fly --config fly-kong-mgf.toml logs | grep "Kong Gateway Enterprise"
```

**That's it!** Enterprise plugins are now available.

### What Enterprise Adds

**Premium Plugins (Enterprise-Only):**

#### Authentication & Security
- **OpenID Connect (OIDC)** - SSO with Azure AD, Okta, Google Workspace
  - Use case: Let operators authenticate with corporate identity providers
  - Example: BEC users login with Google Workspace accounts

- **OAuth 2.0 Introspection** - Validate tokens with external auth servers

- **LDAP/Active Directory** - Enterprise directory authentication

- **mTLS Authentication** - Mutual TLS for service-to-service security

- **Secrets Management** - Vault integration
  - Supported: AWS Secrets Manager, Azure Key Vault, HashiCorp Vault, GCP Secrets Manager
  - Use case: Store `SUPABASE_ANON_KEY`, `JWT_SECRET` in vault, reference via `{vault://aws/key}`
  - Benefit: Secrets never in config files or environment variables

#### Traffic Control
- **Rate Limiting Advanced** - Enhanced rate limiting
  - Sliding window counters (more accurate than fixed windows)
  - Redis Sentinel support (high availability)
  - Better performance in DB-less mode
  - Use case: Protect APIs from abuse/DDoS

- **Request Validator** - OpenAPI schema enforcement
  - Validate requests against OpenAPI 3.0 spec
  - Reject malformed requests at gateway layer
  - Use case: Protect PostgREST from invalid queries

- **Canary Release** - Gradual traffic shifting
  - Route X% traffic to new service version
  - Use case: Test new GoTrue version with 10% of traffic

- **Forward Proxy** - Egress control
  - Whitelist/blacklist outbound HTTP requests
  - Use case: Control which external APIs upstream services can call

- **GraphQL Rate Limiting** - Query complexity-based limits
  - Prevent expensive queries from overloading DB

#### Observability
- **Kong Vitals** - Real-time analytics dashboard
  - Request rates, latency, errors
  - Per-service, per-route, per-consumer metrics
  - Time-series graphs in Kong Manager

- **Proxy Cache Advanced** - Enhanced caching
  - More cache strategies (memory, redis)
  - Cache invalidation controls

#### Management
- **Kong Manager** - Web UI with full RBAC
  - In Free version: Read-only in DB-less mode
  - In Enterprise: Full read/write (still limited in DB-less)
  - RBAC: Control who can view/edit specific routes/services

- **Workspaces** - Multi-tenancy
  - Separate Kong configuration into logical workspaces
  - Use case: Isolate MGF vs BEC configs in single Kong instance
  - Note: Less relevant for your architecture (already separate instances)

- **Dev Portal** - API documentation portal
  - Publish OpenAPI specs
  - Developer onboarding
  - API key management
  - Use case: External developers consuming Simtricity APIs

#### Support
- **24/7/365 Professional Support** - SLA-backed
  - Direct access to Kong engineers
  - Priority bug fixes
  - Security patch prioritization
  - Upgrade assistance

### Enterprise Plugins in DB-less Mode

**✅ Most Enterprise plugins work in DB-less mode:**
- OpenID Connect (OIDC)
- Rate Limiting Advanced (with `redis` or `local` policy)
- Request Validator
- Canary Release
- Secrets Management
- mTLS Authentication
- Forward Proxy

**⚠️ Limitations in DB-less** (even with Enterprise):
- Rate limiting `cluster` policy unavailable (use `redis` or `local`)
- Admin API remains read-only (cannot dynamically add plugins)
- Workspaces less useful (configuration is declarative)

**Best use of Enterprise in DB-less:**
- Add plugins to `kong.yml` declaratively
- Redeploy to activate new plugins
- Fits existing CI/CD workflow

### Cost Estimates

**Kong doesn't publish pricing** (contact sales), but industry estimates:

| Deployment Scale | Annual Cost (per instance) |
|------------------|----------------------------|
| 1-5 data planes | ~$5,000 - $10,000 |
| 5-25 data planes | ~$20,000 - $50,000 (volume discount) |
| 25+ data planes | ~$100,000+ (enterprise tier) |

**For Simtricity:**
- Current instances: 2 (MGF, BEC)
- Future: Potentially 5-10 (WLCE, HMCE, new customers)

**Recommended Licensing Strategy:**
- Start with **1 instance** (e.g., MGF): ~$5k-10k/year
- Evaluate ROI for 3-6 months
- Each operator decides independently if value justifies cost

### When to License

**✅ License if:**
- Operator needs **OIDC/SSO** (no free alternative)
- Compliance requires **secrets management** (audit requirement)
- Need **professional support** (24/7 SLA for critical infrastructure)
- **Request validation** prevents DB overload (security hardening)
- Managing 5+ instances (workspaces/RBAC valuable)

**❌ Stay free if:**
- Current auth (key-auth, basic-auth, JWT) is sufficient
- Rate limiting can use Redis (free plugin + small Redis instance ~$5/mo)
- Secrets managed by Fly.io secrets (adequate for most use cases)
- Community support acceptable (GitHub issues, Kong Nation forums)

### Example: Adding OIDC Plugin

**Scenario:** MGF wants operators to login with Google Workspace accounts.

**Step 1: Add to `kong.yml`**
```yaml
services:
  - name: rest-v1
    url: http://supabase-rest-mgf.flycast:3000/
    routes:
      - name: rest-v1-all
        paths:
          - /rest/v1/
    plugins:
      - name: cors
      # Add OIDC plugin (Enterprise only)
      - name: openid-connect
        config:
          issuer: "https://accounts.google.com/.well-known/openid-configuration"
          client_id: "your-google-client-id"
          client_secret: "{vault://gcp/google-client-secret}"
          redirect_uri: "https://api.mgf.example.com/rest/v1/callback"
          scopes:
            - openid
            - email
            - profile
          # ACL integration
          authenticated_groups_claim: "groups"
```

**Step 2: Store client secret in GCP Secrets Manager**
```bash
gcloud secrets create google-client-secret --data-file=secret.txt
```

**Step 3: Configure Kong to use GCP vault**
```yaml
# kong.yml
_format_version: '2.1'

vaults:
  - name: gcp
    config:
      project_id: "simtricity-prod"
```

**Step 4: Redeploy**
```bash
fly --config fly-kong-mgf.toml deploy
```

Now users authenticate via Google, and Kong validates tokens before proxying to PostgREST.

### Example: Adding Rate Limiting

**Scenario:** Protect APIs from abuse with 1000 req/minute per IP.

**Free Option (Basic Rate Limiting + Redis):**
```yaml
# 1. Deploy Redis on Fly.io (~$5/mo)
fly apps create simtricity-redis
fly redis create --app simtricity-redis

# 2. Add to kong.yml
services:
  - name: rest-v1
    plugins:
      - name: rate-limiting
        config:
          policy: redis
          redis_host: simtricity-redis.internal
          redis_port: 6379
          minute: 1000
          limit_by: ip
```

**Enterprise Option (Advanced Rate Limiting):**
```yaml
services:
  - name: rest-v1
    plugins:
      - name: rate-limiting-advanced  # Enterprise plugin
        config:
          strategy: redis
          redis_host: simtricity-redis.internal
          redis_port: 6379
          limit:
            - 1000
          window_size:
            - 60
          window_type: sliding  # More accurate than fixed windows
          identifier: ip
```

**Benefit of Enterprise version:**
- Sliding windows (fairer, harder to game)
- Better performance
- More configuration options

**Cost/benefit:**
- Free version: $0 (+ ~$5/mo Redis)
- Enterprise: ~$5k-10k/year

**Recommendation:** Try free version first. Upgrade to Enterprise if you need sliding windows or hit performance limits.

---

## Appendix B: Research Summary

### Kong Gateway Deployment Topologies

Kong supports three deployment modes:

1. **Hybrid Mode** (CP/DP separation)
   - Control Plane manages configuration
   - Data Plane handles traffic
   - Best for: Multi-region, Konnect platform
   - **Not used by Simtricity** (all-in-one instances)

2. **Traditional Mode** (Database-backed)
   - All nodes connect to shared PostgreSQL/Cassandra
   - Dynamic configuration via Admin API
   - Best for: Dynamic environments, plugin development
   - **Not used by Simtricity** (DB-less is better for CI/CD)

3. **DB-less Mode** (Declarative config) ✅ **We use this**
   - Configuration in YAML/JSON files
   - In-memory storage only
   - Immutable deployments
   - Best for: CI/CD, GitOps, Kubernetes
   - **Perfect for Simtricity architecture**

### DB-less Mode Characteristics

**Advantages:**
- ✅ Configuration always in known state (version-controlled)
- ✅ No database to manage/backup
- ✅ Faster startup (no DB queries)
- ✅ Easier rollback (just redeploy)
- ✅ Ideal for CI/CD pipelines

**Limitations:**
- ⚠️ Admin API is read-only (expected)
- ⚠️ Rate limiting `cluster` policy unavailable (use `redis` or `local`)
- ⚠️ Plugins requiring dynamic entity creation don't work (e.g., OAuth2 plugin that creates tokens)
- ⚠️ Must redeploy to change configuration (acceptable for our workflow)

**Plugins Compatible with DB-less:**
- ✅ All our current plugins (request-transformer, cors, key-auth, acl, basic-auth)
- ✅ Most Enterprise plugins (OIDC, rate-limiting-advanced, request-validator, canary)
- ❌ OAuth2 plugin (creates credentials dynamically)
- ❌ Rate limiting with `cluster` policy (requires database)

### Kong Konnect Platform (SaaS)

**What is Konnect:**
- Kong-hosted SaaS control plane
- Manages configuration for distributed data planes
- Includes: Advanced analytics, Dev Portal, API catalog
- Auto-provisions Enterprise licenses

**Data Plane Options:**
- **Serverless gateways** - Kong-hosted, zero management
- **Dedicated Cloud Gateways** - Kong-managed on AWS/Azure/GCP
- **Self-hosted data planes** - You run, Kong manages control plane

**Licensing:**
- Enterprise licenses automatically included with Konnect account
- No separate license files needed
- Paid per data plane

**Use Case for Simtricity:**
- Could connect all instances (MGF, BEC, WLCE, HMCE) to single control plane
- Centralized visibility across customers
- Unified API catalog
- Each instance remains isolated (separate data plane)

**When to Consider Konnect:**
- Managing 5+ customer instances
- Need centralized analytics dashboard
- Want unified API documentation portal
- Willing to add cloud dependency (control plane hosted by Kong)

**Why Not Konnect (for now):**
- Adds complexity (cloud dependency)
- Higher cost than self-hosted Enterprise
- Current architecture (standalone instances) works well
- Each operator prefers full independence

**Recommendation:** Revisit Konnect when managing 10+ customer instances.

### Kong Gateway Versions

**Current LTS Versions:**
- **2.8.x** (current) - Released 2022, EOL ~2025-2027
- **3.10.x** (target) - Released 2024, EOL ~2027

**Latest Stable:** Kong Gateway 3.12.0.0 (but 3.10 is LTS)

**LTS Support Policy:**
- 4 minor releases per year (starting 2025)
- First release each year becomes LTS
- Each LTS supported for 3 years

**Why 3.10 (not 3.12):**
- 3.10 is LTS (Long-Term Support)
- 3.12 is standard release (shorter support window)
- LTS gets security patches for 3 years

**Upgrade Path:**
- ✅ 2.8.1 → 3.0.x → 3.10.0.6 (supported)
- ✅ 2.8.1 → 3.10.0.6 (likely works in DB-less mode, test first)

**Future Upgrades:**
- Kong Gateway 4.x coming 2025
- Can upgrade 3.10 → 4.x LTS when available

### Kong Free vs Enterprise

**Kong Gateway Free (OSS):**
- Free forever
- All core gateway features (routing, auth, rate limiting, transformations)
- 50+ free plugins
- Kong Manager UI (read-only in DB-less)
- Community support (GitHub, forums)

**Kong Gateway Enterprise:**
- Paid subscription (~$5k-10k+ per instance/year)
- All Free features, plus:
  - 29 premium plugins (OIDC, secrets management, advanced rate limiting)
  - Kong Vitals (real-time analytics)
  - Dev Portal (API documentation)
  - Workspaces & RBAC (multi-tenancy)
  - 24/7 professional support (SLA-backed)
- **Same Docker image** (license toggles features)

**Key Insight:** Free → Enterprise is a license key addition, not a migration.

### Docker Images

**Alpine Discontinued:**
- Kong stopped publishing Alpine images in 3.4+
- Reason: Debian images now minimal and security-scanned
- Alpine compatibility issues with some plugins

**Available Images (Kong 3.10.0.6):**
- `kong/kong-gateway:3.10.0.6-debian` ✅ Recommended (smallest)
- `kong/kong-gateway:3.10.0.6-ubuntu`
- `kong/kong-gateway:3.10.0.6-rhel`
- `kong/kong-gateway:3.10.0.6-amazonlinux-2023`

**Supabase Kong Images:**
- Current: `public.ecr.aws/supabase/kong:2.8.1`
- No Kong 3.x images from Supabase yet
- Timeline: Unknown (could be months)
- **Recommendation:** Use official Kong images (no vendor lock-in)

### Rate Limiting in DB-less Mode

**Three Policies:**
1. **`local`** (Free) - Per-instance counters
   - Pros: Simple, no external dependencies
   - Cons: Inaccurate with multiple instances (each counts separately)
   - Use case: Single instance, or accuracy not critical

2. **`redis`** (Free) - Shared counters in Redis
   - Pros: Accurate across instances, free plugin
   - Cons: Requires Redis instance (~$5/mo)
   - Use case: Multiple instances, need accuracy

3. **`cluster`** (Free in Traditional mode, N/A in DB-less)
   - Pros: Accurate, no external dependencies
   - Cons: **Requires database** (not available in DB-less)
   - Use case: Traditional mode deployments only

**Enterprise `rate-limiting-advanced`:**
- Supports `redis` policy (not `cluster` in DB-less)
- Sliding windows (more accurate than fixed windows)
- Better performance
- Redis Sentinel support (HA)

**Recommendation for Simtricity:**
- Current: No rate limiting configured
- If needed: Start with free `rate-limiting` plugin + Redis
- Upgrade to Enterprise if you need sliding windows

### OpenID Connect (OIDC) Plugin

**Enterprise-Only Plugin**

**Use Case:**
- Authenticate users with external identity providers
- Examples: Azure AD, Okta, Google Workspace, Keycloak

**How It Works:**
1. User requests protected API
2. Kong redirects to IdP login page
3. User authenticates with IdP (e.g., Google)
4. IdP returns to Kong with ID token
5. Kong validates token and proxies request

**Integration with ACL:**
- OIDC plugin can extract groups from JWT claims
- Use with `acl` plugin for authorization
- Example: `groups: ["admin"]` → ACL allows access to admin routes

**Alternatives (Free):**
- Implement OIDC in your application (not at gateway level)
- Use Supabase Auth with social logins (Google, GitHub)
- Use `key-auth` or `jwt` plugins with manual token management

**When to Use:**
- Operator wants corporate SSO (Azure AD, Google Workspace)
- Centralized user management across multiple apps
- Compliance requires enterprise identity integration

### Secrets Management (Vault Integration)

**Enterprise-Only Feature**

**Supported Vault Backends:**
- AWS Secrets Manager
- Azure Key Vault
- Google Cloud Secret Manager
- HashiCorp Vault

**How It Works:**
1. Store secrets in vault (e.g., AWS Secrets Manager)
2. Reference in `kong.yml` via vault URI: `{vault://aws/supabase-anon-key}`
3. Kong fetches secret at runtime
4. Secret never in config files or environment variables

**Example:**
```yaml
# kong.yml
_format_version: '2.1'

vaults:
  - name: aws
    config:
      region: "eu-west-2"

consumers:
  - username: anon
    keyauth_credentials:
      - key: "{vault://aws/supabase-anon-key}"  # Fetched from AWS Secrets Manager
```

**Benefits:**
- Secrets rotation (change in vault, no redeploy)
- Audit trail (who accessed which secrets)
- Compliance (SOC 2, ISO 27001, GDPR)
- Reduced exposure (secrets never in git or logs)

**Alternatives (Free):**
- Fly.io secrets: `fly secrets set KEY=value`
- Environment variables (less secure, but adequate for many use cases)
- Separate secrets management tool (Vault, SOPS, sealed-secrets)

**When to Use:**
- Compliance audit requires secrets management
- Multiple teams need access to secrets
- Secrets rotation required frequently

### Breaking Changes Summary (2.8 → 3.10)

**No Breaking Changes for Our Use Case:**

✅ **Unchanged:**
- Declarative configuration format (`_format_version: '2.1'`)
- All our plugins (request-transformer, cors, key-auth, acl, basic-auth)
- Environment variables (`KONG_DATABASE`, `KONG_DECLARATIVE_CONFIG`, etc.)
- Service routing behavior
- Plugin execution order

⚠️ **Changed (but not impacting us):**
- Alpine images discontinued (switching to Debian)
- Legacy DAO removed (we use declarative config)
- Cassandra support removed (we use DB-less)
- OpenResty version upgraded (1.19 → 1.25) - better security/performance
- Nginx core upgraded (1.19 → 1.25) - HTTP/3 support

✅ **New Features (Can Use Later):**
- Kong Manager UI (now free, but read-only in DB-less)
- WebAssembly plugin support (for custom plugins)
- HTTP/3 support (automatic, no config needed)
- Better observability (OpenTelemetry improvements)

**Testing Required:**
- DNS resolution to `*.flycast` internal domains (changed DNS resolver)
- Plugin execution (validate all plugins work in 3.10)
- HTTPS/TLS (should work, but verify certs)

### Supabase Kong Version Status

**Official Supabase:**
- Docker Compose: `kong:2.8.1`
- ECR: `public.ecr.aws/supabase/kong:2.8.1`
- Last updated: 2022 (2+ years old)

**Community Requests for Kong 3.x:**
- GitHub discussions mention Kong 3.4 (includes Kong Manager GUI)
- No official timeline for upgrade
- Some users manually upgrading in custom deployments

**Why Supabase Hasn't Upgraded:**
- Kong 2.8 is stable and working
- Breaking changes require testing across entire Supabase stack
- Community contributions welcome (open-source project)

**Impact on Simtricity:**
- We're currently using Supabase's Kong 2.8.1 image
- By switching to official Kong images, we:
  - ✅ No longer dependent on Supabase release schedule
  - ✅ Get security patches faster
  - ✅ Can upgrade to 3.10, 3.12, 4.x independently
  - ✅ Maintain compatibility with Supabase services (kong.yml unchanged)

**No vendor lock-in:** `kong.yml` is standard Kong declarative format.

---

## Appendix C: Resources

### Official Kong Documentation

**Kong Gateway 3.10:**
- Docs: https://developer.konghq.com/gateway/
- Changelog: https://developer.konghq.com/gateway/changelog/
- Upgrade Guide: https://developer.konghq.com/gateway/upgrade/
- Breaking Changes: https://developer.konghq.com/gateway/latest/breaking-changes/

**DB-less Mode:**
- DB-less Reference: https://developer.konghq.com/gateway/db-less-mode/
- Declarative Config: https://docs.konghq.com/gateway/latest/production/deployment-topologies/db-less-and-declarative-config/

**Plugins:**
- Plugin Hub: https://developer.konghq.com/plugins/
- Rate Limiting: https://developer.konghq.com/plugins/rate-limiting/
- Rate Limiting Advanced (Enterprise): https://developer.konghq.com/plugins/rate-limiting-advanced/
- OpenID Connect (Enterprise): https://developer.konghq.com/plugins/openid-connect/

**Licensing:**
- License Deployment: https://developer.konghq.com/gateway/entities/license/
- Pricing: https://konghq.com/pricing

**Deployment Topologies:**
- Overview: https://developer.konghq.com/gateway/deployment-topologies/

**Kong Konnect:**
- Konnect Docs: https://developer.konghq.com/konnect/

### Docker Images

**Official Kong Registry:**
- Docker Hub: https://hub.docker.com/r/kong/kong-gateway/tags
- Kong 3.10.0.6: `kong/kong-gateway:3.10.0.6-debian`

**Supabase Registry:**
- ECR: https://gallery.ecr.aws/supabase/kong
- GitHub Packages: https://github.com/orgs/supabase/packages?repo_name=supabase

### Supabase Documentation

**Self-Hosting:**
- Docker Guide: https://supabase.com/docs/guides/self-hosting/docker
- Architecture: https://supabase.com/docs/guides/auth/architecture

**Supabase GitHub:**
- Main Repo: https://github.com/supabase/supabase
- Docker Compose: https://github.com/supabase/supabase/blob/master/docker/docker-compose.yml
- Kong Config: https://github.com/supabase/supabase/blob/master/docker/volumes/api/kong.yml

### Fly.io Documentation

**Deployment:**
- Fly.io Docs: https://fly.io/docs/
- Configuration Reference: https://fly.io/docs/reference/configuration/
- Secrets Management: https://fly.io/docs/reference/secrets/

### Community Resources

**Kong Nation (Forums):**
- https://discuss.konghq.com/

**Kong GitHub:**
- Kong OSS: https://github.com/Kong/kong
- Kong Docker: https://github.com/Kong/docker-kong
- Issues: https://github.com/Kong/kong/issues
- Upgrade Guide (GitHub): https://github.com/Kong/kong/blob/master/UPGRADE.md

### Testing Tools

**HTTP Testing:**
- curl: https://curl.se/
- HTTPie: https://httpie.io/
- Postman: https://www.postman.com/

**Load Testing:**
- Apache Bench: https://httpd.apache.org/docs/2.4/programs/ab.html
- hey: https://github.com/rakyll/hey
- k6: https://k6.io/

**Monitoring:**
- Fly.io Dashboard: `fly dashboard`
- Kong Admin API: http://localhost:8001/ (if exposed)
- Kong Manager: http://localhost:8002/ (if enabled)

### Internal Simtricity Resources

**Codebase:**
- Repository: `/Users/damonrand/code/supabase/`
- Kong Configs: `supabase-host/fly/kong/`
- MGF Config: `fly-kong-mgf.toml`
- BEC Config: `fly-kong-bec.toml`
- Kong YAML: `kong.yml`

**Documentation:**
- Project README: `supabase-host/README.md`
- This Upgrade Plan: `supabase-host/docs/kong-3.10-upgrade-plan.md`

**Contact:**
- Project Lead: Damon Rand
- Team: Cepro, Simtricity, Microgrid Foundry

---

## Change Log

| Date | Version | Author | Changes |
|------|---------|--------|---------|
| 2025-10-18 | 1.0 | Damon Rand | Initial document: Complete upgrade plan and research summary |

---

## Approval & Sign-Off

**Plan Reviewed By:**
- [ ] Damon Rand (Project Lead)
- [ ] Operations Team
- [ ] Development Team

**Approved for Execution:**
- [ ] Signature: _________________ Date: _________

**Post-Deployment Review:**
- [ ] All instances upgraded successfully
- [ ] No incidents reported
- [ ] Success criteria met
- [ ] Documentation updated
- [ ] Lessons learned documented

---

## Next Steps

1. **Review this document** with stakeholders
2. **Schedule upgrade windows** (if needed - likely zero downtime)
3. **Backup current configs** (git commit + tag)
4. **Start Phase 1** (local environment) - Week 1
5. **Execute phased rollout** - Weeks 2-4
6. **Monitor and validate** - Post-deployment
7. **Document lessons learned** - Post-upgrade review
8. **Consider Enterprise licensing** - Q2 2025 (see Appendix A)

---

**End of Document**
