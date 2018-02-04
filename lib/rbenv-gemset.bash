if [[ -n "$rbenv_gemset_lib_loaded" ]]; then
  return 0
fi

rbenv_gemset_lib_loaded=yes

function rbenv_gemset_err() {
  local message="DEBUG $BASHPID [rbenv-gemset] ${@}"
  (>&2 echo "$message")
  # if [[ -n "$RENV_DEBUG" ]]; then
  #   (>&2 echo "DEBUG [rbenv-gemset] ")
  # fi
  return 0
}


# Write a debug message to STDERR if `$RBENV_GEMSET_DEBUG` is not empty.
# 
# Writes in a sub-shell so it doesn't mess up anything else. This trashes
# perfomance of course, so don't profie with it enabled.
# 
# @param $@ Passed to `echo`
# 
function rbenv_gemset_debug() {
  if [[ -n $RBENV_GEMSET_DEBUG ]]; then
    rbenv_gemset_err "$@"
  fi
}


# Dump a variable name and value when debugging
function rbenv_gemset_debug_var {
  if [[ -n $RBENV_GEMSET_DEBUG ]]; then
    local name="$1"
    printf "%-32s ${!name}\n" "${name}:"
  fi
}


function rbenv_gemset_fatal() {
  rbenv_gemset_err "FATAL $@"
  exit 1
}


# Test if a variable is set.
function rbenv_gemset_is_set() {
  local var_name="$1"
  
  rbenv_gemset_debug "TESTING if var \$${var_name} is set..."
  
  # Test if `$RBENV_GEMSETS` is unset
  # 
  # Adapted from https://stackoverflow.com/a/13864829/1658272
  # 
  if [[ -z ${!var_name+_} ]]; then
    rbenv_gemset_debug "Var \$${var_name} is UNSET (or null), returning 1"
    return 1
  else
    rbenv_gemset_debug \
      "Var \$${var_name} is SET to '${!var_name}', returning 0"
    return 0
  fi
}


function rbenv_gemset_ensure() {
  local var_name="$1"
  rbenv_gemset_debug \
    "ENSURING \$${var_name} is set..."
  
  rbenv_gemset_is_set "${var_name}" && return 0
  
  local set_func_name="_rbenv_gemset_set_${var_name}"
  
  rbenv_gemset_debug \
    "CALLING set function '${set_func_name}'..."
  
  # the `|| true` is **super** important... we want to keep going no matter
  # what happen in there so we can report it
  "${set_func_name}" || true
  
  if ! rbenv_gemset_is_set "${var_name}"; then
    rbenv_gemset_fatal \
      "Function '${set_func_name}' failed to set variable \$${var_name}"
  fi
  
  rbenv_gemset_debug \
    "SET \$${var_name}=${!var_name}"
  
  return 0
}


# Variable Set Functions
# ============================================================================
# 
# These functions are specifically named `_rbenv_gemset_set_<name>` and *must*
# set the `$<name>` variable (they may set it to '').
# 
# They are dynamically called by `rbenv_gemset_ensure`, which checks if the
# var is set and calls the coresponding set function if it's not.
# 


# rbenv Script Caches
# ----------------------------------------------------------------------------

# Set `$rbenv_gemset_version_name` to `rbenv-version-name` output
function _rbenv_gemset_set_rbenv_gemset_version_name() {
  rbenv_gemset_version_name="$(rbenv-version-name)"
}


# Set `$rbenv_gemset_version_file` to `rbenv-version-file` output
function _rbenv_gemset_set_rbenv_gemset_version_file() {
  rbenv_gemset_version_file="$(rbenv-version-file)"
}


# Set `$rbenv_gemset_prefix` to `rbenv-prefix` output
function _rbenv_gemset_set_rbenv_gemset_prefix() {
  rbenv_gemset_prefix="$(rbenv-prefix)"
}


# 
# ----------------------------------------------------------------------------

