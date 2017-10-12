if [[ "${PKG_NAME}" == "ptscotch" ]]; then

mpic++ $CXXFLAGS "-I$PREFIX/include" "-L$PREFIX/lib" "${RECIPE_DIR}/test/test_ptscotch.cxx" -o test_ptscotch -DSCOTCH_PTSCOTCH -lptscotch -lptscotcherr

if [[ "$(uname)" == "Darwin" ]]; then
    # FIXME: mpiexec messes with docker (CircleCI) builds
    ${RECIPE_DIR}/mpiexec.sh ./test_ptscotch
fi

fi
