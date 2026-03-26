#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

NODE_VERSION="${MARKTEXT_NODE_VERSION:-20.18.0}"
BUILD_SCRIPT="${MARKTEXT_BUILD_SCRIPT:-build:bin}"
APP_INSTALL_DIR="${MARKTEXT_APPLICATION_DIR:-/Applications}"
CLI_NAME="${MARKTEXT_CLI_NAME:-mark}"

use_supported_node() {
  local current_version
  current_version="$(node -v 2>/dev/null || true)"

  case "$current_version" in
    v16.*|v20.*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  # shellcheck disable=SC1090
  source "$HOME/.nvm/nvm.sh"

  if ! nvm use "$NODE_VERSION" >/dev/null 2>&1; then
    if use_supported_node; then
      echo "warning: nvm node $NODE_VERSION is not installed, using $(node -v)" >&2
    else
      echo "error: nvm node $NODE_VERSION is not installed." >&2
      echo "install it with: nvm install $NODE_VERSION" >&2
      exit 1
    fi
  fi
elif ! use_supported_node; then
  echo "error: unsupported node version: $(node -v 2>/dev/null || echo missing)" >&2
  echo "use Node 16.x or 20.x, or install nvm node $NODE_VERSION." >&2
  exit 1
fi

if ! command -v yarn >/dev/null 2>&1; then
  echo "error: yarn is required but was not found in PATH." >&2
  exit 1
fi

find_latest_app_bundle() {
  local app_bundle=""
  local latest_mtime=0
  local candidate
  local candidate_mtime

  while IFS= read -r -d '' candidate; do
    candidate_mtime="$(stat -f '%m' "$candidate")"
    if (( candidate_mtime > latest_mtime )); then
      latest_mtime="$candidate_mtime"
      app_bundle="$candidate"
    fi
  done < <(find "$ROOT_DIR/build" -maxdepth 3 -type d -name '*.app' -print0 2>/dev/null)

  if [[ -n "$app_bundle" ]]; then
    printf '%s\n' "$app_bundle"
  fi
}

copy_latest_app_bundle() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    return 0
  fi

  local latest_app
  latest_app="$(find_latest_app_bundle)"
  if [[ -z "$latest_app" ]]; then
    echo "warning: no app bundle found under build/, skipping Applications copy." >&2
    return 0
  fi

  local install_dir="$APP_INSTALL_DIR"
  if [[ ! -d "$install_dir" ]]; then
    mkdir -p "$install_dir" 2>/dev/null || true
  fi

  if [[ ! -w "$install_dir" ]]; then
    local fallback_install_dir="$HOME/Applications"
    mkdir -p "$fallback_install_dir"
    if [[ -w "$fallback_install_dir" ]]; then
      echo "warning: $install_dir is not writable, copying to $fallback_install_dir instead." >&2
      install_dir="$fallback_install_dir"
    else
      echo "warning: cannot write to $install_dir or $fallback_install_dir, skipping Applications copy." >&2
      return 0
    fi
  fi

  local dest_app="$install_dir/$(basename "$latest_app")"
  echo "Copying $(basename "$latest_app") to $dest_app" >&2

  if command -v rsync >/dev/null 2>&1; then
    mkdir -p "$dest_app"
    rsync -a --delete "$latest_app/" "$dest_app/"
  else
    rm -rf "$dest_app"
    ditto "$latest_app" "$dest_app"
  fi

  printf '%s\n' "$dest_app"
}

resolve_cli_install_path() {
  local cli_path="${MARKTEXT_CLI_PATH:-}"
  if [[ -n "$cli_path" ]]; then
    printf '%s\n' "$cli_path"
    return 0
  fi

  local preferred_dirs=(
    "/usr/local/bin"
    "/opt/homebrew/bin"
    "$HOME/.local/bin"
  )
  local dir

  for dir in "${preferred_dirs[@]}"; do
    if [[ -d "$dir" ]]; then
      if [[ -w "$dir" ]]; then
        printf '%s/%s\n' "$dir" "$CLI_NAME"
        return 0
      fi
      continue
    fi

    if mkdir -p "$dir" 2>/dev/null; then
      printf '%s/%s\n' "$dir" "$CLI_NAME"
      return 0
    fi
  done

  return 1
}

install_cli_shim() {
  local app_bundle_path="${1:-}"
  if [[ "$(uname -s)" != "Darwin" || -z "$app_bundle_path" ]]; then
    return 0
  fi

  local cli_path
  if ! cli_path="$(resolve_cli_install_path)"; then
    echo "warning: could not find a writable location for the $CLI_NAME command." >&2
    return 0
  fi

  local cli_dir
  cli_dir="$(dirname "$cli_path")"
  mkdir -p "$cli_dir"

  cat > "$cli_path" <<EOF
#!/usr/bin/env bash
exec "$app_bundle_path/Contents/MacOS/MarkText" "\$@"
EOF
  chmod +x "$cli_path"

  echo "Installed CLI command: $cli_path"

  case ":$PATH:" in
    *":$cli_dir:"*)
      ;;
    *)
      echo "warning: $cli_dir is not in PATH. Add it to your shell config to use '$CLI_NAME' directly." >&2
      ;;
  esac
}

# Work around keytar/node-gyp failures on newer macOS + toolchain combinations.
export GYP_DEFINES="${GYP_DEFINES:+$GYP_DEFINES }openssl_fips="

# Keep local packaging unsigned unless the caller opts in.
export CSC_IDENTITY_AUTO_DISCOVERY="${CSC_IDENTITY_AUTO_DISCOVERY:-false}"

echo "Using node $(node -v)"
echo "Running yarn run $BUILD_SCRIPT"

yarn run "$BUILD_SCRIPT"
installed_app_bundle="$(copy_latest_app_bundle)"
install_cli_shim "$installed_app_bundle"
