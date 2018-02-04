# Source the lib, if it hasn't been already
if [[ -z "$rbenv_gemset_lib_loaded" ]]; then
  rbenv_gemset_root="$(dirname "${BASH_SOURCE[0]}")/../../../"
  source "${rbenv_gemset_root}/lib/rbenv-gemset.bash"
fi

rbenv_gemset_debug "gemset.exec.bash STARTING ${@}"

# Guard against running twice
if [[ $RBENV_GEMSET_EXEC_ALREADY = yes ]]; then
  rbenv_gemset_debug "gemset.exec.bash already loaded, RETURNING"
  return 0
else
  export RBENV_GEMSET_EXEC_ALREADY=yes
fi

# Now, on to the actual work...
rbenv_gemset_debug "gemset.exec.bash EXECUTING"

# Ensure we have `$RBENV_GEMSETS` setup, which we used to get from the output
# of `rbenv-gemset-active`
rbenv_gemset_ensure RBENV_GEMSETS

# Short-ciruit if there are no gemsets
if [[ -z "$RBENV_GEMSETS" ]]; then
  rbenv_gemset_debug "No gemsets, RETURNING"
  return 0
fi

# Hmmm... need to look into this..?
unset GEM_HOME GEM_PATH

rbenv_gemset_debug "gemset.which.bash LOOP..."

OLDIFS="$IFS"
IFS=$' \t\n'
for gemset in "$RBENV_GEMSETS"; do
  if [[ $gemset =~ $RBENV_GEMSET_PROJECT_GEMSET_PATTERN ]]; then
    rbenv_gemset_ensure RBENV_GEMSET_DIR
    path="${RBENV_GEMSET_DIR}/$gemset"
  else
    rbenv_gemset_ensure RBENV_GEMSET_ROOT
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

rbenv_gemset_ensure rbenv_gemset_gemdir
GEM_PATH="$GEM_PATH:${rbenv_gemset_gemdir}"

if [ -n "$GEM_HOME" ]; then
  export GEM_HOME GEM_PATH PATH
fi
