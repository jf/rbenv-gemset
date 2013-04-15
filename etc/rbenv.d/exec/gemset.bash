unset GEM_HOME GEM_PATH

if [ "$(rbenv-version-name)" = "system" ]; then
  RBENV_GEMSET_ROOT="$RBENV_GEMSET_SYSTEM_ROOT"
else
  RBENV_GEMSET_ROOT="$(rbenv-prefix)/gemsets"
fi

OLDIFS="$IFS"
IFS=$' \t\n'
for gemset in $(rbenv-gemset active 2>/dev/null); do
  path="${RBENV_GEMSET_ROOT}/$gemset"
  PATH="$path/bin:$PATH"
  if [ -z "$GEM_HOME" ]; then
    GEM_HOME="$path"
    GEM_PATH="$path"
  else
    GEM_PATH="$GEM_PATH:$path"
  fi
done
IFS="$OLDIFS"

if [ -n "$GEM_HOME" ]; then
  export GEM_HOME GEM_PATH PATH
fi
