#!/bin/bash

set -ex

if [[ $(uname) == "Darwin" ]]; then
  shared_flags="-Wl,-undefined -Wl,dynamic_lookup"
else
  shared_flags="-Wl,-shared"
fi

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" && "${mpi}" == "openmpi" ]]; then
  export OPAL_PREFIX="$PREFIX"
  # export OMPI_CC="$CC"
  export OPAL_CC="$CC"
fi

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == 1 ]]; then
  (
    mkdir -p src/dummysizes/build-host
    pushd src/dummysizes/build-host

    cp $RECIPE_DIR/CMakeLists-dummysizes.txt $SRC_DIR/src/dummysizes/CMakeLists.txt

    export CC=$CC_FOR_BUILD
    export LDFLAGS=${LDFLAGS//$PREFIX/$BUILD_PREFIX}
    export PKG_CONFIG_PATH=${PKG_CONFIG_PATH//$PREFIX/$BUILD_PREFIX}

    # Unset them as we're ok with builds that are either slow or non-portable
    unset CFLAGS

    cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$BUILD_PREFIX \
      -DCMAKE_INSTALL_PREFIX=$BUILD_PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=True \
      -DBUILD_PTSCOTCH=OFF

    cmake --build . --parallel ${CPU_COUNT} --config Release
  )
fi

cmake \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_SHARED_LINKER_FLAGS="$shared_flags" \
  -D CMAKE_INSTALL_PREFIX=$PREFIX \
  -D BUILD_SHARED_LIBS=ON \
  -B build \
  .

cmake --build ./build --parallel ${CPU_COUNT} --config Release
cmake --install ./build --component=libscotch
