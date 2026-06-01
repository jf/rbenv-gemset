# dont bother carrying on if `rbenv version` is "system"; the codebase has not supported this for a long time now!
[[ $RBENV_VERSION = "system" ]] && return

# EARLY RETURN #2: no gemset file = no work to do!
_rbenv_gemsets_file="$( rbenv-gemset-file 2>/dev/null )"
[[ -z $_rbenv_gemsets_file ]] && return

_rbenv_gemsets_container="$( rbenv-prefix )/gemsets"
_project_dir=${_rbenv_gemsets_file%/*}

OLDIFS="$IFS"
IFS=$' \t\n'
for gemset in $( _rbenv_gemsets_file=$_rbenv_gemsets_file rbenv-gemset-active 2>/dev/null ); do
  if [[ $gemset =~ ^\..+ ]]; then
    command="$_project_dir/$gemset/bin/$RBENV_COMMAND"
    if [ -x "$command" ]; then
      RBENV_COMMAND_PATH="$command"
      break
    fi
  else
    command="$_rbenv_gemsets_container/$gemset/bin/$RBENV_COMMAND"
    if [ -x "$command" ]; then
      RBENV_COMMAND_PATH="$command"
      break
    fi
  fi
done
IFS="$OLDIFS"
