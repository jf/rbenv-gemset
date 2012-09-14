if [ "$(rbenv-version-name)" = "system" ]; then
  RBENV_GEMSET_ROOT="$(rbenv-gemset system-root)"
else
  RBENV_GEMSET_ROOT="$(rbenv-prefix)/gemsets"
fi

for gemset in $(rbenv-gemset active 2>/dev/null); do
  command="${RBENV_GEMSET_ROOT}/${gemset}/bin/$RBENV_COMMAND"
  if [ -x "$command" ]; then
    RBENV_COMMAND_PATH="$command"
    break
  fi
done
