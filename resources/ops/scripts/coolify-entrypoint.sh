#!/usr/bin/env bash
# Coolify / production entrypoint for Gibbon.
# Persists config.php across redeploys via /var/gibbon-persist.

set -euo pipefail

PERSIST_DIR="${GIBBON_PERSIST_DIR:-/var/gibbon-persist}"
APP_DIR="${GIBBON_APP_DIR:-/var/www/html}"
PERSIST_CONFIG="${PERSIST_DIR}/config.php"
APP_CONFIG="${APP_DIR}/config.php"

mkdir -p "${PERSIST_DIR}" "${APP_DIR}/uploads"

# Keep an empty (or existing) config on the persistent volume and point the
# app root at it so the web installer can write through the symlink.
if [[ ! -e "${PERSIST_CONFIG}" ]]; then
    touch "${PERSIST_CONFIG}"
fi

ln -sfn "${PERSIST_CONFIG}" "${APP_CONFIG}"

chown -R www-data:www-data "${PERSIST_DIR}" "${APP_DIR}/uploads"
# Installer must be able to write config.php (via the symlink) and create uploads.
chown www-data:www-data "${APP_DIR}"
chmod 775 "${APP_DIR}" "${APP_DIR}/uploads" "${PERSIST_DIR}"
chmod 664 "${PERSIST_CONFIG}"

exec apache2-foreground
