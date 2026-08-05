# From Working Prototype to Real Company App

Two questions, answered together: **(1) how do we make this app solid enough for a real business to depend on**, and **(2) how do we actually get it running and onto employees' phones**. Part 2 is written in plain steps on purpose.

Current decision: **stick with the Django backend** (`backend_new`). It already has JWT auth, tests, API docs, and env-based settings — it's a real foundation, not a prototype. The `spring_backend` rewrite was abandoned (see note at the end).

This version supersedes the previous one — it's grounded in an actual code audit (exact file:line references below) rather than generic advice, and it reflects a firm decision: **no Google Play Store, no Apple TestFlight** — this is a private company tool, distributed via Firebase App Distribution instead (see Part 2, Problem B).

---

## Part 1 — Making the app production-solid

Do these roughly in order. Each one is a checklist item, not a project.

### 1. Lock down the settings — `backend_new/aljazeera_stca/settings.py`
- [ ] `DEBUG` (line 28) currently **defaults to `True`** when the env var is missing — set `DEBUG=False` in prod and make the code default to `False` too, so a missing env var fails safe, not open.
- [ ] `ALLOWED_HOSTS` (lines 30-34) currently defaults to `'localhost,127.0.0.1,0.0.0.0,*'` — the `*` wildcard must go once there's a real domain.
- [ ] `SECRET_KEY` (line 25) is externalized via `python-decouple` — good — but the fallback default `'dev-only-change-me'` must never be reachable in prod (the env var must always be set on the server).
- [ ] `CORS_ALLOW_ALL_ORIGINS = True` (line 193) is hardcoded, no env override — replace with `CORS_ALLOWED_ORIGINS` listing only the app's real origin(s).
- [ ] No HTTPS/cookie-security settings exist at all — add `SECURE_SSL_REDIRECT`, `SESSION_COOKIE_SECURE`, `CSRF_COOKIE_SECURE`, `SECURE_HSTS_SECONDS`, `SECURE_PROXY_SSL_HEADER` (needed once Nginx is the TLS terminator).
- [ ] No throttle classes in `REST_FRAMEWORK` (lines 164-179) — add `DEFAULT_THROTTLE_CLASSES`, at minimum rate-limiting the login endpoint.
- [ ] Run `python manage.py check --deploy` on the server and fix everything it warns about.

### 2. Stop using the dev server
- [ ] `requirements.txt` is missing `gunicorn` and `whitenoise` — add both.
- [ ] Write a `Dockerfile` for the Django app + a `docker-compose.yml` running Django (gunicorn) + Postgres + Nginx together. Neither exists yet — no `Dockerfile`, `docker-compose.yml`, or `project3/scripts/` deployment scripts found in the repo.
- [ ] Use **Postgres**, not `db.sqlite3` (present at `backend_new/db.sqlite3`, 401KB), for anything real — `DB_ENGINE` already defaults to `postgresql` in settings, just make sure the prod `.env` actually sets real Postgres credentials.

### 3. Backups
- [ ] Automated nightly database backup.
- [ ] **Actually restore one** at least once to prove the backup isn't corrupted.

### 4. Know when something breaks
- [ ] Add **Sentry** (missing from `requirements.txt`) to Django and to Flutter — tells you about crashes/errors automatically instead of waiting for an employee to complain.
- [ ] Add a `/health` endpoint and a free uptime monitor (e.g. UptimeRobot) that pings it.

