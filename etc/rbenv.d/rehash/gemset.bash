shopt -s nullglob
gemset_bin=(${RBENV_ROOT}/versions/*/gemsets/*/bin/*)
shopt -s nullglob

cd "$SHIM_PATH"
make_shims ${gemset_bin[@]}
cd "$CUR_PATH"
