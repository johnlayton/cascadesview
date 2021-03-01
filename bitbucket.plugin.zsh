#####################################################################
# Init
#####################################################################

export BITBUCKET_API_ENDPOINT="https://api.bitbucket.org/2.0"

function bitbucket-del () {
  local PTH=""

  if [[ -n "${1}" ]]; then
    PTH="/${1}"
  fi

  curl --request DELETE \
       --silent \
       --header 'Accept: application/json' \
       --header "Authorization: Bearer ${bitbucket_TOKEN}" \
       "${BITBUCKET_API_ENDPOINT}${PTH}"
}

function bitbucket-get () {
  local PTH="" #${1:-""}
  local QRY="" #${2:-""}

  if [[ -n "${1}" ]]; then
    PTH="/${1}"
  fi

  if [[ -n "${2}" ]]; then
    QRY="?${2}"
  fi

  curl --request GET \
       --silent \
       --header 'Accept: application/json' \
       --header "Authorization: Bearer ${bitbucket_TOKEN}" \
       "${BITBUCKET_API_ENDPOINT}${PTH}${QRY}"
}

function bitbucket-post () {
  local PTH=${1:-""}
  local DTA=${2:-"{}"}

  if [[ -n "${1}" ]]; then
    PTH="/${1}"
  fi

  curl --request POST \
       --silent \
       --header 'Content-type: application/json' \
       --header 'Accept: application/json' \
       --header "Authorization: Bearer ${bitbucket_TOKEN}" \
       --data $DTA \
       "${BITBUCKET_API_ENDPOINT}${PTH}"
}

function bitbucket () {
  [[ $# -gt 0 ]] || {
    _bitbucket::help
    return 1
  }

  local command="$1"
  shift

  (( $+functions[_bitbucket::$command] )) || {
    _bitbucket::help
    return 1
  }

  _bitbucket::$command "$@"
}

function _bitbucket {
  local -a cmds subcmds
  cmds=(
    'help:Usage information'
    'init:Initialisation information'
  )

  if (( CURRENT == 2 )); then
    _describe 'command' cmds
  elif (( CURRENT == 3 )); then
    case "$words[2]" in
      repositories) subcmds=(
        'list:List all the repositories'
        )
        _describe 'command' subcmds ;;
    esac
  fi

  return 0
}

compdef _bitbucket bitbucket

function _bitbucket::help {
    cat <<EOF
Usage: bitbucket <command> [options]

Available commands:

  repositories

EOF
}

function _bitbucket::init {
  if [ -n "${BITBUCKET_SECRET}" ] && [ -n "${BITBUCKET_KEY}" ]; then
    echo "============================================="
    echo "Current OAuth Consumer"
    echo "BITBUCKET_KEY ..... ${BITBUCKET_KEY}"
    echo "BITBUCKET_SECRET .. ${BITBUCKET_SECRET}"
    echo "============================================="
  else
    echo "============================================="
    echo "Create a new OAuth Consumer"
    echo "BITBUCKET_KEY=<Key>"
    echo "BITBUCKET_SECRET=<Secret>"
    echo "============================================="
    open "https://bitbucket.org/${USER}/workspace/settings/api"
  fi
}

