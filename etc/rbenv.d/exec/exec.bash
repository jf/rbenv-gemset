[[ $RBENV_GEMSET_ALREADY = "yes" ]] && return
export RBENV_GEMSET_ALREADY=yes

unset GEM_HOME GEM_PATH

if [ "$RBENV_VERSION" = "system" ]; then
  # dont bother carrying on if `rbenv version` is "system"; the codebase has not supported this for a long time now!
  return
else
  # cache result of `rbenv-prefix` call so we only call it once
  # NOTE: while it may be tempting to try to use one of RBENV_{COMMAND,BIN}_PATH, *this will NOT work with project gemsets*!
  _rbenv_prefix=$(rbenv-prefix)

  _rbenv_gemsets_container="$_rbenv_prefix/gemsets"
fi

_project_dir="$(rbenv-gemset file 2>/dev/null)"
_project_dir=${_project_dir%/*}
_project_gemset='^\..+'
_path_acc=""
#
OLDIFS="$IFS"
IFS=$' \t\n'
for gemset in $(rbenv-gemset active 2>/dev/null); do
  if [[ $gemset =~ $_project_gemset ]]; then
    _gemset_dir="$_project_dir/$gemset"
  else
    _gemset_dir="$_rbenv_gemsets_container/$gemset"
  fi
  _path_acc="$_path_acc:$_gemset_dir/bin"

  if [ -z "$GEM_HOME" ]; then
    GEM_HOME="$_gemset_dir"
    GEM_PATH="$_gemset_dir"
  else
    GEM_PATH="$GEM_PATH:$_gemset_dir"
  fi
done
IFS="$OLDIFS"

# append rbenv Ruby gemdir to GEM_PATH;
# invocation tested to work for: CRuby, JRuby, and TruffleRuby. Likely for Rubinius too (anybody still on this?)
# NOTE: special PATH invocation for "gem env gemdir" is needed for JRuby (#94 was a foreshadowing)!
GEM_PATH="$GEM_PATH:$(PATH="$_rbenv_prefix/bin:$PATH" $_rbenv_prefix/bin/gem env gemdir)"

if [ -n "$GEM_HOME" ]; then
  PATH="${_path_acc#:}:$PATH"
  export GEM_HOME GEM_PATH PATH
fi
