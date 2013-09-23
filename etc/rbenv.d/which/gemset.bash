if [ "$(rbenv-version-name)" = "system" ]; then
  RBENV_GEMSET_ROOT="$RBENV_GEMSET_SYSTEM_ROOT"
else
  RBENV_GEMSET_ROOT="$(rbenv-prefix)/gemsets"
fi

RBENV_GEMSET_DIR="$(dirname "$(rbenv-gemset file 2>/dev/null)" 2>/dev/null)"
project_gemset='\..+'
OLDIFS="$IFS"
IFS=$' \t\n'
for gemset in $(rbenv-gemset active 2>/dev/null); do
  if [[ $gemset =~ $project_gemset ]]; then
    command="${RBENV_GEMSET_DIR}/${gemset}/bin/$RBENV_COMMAND"
    if [ -x "$command" ]; then
      RBENV_COMMAND_PATH="$command"
      break
    fi
  else
    command="${RBENV_GEMSET_ROOT}/${gemset}/bin/$RBENV_COMMAND"
    if [ -x "$command" ]; then
      RBENV_COMMAND_PATH="$command"
      break
    fi
  fi
done
IFS="$OLDIFS"
