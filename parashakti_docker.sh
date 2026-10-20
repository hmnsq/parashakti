#!/usr/bin/env bash
# parashakti_docker.sh: run Parashakti inside a container that has every tool it needs, so nothing is installed on this
# machine. Built on the Ubuntu sandbox script: the same GitHub and Zenodo hand-off, read-only Documents, and checks first.
#   bash parashakti_docker.sh                         a shell in the container, with parashakti ready
#   bash parashakti_docker.sh --fork-all --publish    run Parashakti in the container with these arguments
# Work is kept in ./parashakti-work beside this script (clones, builds, models, the report), so a run can be resumed.
# Why the sandbox exited: when gh keeps its login in the system keyring, hosts.yml holds no token, so `gh auth status`
# failed inside the container and `set -e` ended it. The token is now passed in as GH_TOKEN instead.
# © 1993–2026 Abhishek Choudhary. All rights reserved. AyeAI.
set -uo pipefail
IMAGE="${PARASHAKTI_BASE:-ubuntu:26.04}"; TAGGED="parashakti-env:${IMAGE#*:}"
HERE="$(cd "$(dirname "$0")" && pwd)"; WORK="$HERE/parashakti-work"; DOCS="$HOME/Documents"
mkdir -p "$WORK"; [ -f "$HERE/parashakti.sh" ] && cp "$HERE/parashakti.sh" "$WORK/parashakti.sh"
say() { printf '%s\n' "$*"; }

say "==> Docker"; command -v docker >/dev/null || { say "Docker is not installed."; exit 1; }
docker info >/dev/null 2>&1 || { say "The Docker daemon is not running, or this user cannot reach it."; exit 1; }
say "==> GitHub"
TOKEN="$(gh auth token 2>/dev/null)"
[ -n "$TOKEN" ] && say "   token handed to the container (gh auth token)" || say "   gh is not logged in here: publishing will not work inside (gh auth login first)"
ZEN=""; [ -f "$DOCS/zenodo_token_20260612" ] && ZEN="$(cat "$DOCS/zenodo_token_20260612")" && say "   ZENODO_TOKEN handed over"

if ! docker image inspect "$TAGGED" >/dev/null 2>&1; then
  say "==> building $TAGGED once (every tool Parashakti needs; later runs start at once)"
  docker build -t "$TAGGED" - <<EOF || { say "the image did not build"; exit 1; }
FROM $IMAGE
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq && apt-get install -y -qq git python3 python3-pip gcc g++ make flex bison gawk bc cmake ninja-build wabt \\
    gcc-riscv64-linux-gnu gcc-riscv64-unknown-elf qemu-system-misc qemu-system-x86 tmux htop curl ca-certificates gh nasm \\
    gcc-multilib sudo >/dev/null && rm -rf /var/lib/apt/lists/*
RUN pip install -q --break-system-packages misty-doi opentimestamps-client || true
WORKDIR /root/work
EOF
fi

GPU=(); docker info 2>/dev/null | grep -qi nvidia && GPU=(--gpus all) && say "==> the GPU is passed to the container"
say "==> starting Parashakti's container (work in $WORK)"
ARGS=("$@")
docker run -it --rm "${GPU[@]}" \
  -e GH_TOKEN="$TOKEN" -e ZENODO_TOKEN="$ZEN" -e TERM="${TERM:-xterm-256color}" \
  --mount "type=bind,src=$WORK,dst=/root/work" \
  $( [ -d "$DOCS" ] && echo "--mount type=bind,src=$DOCS,dst=/root/Documents,readonly" ) \
  "$TAGGED" bash -c '
    gh auth status >/dev/null 2>&1 && echo "   GitHub: logged in as $(gh api user --jq .login 2>/dev/null)" || echo "   GitHub: not logged in (publishing will not work)"
    git config --global user.name "Abhishek Choudhary"; git config --global user.email "obonac@users.noreply.github.com"
    gh auth setup-git >/dev/null 2>&1
    if [ $# -gt 0 ]; then exec bash /root/work/parashakti.sh "$@"; fi
    echo; echo "Parashakti is ready: bash parashakti.sh --check, then bash parashakti.sh ..."; exec bash' _ "${ARGS[@]}"
