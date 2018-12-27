#!/usr/bin/env bash
# Source the lib, if it hasn't been already
if [[ -z "$rbenv_gemset_lib_loaded" ]]; then
  rbenv_gemset_root="$(dirname "${BASH_SOURCE[0]}")/../../../"
  source "${rbenv_gemset_root}/lib/rbenv-gemset.bash"
fi

rbenv_gemset_debug "gemset.which.bash STARTING ${@}"

# Guard against running twice
if [[ $RBENV_GEMSET_WHICH_ALREADY = yes ]]; then
  rbenv_gemset_debug "gemset.which.bash already loaded, RETURNING"
  return 0
else
  export RBENV_GEMSET_WHICH_ALREADY=yes
fi

# Now, on to the actual work...
rbenv_gemset_debug "gemset.which.bash EXECUTING"

# Ensure we have `$RBENV_GEMSETS` setup, which we used to get from the output
# of `rbenv-gemset-active`
rbenv_gemset_ensure RBENV_GEMSETS

# Short-ciruit if there are no gemsets
if [[ -z "$RBENV_GEMSETS" ]]; then
  rbenv_gemset_debug "No gemsets, RETURNING"
  return 0
fi

rbenv_gemset_debug "gemset.which.bash LOOP..."

# Now the original code, which is free of sub-shells
OLDIFS="$IFS"
IFS=$' \t\n'
for gemset in $RBENV_GEMSETS; do
  rbenv_gemset_debug "PROCESSING gemset ${gemset}..."

  if [[ $gemset =~ $RBENV_GEMSET_PROJECT_GEMSET_PATTERN ]]; then
    rbenv_gemset_ensure RBENV_GEMSET_DIR
    command="${RBENV_GEMSET_DIR}/${gemset}/bin/$RBENV_COMMAND"
    if [ -x "$command" ]; then
      RBENV_COMMAND_PATH="$command"
      break
    fi
  else
    rbenv_gemset_ensure RBENV_GEMSET_ROOT
    command="${RBENV_GEMSET_ROOT}/${gemset}/bin/$RBENV_COMMAND"
    if [ -x "$command" ]; then
      RBENV_COMMAND_PATH="$command"
      break
    fi
  fi
done
IFS="$OLDIFS"

rbenv_gemset_debug "gemset.which.bash DONE ${@}"
