#!/bin/sh
set -eu

SERVICE_NAME="${DOCKER_SERVER_SERVICE:-docker_server}"

usage() {
  cat <<EOF
Usage: $0 [--force] [--no-volumes]

Prunes unused Docker objects inside the Docker DinD compose service (${SERVICE_NAME}).

Options:
  -f, --force    Skip the confirmation prompt.
  --no-volumes   Preserve unused Docker volumes inside the DinD server.
  --volumes      Include unused Docker volumes. This is the default.
  -h, --help     Show this help text.
EOF
}

force=false
include_volumes=true

while [ "$#" -gt 0 ]; do
  case "$1" in
    -f|--force)
      force=true
      ;;
    --volumes)
      include_volumes=true
      ;;
    --no-volumes)
      include_volumes=false
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac

  shift
done

cd "$(dirname "$0")"

if docker compose version >/dev/null 2>&1; then
  compose() {
    docker compose "$@"
  }
elif command -v docker-compose >/dev/null 2>&1; then
  compose() {
    docker-compose "$@"
  }
else
  echo "Error: neither 'docker compose' nor 'docker-compose' is available." >&2
  exit 1
fi

dind_docker() {
  compose exec -T "${SERVICE_NAME}" docker "$@"
}

if [ "${force}" != true ]; then
  if [ "${include_volumes}" = true ]; then
    echo "This will prune unused containers, networks, images, build cache, and volumes inside '${SERVICE_NAME}'."
    echo "Unused Docker volumes inside '${SERVICE_NAME}' will be deleted."
  else
    echo "This will prune unused containers, networks, images, and build cache inside '${SERVICE_NAME}'."
    echo "Unused Docker volumes inside '${SERVICE_NAME}' will be preserved."
  fi

  printf 'Type "prune" to continue: '
  if ! read -r answer; then
    echo
    echo "Aborted."
    exit 1
  fi

  if [ "${answer}" != prune ]; then
    echo "Aborted."
    exit 0
  fi
fi

echo "Checking Docker daemon inside '${SERVICE_NAME}'..."
dind_docker info >/dev/null

echo
echo "Docker disk usage before prune:"
dind_docker system df

echo
echo "Pruning unused containers, networks, images, and build cache..."
dind_docker system prune --all --force

echo
echo "Pruning builder cache..."
dind_docker builder prune --all --force

if [ "${include_volumes}" = true ]; then
  echo
  echo "Pruning unused volumes..."
  dind_docker volume prune --force
fi

echo
echo "Docker disk usage after prune:"
dind_docker system df