### 5. Automate testing and releases
- [ ] `project3/test/widget_test.dart` is still the **untouched default Flutter counter-app template** — it asserts a `+` icon and `find.text('0')`/`'1'` that no longer exist in this app, so `flutter test` is almost certainly failing right now, not just "no coverage." Replace with real tests: login flow, one flow per role, and any new business logic (e.g. the internal olive-oil classification rules).
- [ ] No CI exists (`.github/workflows/` doesn't exist). Set up **GitHub Actions**: every push runs the test suite; nothing merges if tests fail.

### 6. Performance (only what you'll actually need)
- [ ] Check dashboard queries (CEO/chef) under realistic data volume — these are usually the slowest.
- [ ] Don't do anything beyond this until you actually see a slowdown.

#### 6b. Caching plan — ⏸️ DEFERRED, not yet decided

A caching strategy belongs in this document (not in `files/notifications/`, which is business logic only). **Decision deliberately postponed** — the call was: build the features first, decide caching once the app is complete and there's something real to measure. That is the correct order; caching an unfinished app optimises guesses.

Recorded here only so the intent isn't lost. When it's picked up, "cache" in this app means **three separate things** and they should be planned separately, each with its own invalidation rule:

| Layer | What it solves | Current state |
|---|---|---|
| **Offline local cache (mobile)** | The collector registers samples in the field with no network, syncs on reconnect. A real business requirement, not an optimisation — this is the one that matters. | Offline-first design is described in `CLAUDE.md`; not yet implemented against a real backend |
| **Image / media cache** | Avoids re-fetching and re-decoding sample photos and lab report images | `cached_network_image` is already a dependency — largely handled |
| **Backend query cache** (e.g. Redis) | CEO/chef dashboard aggregations — the only endpoints identified above as likely slow | Not present. Add **when measured**, per the rule directly above |

- [ ] Revisit once feature work is complete and dashboard timings under realistic volume exist.

**Never judge app performance from a debug build.** Everything tested during development (`flutter run`) is a debug build — JIT-compiled, full of assertions and debug metadata, typically 2-3x slower and significantly larger than what actually ships. Always evaluate real feel and size on a release build:
- [ ] Build with `flutter build apk --release` (or install the resulting APK directly) before judging startup time, jank, or size — debug-mode jank (e.g. "Skipped N frames" log warnings) is often not representative of the real thing.
- [ ] Run `flutter build apk --analyze-size` periodically to see what's actually contributing to binary size (dependencies, assets, fonts) and catch bloat before it accumulates.
- [ ] Release mode gets Flutter's AOT (ahead-of-time) compilation and dead-code elimination ("tree shaking") for free — no action needed, just don't let debug-mode numbers drive size/speed decisions.

**What actually causes jank (dropped frames):** real work happening on the UI thread during a frame — heavy JSON parsing, large synchronous list rebuilds, blocking file I/O. Since this app uses `setState()` everywhere (per repo convention, no Provider/Bloc), remember that `setState` rebuilds the whole widget subtree under it — keep the subtree it's called on as small/scoped as practical, especially on list-heavy screens (dashboards, échantillon lists).

**Already working in this app's favor, no action needed:**
- Impeller rendering backend is active (confirmed in device logs) — Flutter's newer renderer, smoother by default than the older Skia-only pipeline.
- `cached_network_image` is already a dependency — avoids re-fetching/re-decoding the same image repeatedly.
- The Collector module's offline-first design (per `CLAUDE.md`) means instant local response with sync-later, which is good for perceived performance regardless of network conditions in the field.

### 7. Security pass
- [ ] Check who can do what per role (who can confirm a purchase, refuse a sample, etc.) — real business consequences.
- [ ] Rate-limit the login endpoint (see settings, above).
- [ ] Run `pip-audit` to check for known vulnerabilities in dependencies.
- [ ] If any real secret (API key, password) was ever committed to git — rotate it, assume it's compromised. (Relevant here: `backend_new/.env` was tracked in git before an earlier "untrack venv/.env" commit — worth checking git history for any key that leaked during that window.)

### 8. App release readiness — `android/app/build.gradle.kts` and `lib/main.dart`
- [ ] **`applicationId`** (`build.gradle.kts:24`) is still the placeholder `com.example.project3` — must become a real reverse-domain ID before any real build ships, since it can't change later without becoming a "new app" to every install.
- [ ] **Release signing** (`build.gradle.kts:33-38`): release builds currently sign with the **debug keystore** — generate a real release keystore, add a gitignored `key.properties` + `signingConfigs.create("release")`. This keystore is the single highest-risk artifact in this whole plan (see Part 3) — if lost, the app can never be updated under the same identity again.
- [ ] **Debug login buttons** (`lib/main.dart:456-490`, `_debugBtn` helper at `512-525`): 5 buttons that bypass auth entirely, **not gated by `kDebugMode`** — they ship live in release builds today. Wrap the block in `if (kDebugMode) ...`.
- [ ] **Cleartext traffic** (`android/app/src/main/AndroidManifest.xml:8`, `android:usesCleartextTraffic="true"`): remove once the backend serves HTTPS.
- [ ] No ProGuard/R8 config exists explicitly (though `build/app/outputs/mapping/release/` shows Flutter's own default shrink already ran once) — add an explicit `proguard-rules.pro` so obfuscation is a controlled, versioned decision.
- [ ] `pubspec.yaml` version is `1.0.0+1` — fine as a starting point; pick a real versioning convention now since Firebase App Distribution's update flow depends on it.

### 9. Roll out carefully
- [ ] Pilot with a handful of real employees first (across different roles).
- [ ] Write a one-page runbook: how to deploy, how to roll back, how to restore a backup, who to contact if it's down.
- [ ] Then open it up to everyone.

---

## Part 2 — Getting it deployed and onto people's phones

Think of this as three separate problems:

> **Step 0: where does the code live?** (so anything below can actually happen)
> **Problem A: where does the API live?** (the server that Postgres/Django run on)
> **Problem B: how does an employee get the app on their phone?** (privately — no Play Store, no App Store)

### Step 0 — GitHub

Push both the Flutter app and the Django backend (`backend_new`) to a GitHub repo, if not already there. This is the single source of truth everything else in this section plugs into — Railway/Render deploy straight from it, and it's what makes rollbacks possible ("this version broke something, redeploy the previous commit").

### Problem A — Where the backend lives

**Recommended path — Railway or Render:** connect your GitHub repo, they build and run it automatically every time you push. One click adds a managed PostgreSQL database. A connected domain gets free automatic HTTPS — no manual certificate step. No server to patch, no Docker Compose file to maintain yourself. This is the easier, non-technical-friendly, industry-standard option, and it's the one to default to.

1. Create a Railway or Render account, connect it to the GitHub repo, point it at `backend_new`.
2. Add a PostgreSQL database from their dashboard (one click, no manual install).
3. Set environment variables in their dashboard: `SECRET_KEY`, `DEBUG=False`, `ALLOWED_HOSTS`, database credentials (usually auto-filled once you add their database).
4. Buy a domain (~$10/year, e.g. Namecheap), connect it in Railway/Render — HTTPS certificate is automatic.
5. Point the Flutter app at that URL. `lib/config.dart:6-9` already reads `kApiBaseUrl` from a compile-time environment variable (`String.fromEnvironment('API_BASE_URL', defaultValue: 'http://127.0.0.1:8000')`) — no code change needed, just build with `--dart-define=API_BASE_URL=https://api.yourcompany.tn`.

**Alternative — a self-managed VPS (Hetzner/DigitalOcean, ~$6–12/month) with Docker Compose + Nginx + Certbot (from Part 1, step 2):** more manual work (you patch and monitor the server yourself), but more control and marginally cheaper. Only worth it if there's a specific reason Railway/Render doesn't fit (e.g. a data-residency requirement). Default to Railway/Render unless there's a concrete reason not to.

**Decision record — why not Supabase:** Supabase bundles hosted Postgres with its own auto-generated API, auth, and storage — it's a replacement for the *whole* Django layer, not just the database. This backend already has 10 Django apps of real business logic and permission rules (`echantillons`, `evaluations`, `analyses`, `chef`, `ceo`, etc.) — moving to Supabase would mean rewriting all of that from scratch, not "swapping the database." Not worth it here. (Using only Supabase's hosted Postgres and pointing Django at it like any other database *would* work, but Railway/Render already provide that same convenience bundled with the hosting itself, for less total complexity.)

### Problem B — Getting the app onto phones without an app store

**Decision: Firebase App Distribution for both Android and iOS.** Not Play Console Internal Testing, not TestFlight — those still route through Google's/Apple's store infrastructure and require store developer accounts even for "private" tracks. Firebase App Distribution is a separate, purpose-built tool for exactly this: private, invite-only app delivery with proper update notifications, no store listing at all, ever.

**Setup:**
1. Create a Firebase project (owned by the company — see Part 3).
2. Add the Android app (using the real `applicationId` from Part 1, step 8) and the iOS app (with its bundle ID) to that project.
3. **Android:** `flutter build apk --release --dart-define=API_BASE_URL=https://api.yourcompany.tn`, signed with the real release keystore → upload to Firebase App Distribution.
4. **iOS:** still needs an Apple Developer Program account ($99/year, enrolled as an **Organization**) purely for code signing/provisioning — an ad-hoc provisioning profile + distribution certificate (good for up to 100 registered test devices; only worth the $299/year Enterprise Program if you exceed that). `flutter build ipa --release` with that profile → upload to Firebase App Distribution, same as Android.
5. Add employees as testers by email, grouped by role (e.g. a "dégustateurs" group, a "ceo" group). They get an email invite, install the small **Firebase App Tester** app once, and get this app plus every future update through it.

**The whole thing, start to finish:**
1. Push code to GitHub.
2. Connect Railway/Render to the repo → add PostgreSQL → set environment variables → connect domain (backend is now live at a real HTTPS URL, redeploying automatically on every push).
3. Create the Firebase project (company-owned) → add Android + iOS apps.
4. Build the release APK (and IPA, if iOS is in scope) → upload to Firebase App Distribution → invite employees by email.
5. Employees tap the invite, install the small Firebase tester app, then this app. No store search, no public listing, updates happen automatically.
6. Pilot with 2-3 real employees across different roles before opening it up to everyone.

**Rough cost for the first year:** Railway/Render's usage-based free/starter tier often covers small apps; budget ~$5-20/month once real usage kicks in, plus ~$10/year domain, plus $99/year Apple Developer account if iOS is included. Firebase App Distribution itself is free.

### A note on CI/CD

Connecting Railway/Render to GitHub (Step 0 + Problem A above) *is* basic CI/CD for the backend already — every push automatically tests-and-deploys, no extra setup. The one piece that's still manual is the Flutter side: building the release APK/IPA and uploading to Firebase App Distribution by hand. That can be automated later with GitHub Actions (push → auto-build → auto-upload to Firebase), but it's a "make repeat releases easier" nice-to-have, not something needed before the first real deployment — set it up once releases become routine, not before.

---

## Part 3 — What the company must own (not you)

A few of these steps create long-term legal, financial, or ownership relationships. If they're registered under your personal name/email/card instead of the company's, the company ends up permanently dependent on you personally — and can't easily take it back later. Split it like this:

| Thing | Must be owned by the **company**, because... |
|---|---|
| **GitHub repo/organization** | Should live under a company GitHub organization, not your personal account — otherwise the company's own codebase and deployment history depend on your personal account staying active and cooperative. |
| **Domain name** | Registrant should be the company (legal name + a company email), not your personal email. If you register it personally and later leave, they may lose control of their own API address. |
| **Firebase project** | Created under a company Google account/Workspace, not a personal one — this is what gates app distribution and tester management going forward. |
| **Apple Developer Program account** (iOS only) | Enrolled as an **Organization**, tied to the company's legal identity (needs a D-U-N-S number — a free business ID from Dun & Bradstreet, the company likely already has one or can get one free), with a company representative as the account holder. |
| **Server/hosting account** (Hetzner, DigitalOcean, Railway...) | Create it with a **company email and a company payment method**, not your personal one. If billing is on your card, the server can get shut off the moment you're unreachable or unpaid. |
| **Signing keys / certificates** (Android keystore, iOS signing certificate) | Must be **backed up somewhere the company controls** (e.g. a company password manager/vault). If lost, the app can **never be updated again** under the same identity — it would have to be republished as a brand-new app. This is the single highest-risk item on this list. |
| **Tester list** (Firebase App Distribution groups) | Whoever handles HR/onboarding at the company should own adding new employees and **removing people who leave** — an ongoing responsibility, not a one-time setup task. |
| **Data responsibility** | The company is legally the "owner" of the business data (supplier records, employee accounts, purchase decisions) regardless of who wrote the code — decisions like backup retention and who can see what data are theirs to sign off on. |

**What you (the developer) can reasonably own:** the code itself, the CI/CD pipeline, writing the Docker/Nginx config, uploading builds to Firebase App Distribution, and day-to-day maintenance — as long as the underlying *accounts* above belong to the company, not to you personally.

**Practical rule of thumb:** anywhere you'd type a credit card number or a legal business name during setup, stop and use the company's — even if it's more convenient to use your own to get started quickly.

---

## Note on the Spring Boot backend

A parallel Spring Boot rewrite (`spring_backend/`) was started but is incomplete (covers ~3 of 12 business areas), untracked in git, and has never been compiled (no Java/Maven/Docker installed on this machine to verify it). Decision: continue with the Django backend, which is already feature-complete and wired to the Flutter app. Revisit Spring Boot only if a concrete, specific reason to migrate comes up later — not as a general "might be better" rewrite.

## Note on the OCR feature — removed, now being revisited (2026-08-03)

The Azure Document Intelligence OCR integration (bottle-label / lab-report photo scanning) was removed from both the backend and the app. Credentials and reactivation notes are archived at `backend_new/.env.ocr-archive` (gitignored).

**Update:** lab-report scanning is being brought back, but **not** via Azure. The retained direction is **ML Kit on-device** — free, offline, no per-page cost, no document leaving the phone. It's viable here because the report is printed (not handwritten), the template is fixed, the field set is small and known, and the technician review before submit is mandatory — so extraction accuracy is a time-saver, not a correctness guarantee.

Full reasoning, alternatives considered, and open points: [`files/notifications/05_laboratoire.md`](../files/notifications/05_laboratoire.md).

Deployment consequences to track:
- Azure is **not** deleted — it stays behind a config flag in `lib/config.dart` as a fallback. No Azure subscription or credential is required to ship.
- ML Kit is **Android/iOS only**. It does not run on Flutter web — camera scanning is a mobile-only feature by design.
- Adds an on-device ML dependency: expect an **APK size increase**. Check it with `flutter build apk --analyze-size` (see §6) before and after.
- ⚠️ This note supersedes the earlier claim that OCR "is no longer part of this deployment plan". `files/role_laboratoire.md` (which always described the photo-extraction flow) is the accurate one.
