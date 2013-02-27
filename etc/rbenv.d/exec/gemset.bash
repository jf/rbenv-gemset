unset GEM_HOME GEM_PATH

if [ "$(rbenv-version-name)" = "system" ]; then
  RBENV_GEMSET_ROOT="$RBENV_GEMSET_SYSTEM_ROOT"
else
  RBENV_GEMSET_ROOT="$(rbenv-prefix)/gemsets"
fi

gemsets=`rbenv-gemset active 2>/dev/null`

# to avoid infinite loop by evaluating recursively
if [ -n "$gemsets" ]; then
  DEFAULT_GEM_PATH=`RBENV_GEMSETS=" " gem env gempath`
fi

for gemset in $gemsets; do
  if [ $gemset = "__DEFAULT__" ]; then
    GEM_PATH="$GEM_PATH:$DEFAULT_GEM_PATH"
  else
    path="${RBENV_GEMSET_ROOT}/$gemset"
    if [ -z "$GEM_HOME" ]; then
      GEM_HOME="$path"
    fi
    GEM_PATH="$GEM_PATH:$path"
  fi
done

if [ -n "$GEM_HOME" ]; then
  export GEM_HOME GEM_PATH
fi
