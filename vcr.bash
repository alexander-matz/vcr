
# vim: ts=2 sts=2 sw=2 et ai
__preexec () { :; }
__preexec_invoke_exec() {
  [[ -n "$COMP_LINE" ]] && return
  [[ "$__recording" != "yes" ]] && return
  [[ "$BASH_COMMAND" == "$PROMPT_COMMAND" ]] && return
  [[ "$BASH_COMMAND" == "vcr-"* ]] && return
  __record="${__record}${BASH_COMMAND}\n"
}

__records_dir="${HOME}/.vcr-records"
__recording=no
__record=''

vcr-record() {
  if [[ "$__recording" == "yes" ]]; then
    echo "[already recording]" >&2
    return 1
  fi
  __recording=yes
  echo "[recording...]" >&2
}

vcr-abort() {
  if [[ "$__recording" != "yes" ]]; then
    echo "[not currently recording]" >&2
    return 1
  fi
  __recording=no
  __record=""
  echo "[aborted record]" >&2
}
 
vcr-recording() {
  if [[ "$__recording" == "yes" ]]; then
    echo "[recording is in process]" >&2
  else
    echo "[not currently recording]" >&2
  fi
}

vcr-label() {
  if [[ "$__recording" != "yes" ]]; then
    echo "[not currently recording]" >&2
    return 1
  fi
  if [[ $# -ne 1 ]]; then
    echo "[usage: vcr-label <label>]" >&2
    return 1
  fi
  [[ -d "$__records_dir" ]] || mkdir "$__records_dir"
  echo -e -n "${__record}" > "$__records_dir/$1"
  __recording=no
  __record=""
  echo "[stored record under label '$1']" >&2
}

vcr-list() {
  echo "[available records:]" >&2
  [[ -d "$__records_dir" ]] || return
  for record in "$__records_dir"/*; do
    echo "  [$(basename $record)]" >&2
  done
}

vcr-delete() {
  if [[ $# -ne 1 ]]; then
    echo "[usage: vcr-delete <label>]" >&2
    return 1
  fi
  if [[ ! -f "$__records_dir/$1" ]]; then
    echo "[no such record: '$1']" >&2
    return 1
  fi
  rm -f "$__records_dir/$1"
}

vcr-clear() {
  read -p "[all records will be deleted, proceeds (yes/No)?] " >&2
  if [[ "$REPLY" == "yes" ]]; then
    echo "[deleting all records]" >&2
    rm -rf "$__records_dir"
  fi
}

vcr-show() {
  if [[ "$__recording" == "yes" ]]; then
    echo "[recording in process]" >&2
    return 1
  fi
  if [[ $# -ne 1 ]]; then
    echo "[usage: vcr-show <label>]" >&2
    return 1
  fi
  if [[ ! -f "$__records_dir/$1" ]]; then
    echo "[no such record: '$1']" >&2
    return 1
  fi
  echo "[record contents:]"
  cat "$__records_dir/$1" | sed "s/^/$ /g"
}

vcr-play() {
  if [[ "$__recording" == "yes" ]]; then
    echo "[recording in process]" >&2
    return 1
  fi
  if [[ $# -ne 1 ]]; then
    echo "usage: vcr-play <label>" >&2
    return 1
  fi
  if [[ ! -f "$__records_dir/$1" ]]; then
    echo "no such record: '$1'" >&2
    return 1
  fi
  echo "[playing record...]" >&2
  . "$__records_dir/$1"
  echo "[done]" >&2
}

trap '__preexec_invoke_exec' DEBUG

__record_complete() {
  local cur=${COMP_WORDS[COMP_CWORD]}
  local files
  [[ -d "$__records_dir" ]] && files="$(ls "$__records_dir" | grep "^$cur")"
  COMPREPLY=( $(compgen -W "$files" -- $cur) )
}
complete -F __record_complete vcr-play
complete -F __record_complete vcr-show
complete -F __record_complete vcr-delete
