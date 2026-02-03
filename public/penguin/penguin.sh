# penguin - forked beads binary for openclaw directory
# Uses ~/go/bin/bd (built from ~/code/penguin) instead of Homebrew bd
# Named build flags (--retro, --dev, etc.) switch to alternate binaries
# Builds config: ~/.openclaw/builds.conf (name=path, one per line)
declare -A penguin_builds=()
_penguin_builds_conf="$HOME/.openclaw/builds.conf"
# Load builds from config file
if [[ -f "$_penguin_builds_conf" ]]; then
  while IFS='=' read -r name path; do
    [[ -z "$name" || "$name" == \#* ]] && continue
    penguin_builds[$name]="$path"
  done < "$_penguin_builds_conf"
fi
_penguin_save_builds() {
  mkdir -p "${_penguin_builds_conf:h}"
  : > "$_penguin_builds_conf"
  for name in "${(@k)penguin_builds}"; do
    echo "${name}=${penguin_builds[$name]}" >> "$_penguin_builds_conf"
  done
}
penguin() {
  local beads_dir="$HOME/.openclaw"
  local penguin_bd="$HOME/go/bin/bd"

  # Intercept 'build' subcommand
  if [[ "$1" == "build" ]]; then
    local action="$2"
    case "$action" in
      set)
        if [[ -z "$3" || -z "$4" ]]; then
          echo "Usage: penguin build set <name> <path>" >&2
          return 1
        fi
        penguin_builds[$3]="$4"
        _penguin_save_builds
        echo "Build '$3' set to $4"
        ;;
      unset)
        if [[ -z "$3" ]]; then
          echo "Usage: penguin build unset <name>" >&2
          return 1
        fi
        if [[ -z "${penguin_builds[$3]+x}" ]]; then
          echo "Build '$3' not found" >&2
          return 1
        fi
        unset "penguin_builds[$3]"
        _penguin_save_builds
        echo "Build '$3' removed"
        ;;
      list)
        if [[ ${#penguin_builds} -eq 0 ]]; then
          echo "No builds registered"
        else
          for name in "${(@k)penguin_builds}"; do
            echo "$name=${penguin_builds[$name]}"
          done
        fi
        ;;
      *)
        echo "Usage: penguin build {set|unset|list}" >&2
        echo "  set <name> <path>   Register a named build" >&2
        echo "  unset <name>        Remove a named build" >&2
        echo "  list                Show all registered builds" >&2
        return 1
        ;;
    esac
    return
  fi

  # Check for named build flags (--retro, etc.) and strip from args
  local args=()
  for arg in "$@"; do
    local flag="${arg#--}"
    if [[ "$arg" == --* ]] && [[ -n "${penguin_builds[$flag]+x}" ]]; then
      penguin_bd="${penguin_builds[$flag]}"
    else
      args+=("$arg")
    fi
  done

  # Check if this is a help request
  if [[ "${args[*]}" == *"--help"* ]] || [[ "${args[*]}" == *"-h"* ]] || [[ "${args[1]}" == "help" ]] || [[ ${#args[@]} -eq 0 ]]; then
    (cd "$beads_dir" && "$penguin_bd" "${args[@]}") 2>&1 | perl -pe 's/\bbd\b/penguin/g'
  else
    (cd "$beads_dir" && "$penguin_bd" "${args[@]}")
  fi
}
