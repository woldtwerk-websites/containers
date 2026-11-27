#!/bin/sh
set -eu

# The host file is read-only; tamer rewrites /app/config.yaml after a sign-in
cp /etc/tamer/config.yaml /app/config.yaml

# The example config ships this placeholder; running with it would accept the
# literal string as the proxy's bearer key
if grep -q 'REPLACE_ME' /app/config.yaml; then
  echo "lumo-tamer: set server.apiKey in ~/.config/lumo-tamer/config.yaml" >&2
  exit 1
fi

# The server refuses to start without a vault, but the container has to stay up
# long enough for `tamer auth login` to create one
if [ ! -s /app/sessions/vault.enc ]; then
  echo "lumo-tamer: no Proton session yet, waiting for sign-in:" >&2
  echo "  podman exec -it lumo-tamer tamer auth login" >&2
  echo "  systemctl --user restart lumo-tamer" >&2
  while :; do sleep 3600; done
fi

exec tamer server
