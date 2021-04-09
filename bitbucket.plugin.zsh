#####################################################################
# Init
#####################################################################

export BITBUCKET_API_ENDPOINT="https://api.bitbucket.org/2.0"

function bitbucket-token () {
  local KEY=${1:-$BITBUCKET_KEY}
  local SECRET=${2:-$BITBUCKET_SECRET}

  curl \
    --user "$KEY:$SECRET" \
    --request POST \
    --url "https://bitbucket.org/site/oauth2/access_token" \
    --data "grant_type=client_credentials" \
    | jq ".access_token" -r
}

function bitbucket-del () {
  local PTH=""

  if [[ -n "${1}" ]]; then
    PTH="/${1}"
  fi

  curl --request DELETE \
       --silent \
       --header 'Accept: application/json' \
       --header "Authorization: Bearer $( bitbucket-token )" \
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
       --header "Authorization: Bearer $( bitbucket-token )" \
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
       --header "Authorization: Bearer $( bitbucket-token )" \
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
    'teams:Team based crud'
    'repositories:Repository based crud'
  )

  if (( CURRENT == 2 )); then
    _describe 'command' cmds
  elif (( CURRENT == 3 )); then
    case "$words[2]" in
      teams) subcmds=(
        'list:List all the teams'
        )
        _describe 'command' subcmds ;;
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

  teams
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

#####################################################################
# Teams
#####################################################################

function _bitbucket::teams () {
  (( $# > 0 && $+functions[_bitbucket::teams::$1] )) || {
    cat <<EOF
Usage: bitbucket teams <command> [options]

Available commands:

  list

EOF
    return 1
  }

  local command="$1"
  shift

  _bitbucket::teams::$command "$@"
}

function _bitbucket::teams::list () {

  local QRY="username=\"${1}\""
  bitbucket-get "teams" \
    "role=contributor&q=$( urlencode ${QRY} )&pagelen=300"

}

#####################################################################
# Repositories
#####################################################################

function _bitbucket::repositories () {
  (( $# > 0 && $+functions[_bitbucket::repositories::$1] )) || {
    cat <<EOF
Usage: bitbucket repositories <command> [options]

Available commands:

  list <team>

EOF
    return 1
  }

  local command="$1"
  shift

  _bitbucket::repositories::$command "$@"
}

function _bitbucket::repositories::list () {

  local QRY="owner.username=\"${1}\""
  bitbucket-get "repositories" \
    "role=contributor&q=$( urlencode ${QRY} )&pagelen=300"

}
