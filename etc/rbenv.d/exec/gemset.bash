if [ "$(rbenv-version-name)" = "system" ]; then
  RBENV_GEMSET_ROOT="$(rbenv-gemset system-root)"
else
  RBENV_GEMSET_ROOT="$(rbenv-prefix)/gemsets"
fi

for gemset in $(rbenv-gemset active 2>/dev/null); do
  path="${RBENV_GEMSET_ROOT}/$gemset"
  if [ -z "$GEM_HOME" ]; then
    GEM_HOME="$path"
  fi
  if [ -z "$GEM_PATH" ]; then
    GEM_PATH="$path"
  else
    GEM_PATH="$GEM_PATH:$path"
  fi
done

if [ -n "$GEM_HOME" ]; then
  export GEM_HOME GEM_PATH
fi
