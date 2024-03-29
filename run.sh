#!/usr/bin/env bash
set -e -u -o pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
PROJ="$DIR/.."

# Allow overriding the name of the docker image to use in the compose env.
export DOCKER_IMAGE="${DOCKER_IMAGE:-kpireporter/kpireporter}"
export DOCKER_TAG="${DOCKER_TAG:-edge}"
export PYTHON_VERSION=${PYTHON_VERSION:-3.8}

pushd "$DIR" >/dev/null

usage() {
  cat <<USAGE
Usage: run.sh [-h] [--no-rebuild] [--watch] ARGS

Run a report against a local development Docker-Compose stack, with most
services mocked for testing. Good for exploring examples and playing with
output formatting. ARGS are passed on to the kpireport script.

When the local development stack is running, the following services are
available:

  - MailHog (SMTP preview): localhost:8025
  - Nginx (HTTP preview): localhost:8080

Options:
  -h|--help: Prints this help message
  --no-rebuild: Skip a full rebuild of the Docker-Compose stack
  -w|--watch: Automatically re-run on changes
  --shell: Open an interactive shell within the composed environment

Examples:
  ./run.sh -c examples/mysql.yaml

  ./run.sh -w -c examples/mysql.yaml -c examples/outputs/smtp.yaml
USAGE
  exit 1
}

_dockercompose() {
  docker-compose -p kpireport "$@"
}

log() {
  echo "$@" >&2
}

log_step() {
  for _ in {1..80}; do printf "*" >&2; done
  log
  log "$@"
  for _ in {1..80}; do printf "*" >&2; done
  log
}

log_and_run() {
  log "+ Executing: $@"
  "$@"
}

REBUILD=1
WATCH=0
SHELL=0
BINARY=kpireport
declare -a POSARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-rebuild)
      REBUILD=0
      ;;
    -w|--watch)
      WATCH=1
      ;;
    --shell)
      SHELL=1
      ;;
    -h|--help)
      usage
      ;;
    explorer)
      BINARY=explorer
      ;;
    *)
      POSARGS+=("$1")
      ;;
  esac
  shift
done

mkdir -p "$PROJ/_build"
if [ ! -f "$DIR/.env" ]; then
  cp "$DIR/.env.sample" "$DIR/.env"
fi

declare -a stack_args=(--quiet-pull -d)
if [[ $REBUILD -eq 1 ]]; then
  stack_args+=(--force-recreate)
fi

log_step "Regenerating fixture data ..."
python -m fixtures
log "Done"

log_step "Starting docker-compose stack ..."
_dockercompose up "${stack_args[@]}" || true
log "Done"

log_step "Waiting for datasources to finish initializing ..."
_dockercompose run waiter mysql:3306 -t 60

log_step "Running command '$BINARY ${POSARGS[@]}' ..."
_dockercompose run --service-ports \
  -e KPIREPORT_USER="$(id -u)" \
  -e KPIREPORT_WATCH="$WATCH" \
  -e KPIREPORT_SHELL="$SHELL" \
  "$BINARY" "${POSARGS[@]}"
