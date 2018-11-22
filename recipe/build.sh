#!/bin/sh
set -ex
cp $RECIPE_DIR/Makefile.inc src/Makefile.inc

export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include -DIDXSIZE64 -DSCOTCH_RENAME -Drestrict=__restrict -DCOMMON_FILE_COMPRESS_GZ -DCOMMON_RANDOM_FIXED_SEED -DCOMMON_PTHREAD"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -lz -lm -pthread"

if [[ $(uname) == "Darwin" ]]; then
  export CFLAGS="${CFLAGS} -DCOMMON_PTHREAD_BARRIER -DCOMMON_TIMING_OLD"
  export SONAME="install_name"
else
  export LDFLAGS="${LDFLAGS} -lrt"
  export SONAME="soname"
fi
# VERSION used in dylib versions in debian makefile patches
export VERSION=$PKG_VERSION

if [ "$PKG_NAME" == "scotch" ]
then

export CFLAGS="${CFLAGS} -DSCOTCH_PTHREAD"
export CCD=${CC}

# build
cd src/
make esmumps 2>&1 | tee make.log
cd ..
# install
mkdir -p $PREFIX/lib/
cp -v lib/*${SHLIB_EXT}* $PREFIX/lib/
mkdir -p $PREFIX/bin/
cp -v bin/* $PREFIX/bin/
mkdir -p $PREFIX/include/
# avoid conflicts with the real metis.h
mkdir -p include/scotch
mv include/metis.h include/scotch/
cp -rv include/* $PREFIX/include/

# make check after installing so that @rpath resolves
cd src/
make check 2>&1 | tee check.log

fi # scotch


if [ "$PKG_NAME" == "ptscotch" ]
then

export CCP=mpicc
export CCD=${CCP}

export MPIEXEC="${RECIPE_DIR}/mpiexec.sh"

# build
cd src/
make ptesmumps 2>&1 | tee make.log
cd ..
# install
mkdir -p $PREFIX/lib/
cp -v lib/libpt*${SHLIB_EXT}* $PREFIX/lib/
mkdir -p $PREFIX/bin/
cp -v bin/dg* $PREFIX/bin/
mkdir -p $PREFIX/include/
cp -v include/ptscotch*.h $PREFIX/include/
# avoid conflicts with the real parmetis.h
mkdir -p $PREFIX/include/scotch
cp -v include/parmetis.h  $PREFIX/include/scotch/

# make check after installing so that @rpath resolves
cd src/
make ptcheck EXECP="$MPIEXEC -n 4" 2>&1 | tee check.log

fi # ptscotch