# Set `$rbenv_gemset_version_file_dir` to the directory of
# `$rbenv_gemset_version_file`
function _rbenv_gemset_set_rbenv_gemset_version_file_dir() {
  rbenv_gemset_ensure rbenv_gemset_version_file
  rbenv_gemset_version_file_dir="$(dirname "${rbenv_gemset_version_file}")"
}


# Set and export the `$RBENV_GEMSET_SYSTEM_ROOT` var (seems that it may already
# be set externally)
function _rbenv_gemset_set_RBENV_GEMSET_SYSTEM_ROOT() {
  export RBENV_GEMSET_SYSTEM_ROOT="/usr/local/share/ruby-gemsets"
}


# Set `$RBENV_GEMSET_ROOT` depending on if rbenv is using the `system` Ruby
# version or not.
function _rbenv_gemset_set_RBENV_GEMSET_ROOT() {
  rbenv_gemset_ensure rbenv_gemset_version_name
  
  if [ "$rbenv_gemset_version_name" = "system" ]; then
    rbenv_gemset_ensure RBENV_GEMSET_SYSTEM_ROOT
    RBENV_GEMSET_ROOT="$RBENV_GEMSET_SYSTEM_ROOT"
  else
    rbenv_gemset_ensure rbenv_gemset_prefix
    RBENV_GEMSET_ROOT="${rbenv_gemset_prefix}/gemsets"
  fi
}


# Set `$rbenv_gemset_file` to the file path that used to be output by
# `rbenv-gemset-file`.
# 
function _rbenv_gemset_set_rbenv_gemset_file() {
  rbenv_gemset_ensure rbenv_gemset_version_file_dir
  
  if [[ $RBENV_DIR = $rbenv_gemset_version_file_dir* ]]; then
    rbenv_gemset_locate_local_gemsets_file_from "$RBENV_DIR"
  elif [ -z "$RBENV_GEMSET_FILE" ]; then
    rbenv_gemset_locate_local_gemsets_file_from "$PWD"
  elif [ -e "$RBENV_GEMSET_FILE" ]; then
    rbenv_gemset_file="$RBENV_GEMSET_FILE"
  else
    rbenv_gemset_file=''
  fi
}


# Ensure `$RBENV_GEMSETS` is set. This replaces the output of
# `rbenv-gemset-active`.
# 
function _rbenv_gemset_set_RBENV_GEMSETS() {
  # Ensure we have `$rbenv_gemset_file` set
  rbenv_gemset_ensure rbenv_gemset_file
  
  # If there is a gemset file
  if [ -n "$rbenv_gemset_file" ]; then
    RBENV_GEMSETS="$(cat "$rbenv_gemset_file")"
    if echo $RBENV_GEMSETS | grep -E '(^| )-global( |$)' >/dev/null 2>&1; then
      RBENV_GEMSETS=$(echo $RBENV_GEMSETS | sed -E 's/ /  /g;s/(^| )-?global( |$)//g')
    elif echo $RBENV_GEMSETS | grep -vE '(^| )global( |$)' >/dev/null 2>&1; then
      RBENV_GEMSETS="$RBENV_GEMSETS global"
    fi
  else
    # We didn't find anything, set to empty string
    RBENV_GEMSETS=''
  fi
}


function _rbenv_gemset_set_RBENV_GEMSET_DIR() {
  rbenv_gemset_ensure rbenv_gemset_file
  RBENV_GEMSET_DIR="$(dirname ${rbenv_gemset_file} 2>/dev/null)"
}



# 
# ============================================================================

function rbenv_gemset_locate_local_gemsets_file_from() {
  local root="$1"
  while [ -n "$root" ]; do
    if [ -e "${root}/.rbenv-gemsets" ]; then
      rbenv_gemset_file="${root}/.rbenv-gemsets"
      return 0
    elif [ -e "${root}/.ruby-gemset" ]; then
      rbenv_gemset_file="${root}/.ruby-gemset"
      return 0
    fi
    root="${root%/*}"
  done
  # Did not find it, but need to flag that we've looked by setting the var
  # to the empty string
  rbenv_gemset_file=''
}
