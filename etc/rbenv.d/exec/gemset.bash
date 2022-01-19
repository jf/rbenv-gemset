[[ $RBENV_GEMSET_ALREADY = yes ]] && return
[[ $RBENV_GEMSET_ALREADY = "" ]] && export RBENV_GEMSET_ALREADY=yes

unset GEM_HOME GEM_PATH

if [ "$(rbenv-version-name)" = "system" ]; then
  RBENV_GEMSET_ROOT="$RBENV_GEMSET_SYSTEM_ROOT"
else
  RBENV_GEMSET_ROOT="$(rbenv-prefix)/gemsets"
fi

RBENV_GEMSET_DIR="$(dirname "$(rbenv-gemset file 2>/dev/null)" 2>/dev/null)"
project_gemset='^\..+'
OLDIFS="$IFS"
IFS=$' \t\n'
for gemset in $(rbenv-gemset active 2>/dev/null); do
  if [[ $gemset =~ $project_gemset ]]; then
    path="${RBENV_GEMSET_DIR}/$gemset"
  else
    path="${RBENV_GEMSET_ROOT}/$gemset"
  fi
  PATH="$path/bin:$PATH"

  if [ -z "$GEM_HOME" ]; then
    GEM_HOME="$path"
    GEM_PATH="$path"
  else
    GEM_PATH="$GEM_PATH:$path"
  fi
done
IFS="$OLDIFS"

# !! NOTE that with your standard rbenv setup, we do *NOT* need to do this; but this helps bulletproof the call to 'gem'
# !! if we ever attempt to use/call rbenv in a non-standard way
# !! see https://github.com/jf/rbenv-gemset/issues/94 for our motivation
BULLETPROOF_EXEC_PATH=$(rbenv-which ruby)
BULLETPROOF_EXEC_PATH=${BULLETPROOF_EXEC_PATH%/*}

GEM_PATH="$GEM_PATH:$(PATH=$BULLETPROOF_EXEC_PATH:$PATH $BULLETPROOF_EXEC_PATH/gem env gemdir)"

if [ -n "$GEM_HOME" ]; then
  export GEM_HOME GEM_PATH PATH
fi
