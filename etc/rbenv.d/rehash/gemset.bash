shopt -s nullglob

RBENV_GEMSET_DIR="$(dirname "$(rbenv-gemset file 2>/dev/null)" 2>/dev/null)"
PROJECT_GEMSET_LIST="${RBENV_ROOT}/versions/$(rbenv-version-name)/gemsets/.project-gemsets"
project_gemset='\..+'
OLDIFS="$IFS"
IFS=$' \t\n'
for gemset in $(rbenv-gemset active 2>/dev/null); do
  if [[ $gemset =~ $project_gemset ]]; then
    mkdir -p "$PROJECT_GEMSET_LIST"
    gemset=${RBENV_GEMSET_DIR}/$gemset
    link=${PROJECT_GEMSET_LIST}/${gemset////__}
    ln -sf "$gemset" "$link"
  fi
done
IFS="$OLDIFS"

cd "$SHIM_PATH"
gemset_bin=(${RBENV_ROOT}/versions/*/gemsets/*/bin/* ${RBENV_ROOT}/versions/*/gemsets/.project-gemsets/*/bin/*)
make_shims "${gemset_bin[@]}"
cd "$CUR_PATH"
