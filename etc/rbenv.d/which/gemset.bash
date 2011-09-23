if [ "$(rbenv-version-name)" = "system" ]; then
  RBENV_GEMSET_ROOT="$RBENV_GEMSET_SYSTEM_ROOT"
else
  RBENV_GEMSET_ROOT="$(rbenv-prefix)/gemsets"
fi

if [ ! -x "$RBENV_COMMAND_PATH" ]; then
  for gemset in $(active_gemsets); do
    command="${RBENV_GEMSET_ROOT}/${gemset}/bin/$RBENV_COMMAND"
    if [ -x "$command" ]; then
      RBENV_COMMAND_PATH="$command"
      break
    fi
  done
fi
