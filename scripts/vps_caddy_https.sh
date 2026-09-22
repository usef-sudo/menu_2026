#!/bin/bash
# Run on the VPS as root. Puts Caddy TLS in front of Node :8000.
set -euo pipefail
HOST="169.58.151.217.sslip.io"
API_DIR="/opt/menu_jo_backend"
OLD_ORIGIN="http://169.58.151.217:8000"
NEW_ORIGIN="https://${HOST}"

echo "=== 1. packages ==="
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
if ! command -v caddy >/dev/null 2>&1; then
  apt-get install -y -qq caddy
fi
command -v caddy
caddy version || true

echo "=== 2. Caddyfile ==="
cat > /etc/caddy/Caddyfile <<EOF
{
	email yousefalnajjar444@gmail.com
}

${HOST} {
	reverse_proxy 127.0.0.1:8000
}
EOF
caddy validate --config /etc/caddy/Caddyfile
systemctl enable caddy
systemctl restart caddy
sleep 2
systemctl is-active caddy

echo "=== 3. config.env PUBLIC_BASE_URL + CORS ==="
python3 - <<'PY'
from pathlib import Path
p = Path("/opt/menu_jo_backend/config.env")
text = p.read_text()
lines = text.splitlines()
out = []
seen_pub = seen_cors = False
for line in lines:
    if line.startswith("PUBLIC_BASE_URL="):
        out.append("PUBLIC_BASE_URL=https://169.58.151.217.sslip.io")
        seen_pub = True
    elif line.startswith("CORS_ORIGINS="):
        out.append(
            "CORS_ORIGINS=https://menu-78832.web.app,https://menu-78832.firebaseapp.com"
        )
        seen_cors = True
    else:
        out.append(line)
if not seen_pub:
    out.append("PUBLIC_BASE_URL=https://169.58.151.217.sslip.io")
if not seen_cors:
    out.append(
        "CORS_ORIGINS=https://menu-78832.web.app,https://menu-78832.firebaseapp.com"
    )
p.write_text("\n".join(out) + "\n")
print("config.env PUBLIC_BASE_URL/CORS_ORIGINS updated")
PY

echo "=== 4. trust proxy in dist (no git commit) ==="
python3 - <<'PY'
from pathlib import Path
needle = 'const app = (0, express_1.default)();'
insert = needle + '\napp.set("trust proxy", 1);'
for rel in ("dist/app.js", "src/app.ts"):
    p = Path("/opt/menu_jo_backend") / rel
    if not p.exists():
        print(f"skip missing {rel}")
        continue
    t = p.read_text()
    if "trust proxy" in t:
        print(f"{rel} already has trust proxy")
        continue
    if rel.endswith(".js") and needle in t:
        p.write_text(t.replace(needle, insert, 1))
        print(f"patched {rel}")
    elif rel.endswith(".ts") and "const app: Application = express();" in t:
        p.write_text(
            t.replace(
                "const app: Application = express();",
                'const app: Application = express();\n\n// Caddy (and any TLS terminator) sits in front; honor X-Forwarded-For for rate limits.\napp.set("trust proxy", 1);',
                1,
            )
        )
        print(f"patched {rel}")
    else:
        print(f"WARN: could not patch {rel}")
PY

echo "=== 5. rewrite stored HTTP media URLs ==="
python3 - <<'PY'
import subprocess
from pathlib import Path

env = {}
for line in Path("/opt/menu_jo_backend/config.env").read_text().splitlines():
    raw = line.strip()
    if not raw or raw.startswith("#") or "=" not in raw:
        continue
    k, v = raw.split("=", 1)
    env[k] = v
url = env.get("DATABASE_URL")
if not url:
    raise SystemExit("DATABASE_URL missing")
sql = """
UPDATE restaurants SET logo_url = replace(logo_url, 'http://169.58.151.217:8000', 'https://169.58.151.217.sslip.io')
  WHERE logo_url LIKE 'http://169.58.151.217:8000%';
UPDATE restaurant_photos SET image_url = replace(image_url, 'http://169.58.151.217:8000', 'https://169.58.151.217.sslip.io')
  WHERE image_url LIKE 'http://169.58.151.217:8000%';
UPDATE menu_images SET image_url = replace(image_url, 'http://169.58.151.217:8000', 'https://169.58.151.217.sslip.io')
  WHERE image_url LIKE 'http://169.58.151.217:8000%';
UPDATE categories SET image_url = replace(image_url, 'http://169.58.151.217:8000', 'https://169.58.151.217.sslip.io')
  WHERE image_url LIKE 'http://169.58.151.217:8000%';
UPDATE offers SET image_url = replace(image_url, 'http://169.58.151.217:8000', 'https://169.58.151.217.sslip.io')
  WHERE image_url LIKE 'http://169.58.151.217:8000%';
SELECT 'restaurants' AS t, count(*) FROM restaurants WHERE logo_url LIKE 'https://169.58.151.217.sslip.io%'
UNION ALL SELECT 'restaurant_photos', count(*) FROM restaurant_photos WHERE image_url LIKE 'https://169.58.151.217.sslip.io%'
UNION ALL SELECT 'menu_images', count(*) FROM menu_images WHERE image_url LIKE 'https://169.58.151.217.sslip.io%'
UNION ALL SELECT 'categories', count(*) FROM categories WHERE image_url LIKE 'https://169.58.151.217.sslip.io%'
UNION ALL SELECT 'offers', count(*) FROM offers WHERE image_url LIKE 'https://169.58.151.217.sslip.io%';
"""
r = subprocess.run(["psql", url, "-v", "ON_ERROR_STOP=1", "-c", sql], check=False)
print("psql_exit", r.returncode)
if r.returncode != 0:
    raise SystemExit("psql rewrite failed")
PY

echo "=== 6. restart API ==="
systemctl restart menu-api
sleep 2
systemctl is-active menu-api
curl -fsS http://127.0.0.1:8000/api/health/ready || true
echo

echo "=== 7. wait for TLS (up to ~90s) ==="
ok=0
for i in $(seq 1 18); do
  if curl -fsS --max-time 10 "https://${HOST}/api/health/ready" >/tmp/health_https.json 2>/tmp/health_https.err; then
    echo "HTTPS OK on attempt $i"
    cat /tmp/health_https.json; echo
    ok=1
    break
  fi
  echo "attempt $i failed: $(tr '\n' ' ' < /tmp/health_https.err | tail -c 200)"
  sleep 5
done
if [[ "$ok" != 1 ]]; then
  echo "HTTPS not ready. Caddy status / logs:"
  systemctl status caddy --no-pager -l | head -n 40 || true
  journalctl -u caddy -n 80 --no-pager || true
  ss -tlnp | grep -E ':80|:443|:8000' || true
  exit 1
fi

echo "=== 8. CORS preflight sample ==="
curl -sS -D - -o /dev/null -X OPTIONS "https://${HOST}/api/health/ready" \
  -H "Origin: https://menu-78832.web.app" \
  -H "Access-Control-Request-Method: GET" | head -n 30

echo CADDY_SETUP_DONE
